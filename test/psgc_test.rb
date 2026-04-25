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

  def test_find_region_by_code
    region = Psgc.find_region(code: "1300000000")
    refute_nil region
    assert_equal "National Capital Region (NCR)", region[:name]
  end

  def test_find_region_by_name
    region = Psgc.find_region(name: "National Capital Region")
    refute_nil region
    assert_equal "1300000000", region[:code]
  end

  def test_find_province
    province = Psgc.find_province(code: "1400100000")
    refute_nil province
    assert_equal "Abra", province[:name]
  end

  def test_find_barangay
    barangay = Psgc.find_barangay(code: "1403208016")
    refute_nil barangay
    assert_equal "Bagtayan", barangay[:name]
  end
end