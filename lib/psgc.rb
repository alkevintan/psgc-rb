# frozen_string_literal: true

require "json"

module Psgc
  VERSION = "0.1.0"

  class Error < StandardError; end

  def self.data_dir
    File.expand_path("../../data", __FILE__)
  end

  def self.regions
    @regions ||= load_data("regions")
  end

  def self.provinces
    @provinces ||= load_data("provinces")
  end

  def self.cities_municipalities
    @cities_municipalities ||= load_data("cities_municipalities")
  end

  def self.barangays
    @barangays ||= load_data("barangays")
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

  def self.find(collection, code: nil, name: nil, **attrs)
    collection.each do |item|
      return item if code && item[:code] == code
      return item if name && item[:name].to_s.downcase.include?(name.to_s.downcase)
      attrs.each { |k, v| return item if item[k] == v && v }
    end
    nil
  end

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
  # @param levels [Array<Symbol>] which levels to search (:regions, :provinces, :cities_municipalities, :barangays)
  # @param limit [Integer] max matches per level (not total)
  # @return [Hash{Symbol => Array}] hash with requested level keys and matching records
  def self.search(query, levels: nil, limit: nil)
    return {} unless query && !query.to_s.strip.empty?

    query_down = query.to_s.downcase
    levels ||= [:regions, :provinces, :cities_municipalities, :barangays]

    result = {}
    levels.each do |level|
      collection = case level
                   when :regions then regions
                   when :provinces then provinces
                   when :cities_municipalities then cities_municipalities
                   when :barangays then barangays
                   else raise ArgumentError, "unknown level: #{level}. Valid: :regions, :provinces, :cities_municipalities, :barangays"
                   end

      matches = collection.select { |item| item[:name].to_s.downcase.include?(query_down) }
      matches = matches.first(limit) if limit
      result[level] = matches
    end

    result
  end
end
