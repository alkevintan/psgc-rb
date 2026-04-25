# frozen_string_literal: true

require "bundler/gem_tasks"
require "json"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

namespace :data do
  PSA_URL = "https://psa.gov.ph/classification/psgc/"

  desc "Fetch latest PSGC data from PSA"
  task :fetch do
    puts "Fetching PSGC data from #{PSA_URL}"
    puts "Note: Manual download required - PSA provides Excel files"
    puts "Download: #{PSA_URL}"
  end

  desc "Parse PSGC Excel file and generate JSON fixtures"
  task :parse, [:file] do |_t, args|
    file = args[:file] || "data/PSGC-1Q-2026-Publication-Datafile.xlsx"
    unless File.exist?(file)
      abort "Excel file not found: #{file}. Run 'rake data:fetch' to download."
    end

    puts "Parsing #{file}..."
    puts "(Using Python openpyxl)"

    parse_with_python(file)

    puts "Done."
  end

  def parse_with_python(file)
    script = <<~PYTHON
      import openpyxl
      import json
      import sys

      wb = openpyxl.load_workbook(sys.argv[1])
      ws = wb["PSGC"]

      regions = []
      provinces = []
      cities_municipalities = []
      barangays = []

      for row in ws.iter_rows(min_row=2, values_only=True):
          code = row[0]
          name = row[1]
          level = row[3]
          if not code or not name or not level:
              continue

          code = str(code).strip()
          name = str(name).strip()

          entry = {"code": code, "name": name}

          if level == "Reg":
              regions.append(entry)
          elif level == "Prov":
              entry["region_code"] = code[:2]
              provinces.append(entry)
          elif level in ("City", "Mun", "SubMun"):
              entry["province_code"] = code[:4]
              cities_municipalities.append(entry)
          elif level == "Bgy":
              entry["city_municipality_code"] = code[:6]
              barangays.append(entry)

      with open("data/regions.json", "w") as f:
          json.dump(regions, f, indent=2)
      with open("data/provinces.json", "w") as f:
          json.dump(provinces, f, indent=2)
      with open("data/cities_municipalities.json", "w") as f:
          json.dump(cities_municipalities, f, indent=2)
      with open("data/barangays.json", "w") as f:
          json.dump(barangays, f, indent=2)

      print(f"Generated {len(regions)} regions, {len(provinces)} provinces, {len(cities_municipalities)} cities/municipalities, {len(barangays)} barangays")
    PYTHON

    py_pid = spawn("python3", "-c", script, file)
    _, status = Process.wait2(py_pid)
    raise "Python parsing failed" unless status.success?
  end
end

desc "Update PSGC data (fetch + parse)"
task update: ["data:fetch", "data:parse"]