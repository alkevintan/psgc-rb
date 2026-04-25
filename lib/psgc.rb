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
end