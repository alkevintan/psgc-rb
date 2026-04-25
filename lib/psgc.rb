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
end