# frozen_string_literal: true

require "minitest/autorun"
require "psgc"

class PsgcTest < Minitest::Test
  def test_version
    refute_nil Psgc::VERSION
  end

  def test_regions
    assert_kind_of Array, Psgc.regions
    refute_empty Psgc.regions
  end

  def test_provinces
    assert_kind_of Array, Psgc.provinces
    refute_empty Psgc.provinces
  end

  def test_cities_municipalities
    assert_kind_of Array, Psgc.cities_municipalities
    refute_empty Psgc.cities_municipalities
  end

  def test_barangays
    assert_kind_of Array, Psgc.barangays
    refute_empty Psgc.barangays
  end
end