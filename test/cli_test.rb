# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class CLITest < Minitest::Test
  def setup
    @cli = File.expand_path("../exe/psgc", __dir__)
  end

  def run_cli(*args)
    stdout, stderr, status = Open3.capture3("ruby", @cli, *args)
    [stdout, stderr, status]
  end

  def test_find_command
    stdout, _stderr, status = run_cli("find", "cebu")
    assert status.success?, "Expected success"
    assert_includes stdout, "Provinces"
  end

  def test_find_with_limit
    stdout, _stderr, status = run_cli("find", "manila", "--limit=2")
    assert status.success?, "Expected success"
    assert_includes stdout, "Barangays (2)"
  end

  def test_hierarchy_command
    stdout, _stderr, status = run_cli("hierarchy", "1403208016")
    assert status.success?, "Expected success"
    assert_includes stdout, "Bagtayan"
    assert_includes stdout, "Balbalan"
  end

  def test_hierarchy_invalid_code
    _stdout, _stderr, status = run_cli("hierarchy", "123")
    assert_equal false, status.success?, "Expected failure for invalid code"
  end

  def test_valid_command
    stdout, _stderr, status = run_cli("valid", "1400000000")
    assert status.success?, "Expected success"
    assert_includes stdout, "Valid"
  end

  def test_valid_invalid
    stdout, _stderr, status = run_cli("valid", "9999999999")
    assert_equal false, status.success?, "Expected failure for invalid code"
    assert_includes stdout, "Invalid"
  end

  def test_stats_command
    stdout, _stderr, status = run_cli("stats")
    assert status.success?, "Expected success"
    assert_includes stdout, "Regions:"
    assert_includes stdout, "Provinces:"
  end

  def test_help_command
    stdout, _stderr, status = run_cli("help")
    assert status.success?, "Expected success"
    assert_includes stdout, "Commands"
  end

  def test_invalid_command
    _stdout, _stderr, status = run_cli("bogus")
    assert_equal false, status.success?
  end

  def test_version_flag
    stdout, _stderr, status = run_cli("stats", "--version")
    assert status.success?, "Expected success"
    assert_includes stdout, "psgc-rb"
  end

  def test_export_csv_default
    stdout, _stderr, status = run_cli("export", "--csv")
    assert status.success?, "Expected success"
    assert_includes stdout, "code,name"
  end

  def test_export_csv_level
    stdout, _stderr, status = run_cli("export", "--csv", "--level=provinces")
    assert status.success?, "Expected success"
    assert_includes stdout, "Abra"
  end

  def test_export_yaml
    stdout, _stderr, status = run_cli("export", "--yaml", "--level=barangays")
    assert status.success?, "Expected success"
    assert_includes stdout, "barangays:"
  end

  def test_export_geojson
    stdout, _stderr, status = run_cli("export", "--geojson", "--level=barangays")
    assert status.success?, "Expected success"
    assert_includes stdout, "FeatureCollection"
  end

  def test_export_default
    stdout, _stderr, status = run_cli("export", "--csv")
    assert status.success?, "Expected success"
    assert_includes stdout, "National Capital Region"
  end

  def test_export_invalid_level
    _stdout, _stderr, status = run_cli("export", "--csv", "--level=foo")
    refute status.success?, "Expected failure for invalid level"
  end

  def test_export_cities_alias
    stdout, _stderr, status = run_cli("export", "--csv", "--level=cities")
    assert status.success?, "Expected success for --level=cities"
    assert_includes stdout, "1403201000"
  end

  def test_export_help
    stdout, _stderr, status = run_cli("export", "--help")
    assert status.success?, "Expected success"
    assert_includes stdout, "Usage"
  end
end
