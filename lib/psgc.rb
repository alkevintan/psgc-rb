# frozen_string_literal: true

require "json"

module Psgc
  VERSION = "0.2.0"

  class Error < StandardError; end

  def self.data_dir
    File.expand_path("../../data", __FILE__)
  end

  @data_mutex = Mutex.new

  def self.regions
    @regions || @data_mutex.synchronize { @regions ||= load_data("regions") }
  end

  def self.provinces
    @provinces || @data_mutex.synchronize { @provinces ||= load_data("provinces") }
  end

  def self.cities_municipalities
    @cities_municipalities || @data_mutex.synchronize { @cities_municipalities ||= load_data("cities_municipalities") }
  end

  def self.barangays
    @barangays || @data_mutex.synchronize { @barangays ||= load_data("barangays") }
  end

  def self.load_data(type)
    file_path = File.join(data_dir, "#{type}.json")
    return [] unless File.exist?(file_path)

    JSON.parse(File.read(file_path), symbolize_names: true)
  end

  def self.find_region(code: nil, name: nil)
    return nil unless code || name
    find(regions, code: code, name: name)
  end

  def self.find_province(code: nil, name: nil, region_code: nil)
    return nil unless code || name || region_code
    find(provinces, code: code, name: name, region_code: region_code)
  end

  def self.find_city_municipality(code: nil, name: nil, province_code: nil)
    return nil unless code || name || province_code
    find(cities_municipalities, code: code, name: name, province_code: province_code)
  end

  def self.find_barangay(code: nil, name: nil, city_municipality_code: nil)
    return nil unless code || name || city_municipality_code
    find(barangays, code: code, name: name, city_municipality_code: city_municipality_code)
  end

  # Finds first match in collection using AND semantics.
  # All non-nil criteria must match for a result.
  # Name matching is case-insensitive substring.
  # Code attributes (*_code) use bidirectional prefix matching:
  #   "v.start_with?(item[k]) || item[k].start_with?(v)"
  #   e.g., region_code "14" matches stored "1400000000" and vice versa.
  #
  # @param collection [Array<Hash>] data collection
  # @param code [String, nil] exact PSGC code
  # @param name [String, nil] case-insensitive substring match
  # @param attrs [Hash] additional match criteria
  # @return [Hash, nil] first matching item or nil
  def self.find(collection, code: nil, name: nil, **attrs)
    collection.each do |item|
      matches = true
      matches &&= item[:code] == code if code
      matches &&= item[:name].to_s.downcase.include?(name.to_s.downcase) if name
      attrs.each do |k, v|
        next unless v
        if k.to_s.end_with?("_code")
          matches &&= v.to_s.start_with?(item[k].to_s) || item[k].to_s.start_with?(v.to_s)
        else
          matches &&= item[k] == v
        end
      end
      return item if matches
    end
    nil
  end

  # Traverses PSGC hierarchy for a given code.
  # Uses prefix matching because parent codes are prefixes of child codes
  # (e.g., city code is prefix of barangay code).
  #
  # @param code [String, Integer] 10-digit PSGC code
  # @return [Hash{Symbol => Hash, nil}] hash with :code and found geographic levels
  def self.hierarchy(code)
    return nil unless code.to_s.match?(/^\d{10}$/)
    code = code.to_s

    result = { code: code }

    if code.end_with?("000000")
      result[:region] = find_region(code: code)
    elsif code.end_with?("0000")
      result[:province] = find_province(code: code)
      result[:city_municipality] = find_city_municipality(code: code) unless result[:province]
    elsif code.end_with?("00")
      result[:city_municipality] = find_city_municipality(code: code)
    else
      result[:barangay] = find_barangay(code: code)
    end

    if result[:barangay]
      city = cities_municipalities.find { |c| c[:code].start_with?(result[:barangay][:city_municipality_code]) }
      result[:city_municipality] = city
      if city
        province = provinces.find { |p| p[:code].start_with?(city[:province_code]) }
        result[:province] = province
      end
    elsif result[:city_municipality]
      province = provinces.find { |p| p[:code].start_with?(result[:city_municipality][:province_code]) }
      result[:province] = province
    end

    if result[:province]
      region = regions.find { |r| r[:code].start_with?(result[:province][:region_code]) }
      result[:region] = region
    end

    result[:region] ||= regions.find { |r| r[:code].start_with?(code[0, 2]) }

    result
  end

  # @param query [String] search term (case-insensitive substring match)
  # @param levels [Array<Symbol>] which levels to search (:regions, :provinces, :cities, :cities_municipalities, :barangays)
  # @param limit [Integer] max matches per level (not total)
  # @return [Hash{Symbol => Array}] hash with requested level keys and matching records
  def self.search(query, levels: nil, limit: nil)
    return {} unless query && !query.to_s.strip.empty?

    query_down = query.to_s.downcase
    levels ||= [:regions, :provinces, :cities_municipalities, :barangays]

    result = {}
    levels.each do |level|
      collection = collection_for(level)

      matches = collection.select { |item| item[:name].to_s.downcase.include?(query_down) }
      matches = matches.first(limit) if limit
      result[level] = matches
    end

    result
  end

  # @param code [String, Integer] 10-digit PSGC code
  # @return [Boolean] true if code exists in any level
  def self.valid?(code)
    return false unless code && code.to_s.match?(/^\d{10}$/)

    code_str = code.to_s

    if code_str.end_with?("000000")
      regions.any? { |r| r[:code] == code_str }
    elsif code_str.end_with?("0000")
      provinces.any? { |p| p[:code] == code_str } ||
        cities_municipalities.any? { |c| c[:code] == code_str }
    elsif code_str.end_with?("00")
      cities_municipalities.any? { |c| c[:code] == code_str } ||
        barangays.any? { |b| b[:code] == code_str }
    else
      barangays.any? { |b| b[:code] == code_str }
    end
  end

  # @return [Hash{Symbol => Integer}] counts by level
  def self.stats
    {
      regions: regions.length,
      provinces: provinces.length,
      cities_municipalities: cities_municipalities.length,
      barangays: barangays.length
    }
  end

  # @param level [Symbol] geographic level
  # @return [Symbol] normalized level (:cities -> :cities_municipalities)
  def self.normalize_level(level)
    case level
    when :cities then :cities_municipalities
    else level
    end
  end

  def self.collection_for(level)
    normalized = normalize_level(level)

    case normalized
    when :regions then regions
    when :provinces then provinces
    when :cities_municipalities then cities_municipalities
    when :barangays then barangays
    else raise ArgumentError, "unknown level: #{level}. Valid: :regions, :provinces, :cities, :cities_municipalities, :barangays"
    end
  end

  def self.export_csv(level: :regions, include_headers: true)
    require "csv"
    collection = collection_for(level)

    headers = collection.first.keys.map(&:to_s)

    CSV.generate do |csv|
      csv << headers if include_headers
      collection.each do |item|
        csv << headers.map { |h| item[h.to_sym] }
      end
    end
  end

  def self.export_yaml(level: :regions)
    require "yaml"
    collection = collection_for(level)

    { normalize_level(level) => collection }.to_yaml
  end

  # @return [String] GeoJSON FeatureCollection
  # Note: geometry is null because PSGC data has no geographic coordinates.
  def self.export_geojson(level: :regions)
    collection = collection_for(level)

    features = collection.map do |item|
      props = item.dup
      props.delete(:code)
      {
        type: "Feature",
        id: item[:code],
        geometry: nil,
        properties: props
      }
    end

    {
      type: "FeatureCollection",
      features: features
    }.to_json
  end
end
