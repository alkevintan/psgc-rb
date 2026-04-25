# frozen_string_literal: true

require "minitest/autorun"
require "psgc"

GENERATOR_PATH = File.expand_path("../lib/generators/psgc/seed_generator.rb", __dir__)
TEMPLATE_PATH = File.expand_path("../lib/generators/psgc/templates/seed.rb.erb", __dir__)

class SeedGeneratorTest < Minitest::Test
  def test_generator_file_exists
    assert File.exist?(GENERATOR_PATH)
  end

  def test_template_file_exists
    assert File.exist?(TEMPLATE_PATH)
  end

  def test_template_contains_psgc_references
    src = File.read(TEMPLATE_PATH)
    assert_includes src, "Psgc.regions"
    assert_includes src, "Psgc.provinces"
    assert_includes src, "Psgc.cities_municipalities"
    assert_includes src, "Psgc.barangays"
  end

  def test_template_uses_upsert_all
    src = File.read(TEMPLATE_PATH)
    assert_includes src, ".upsert_all("
  end

  def test_generator_defines_model_options
    src = File.read(GENERATOR_PATH)
    assert_includes src, "region_model"
    assert_includes src, "province_model"
    assert_includes src, "city_model"
    assert_includes src, "barangay_model"
  end

  def test_generator_validates_level
    src = File.read(GENERATOR_PATH)
    assert_includes src, "VALID_LEVELS"
    assert_includes src, "ArgumentError"
  end

  def test_generator_accepts_cities_and_cities_municipalities
    src = File.read(GENERATOR_PATH)
    assert_includes src, "cities"
    assert_includes src, "cities_municipalities"
  end

  def test_template_uses_model_options
    src = File.read(TEMPLATE_PATH)
    assert_includes src, "<%= region_model %>"
    assert_includes src, "<%= province_model %>"
    assert_includes src, "<%= city_model %>"
    assert_includes src, "<%= barangay_model %>"
  end

  def test_template_conditionals_level
    src = File.read(TEMPLATE_PATH)
    assert_includes src, 'level == "all" || level == "regions"'
    assert_includes src, 'cities" || level == "cities_municipalities"'
  end

  def test_renders_each_level_correctly
    require "erb"
    erb = ERB.new(File.read(TEMPLATE_PATH), trim_mode: "-")
    ctx_class = Struct.new(:level, :region_model, :province_model, :city_model, :barangay_model)

    {
      "regions" => "Region.upsert_all",
      "provinces" => "Province.upsert_all",
      "cities" => "City.upsert_all",
      "cities_municipalities" => "City.upsert_all",
      "barangays" => "Barangay.upsert_all"
    }.each do |lvl, expected|
      ctx = ctx_class.new(lvl, "Region", "Province", "City", "Barangay")
      out = erb.result(ctx.instance_eval { binding })
      assert_includes out, expected, "level=#{lvl} should emit #{expected}"
    end
  end
end