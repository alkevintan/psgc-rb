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

  def test_hierarchy_barangay
    result = Psgc.hierarchy("1403208016")
    refute_nil result
    assert_equal "Bagtayan", result[:barangay][:name]
    assert_equal "Balbalan", result[:city_municipality][:name]
    assert_equal "Kalinga", result[:province][:name]
    assert_equal "Cordillera Administrative Region (CAR)", result[:region][:name]
  end

  def test_hierarchy_province
    result = Psgc.hierarchy("1403200000")
    refute_nil result
    assert_equal "Kalinga", result[:province][:name]
    assert_equal "Cordillera Administrative Region (CAR)", result[:region][:name]
  end

  def test_hierarchy_city
    result = Psgc.hierarchy("1403201000")
    refute_nil result
    assert_equal "Balbalan", result[:city_municipality][:name]
    assert_equal "Kalinga", result[:province][:name]
    assert_equal "Cordillera Administrative Region (CAR)", result[:region][:name]
  end

  def test_hierarchy_region
    result = Psgc.hierarchy("1400000000")
    refute_nil result
    assert_equal "Cordillera Administrative Region (CAR)", result[:region][:name]
  end

  def test_hierarchy_huc
    result = Psgc.hierarchy("1380100000")
    refute_nil result
    assert_equal "City of Caloocan", result[:city_municipality][:name]
    assert_equal "National Capital Region (NCR)", result[:region][:name]
  end

  def test_hierarchy_ncr_barangay
    result = Psgc.hierarchy("1380100001")
    refute_nil result
    assert_equal "City of Caloocan", result[:city_municipality][:name]
    assert_equal "National Capital Region (NCR)", result[:region][:name]
  end

  def test_hierarchy_invalid_inputs
    assert_nil Psgc.hierarchy(nil)
    assert_nil Psgc.hierarchy("")
    assert_nil Psgc.hierarchy("123")
    assert_nil Psgc.hierarchy("abc")
  end

  def test_search
    result = Psgc.search("cebu")
    assert_kind_of Hash, result
    assert result[:provinces]
    assert result[:cities_municipalities]
    assert result[:barangays]
    refute_empty result[:provinces]
    assert result[:provinces].any? { |p| p[:name].downcase.include?("cebu") }
  end

  def test_search_with_limit
    result = Psgc.search("san", limit: 2)
    assert_equal 2, result[:barangays].length
  end

  def test_search_with_levels
    result = Psgc.search("cebu", levels: [:provinces])
    assert_equal 1, result.keys.length
    assert result[:provinces]
    assert_equal [:provinces], result.keys
  end

  def test_search_empty_query
    assert_equal({}, Psgc.search(nil))
    assert_equal({}, Psgc.search(""))
    assert_equal({}, Psgc.search("   "))
  end

  def test_search_unknown_level
    assert_raises(ArgumentError) { Psgc.search("test", levels: [:unknown]) }
  end

  def test_valid
    assert Psgc.valid?(Psgc.regions.first[:code])
    assert Psgc.valid?(Psgc.provinces.first[:code])
    assert Psgc.valid?(Psgc.cities_municipalities.first[:code])
    assert Psgc.valid?(Psgc.barangays.first[:code])
    assert Psgc.valid?(1400000000)
  end

  def test_valid_invalid
    refute Psgc.valid?("9999999999")
    refute Psgc.valid?(nil)
    refute Psgc.valid?("")
    refute Psgc.valid?("123")
    refute Psgc.valid?("abcdefghij")
    refute Psgc.valid?(" 1400000000 ")
  end

  def test_stats
    result = Psgc.stats
    assert_kind_of Hash, result
    assert_kind_of Integer, result[:regions]
    assert_kind_of Integer, result[:provinces]
    assert_kind_of Integer, result[:cities_municipalities]
    assert_kind_of Integer, result[:barangays]
    assert result[:regions] > 0
    assert result[:provinces] > 0
    assert result[:cities_municipalities] > 0
    assert result[:barangays] > 0
  end

  def test_find_province_with_code_and_region_code_both_match
    province = Psgc.find_province(code: "1400100000", region_code: "14")
    refute_nil province
    assert_equal "Abra", province[:name]
  end

  def test_find_province_with_code_and_region_code_mismatch
    province = Psgc.find_province(code: "1400100000", region_code: "01")
    assert_nil province
  end

  def test_find_province_with_name_and_region_code_both_match
    province = Psgc.find_province(name: "Abra", region_code: "14")
    refute_nil province
    assert_equal "Abra", province[:name]
  end

  def test_find_barangay_with_code_and_city_code
    barangay = Psgc.find_barangay(code: "1403208016", city_municipality_code: "140320")
    refute_nil barangay
    assert_equal "Bagtayan", barangay[:name]
  end

  def test_find_barangay_with_code_and_wrong_city_code
    barangay = Psgc.find_barangay(code: "1403208016", city_municipality_code: "010101")
    assert_nil barangay
  end

  def test_find_province_by_region_prefix
    province = Psgc.find_province(region_code: "14")
    refute_nil province
    assert_equal "14", province[:region_code]
  end
end
