# Psgc

A Ruby gem providing up-to-date Philippine geographic data from the PSA (Philippine Statistics Authority). Includes Philippine Standard Geographic Codes (PSGC) for regions, provinces, cities/municipalities, and barangays.

Requires Ruby >= 3.2.0.

## Installation

```bash
gem install psgc-rb
```

Or add to Gemfile:

```ruby
gem "psgc-rb"
```

Note: If using the Rails generator, Rails >= 6.1 is required. Each target model (Region, Province, City, or Barangay) must have a unique index on its code column for upsert_all to work.

## Usage

```ruby
require "psgc"

# Get all regions
Psgc.regions
# => [{:code=>"1300000000", :name=>"National Capital Region (NCR)"}, ...]

# Get all provinces
Psgc.provinces
# => [{:code=>"1400100000", :name=>"Abra", :region_code=>"14"}, ...]

# Get all cities and municipalities
Psgc.cities_municipalities
# => [{:code=>"1400101000", :name=>"Bangued", :province_code=>"1400"}, ...]

# Get all barangays
Psgc.barangays
# => [{:code=>"1400101001", :name=>"Bagtayan", :city_municipality_code=>"1400101000"}, ...]

# Foreign-key fields (e.g., :region_code on a province, :province_code on a city)
# store a prefix of the parent's full 10-digit code.

# Finder methods
Psgc.find_region(code: "1300000000")
# => {:code=>"1300000000", :name=>"National Capital Region (NCR)"}

Psgc.find_province(code: "1400100000")
# => {:code=>"1400100000", :name=>"Abra", :region_code=>"14"}

Psgc.find_city_municipality(code: "1400101000")
# => {:code=>"1400101000", :name=>"Bangued", :province_code=>"1400"}

Psgc.find_barangay(code: "1400101001")
# => {:code=>"1400101001", :name=>"Bagtayan", :city_municipality_code=>"1400101000"}

# Find by name (case-insensitive substring match)
Psgc.find_region(name: "National Capital")
# => {:code=>"1300000000", :name=>"National Capital Region (NCR)"}

# Hierarchy traversal
Psgc.hierarchy("1400101001")
# => {:code=>"1400101001", :barangay=>{...}, :city_municipality=>{...}, :province=>{...}, :region=>{...}}

# Search across all levels
Psgc.search("cebu")
# => {:regions=>[...], :provinces=>[...], :cities_municipalities=>[...], :barangays=>[...]}

Psgc.search("san", limit: 5)
# => {:regions=>[...], :provinces=>[...], :cities_municipalities=>[...], :barangays=>[...]}
#   (each level capped at 5 results)

# Validate PSGC code
Psgc.valid?("1400101001")  # => true
Psgc.valid?("9999999999") # => false

# Statistics
Psgc.stats
# => {:regions=>Integer, :provinces=>Integer, :cities_municipalities=>Integer, :barangays=>Integer}

# Export data
Psgc.export_csv(level: :regions)
Psgc.export_csv(level: :provinces)
Psgc.export_csv(level: :cities_municipalities)  # or :cities
Psgc.export_csv(level: :barangays)

Psgc.export_yaml(level: :regions)
Psgc.export_geojson(level: :regions)
```

## CLI

```bash
# Find by name
psgc find Manila
psgc find Cebu --limit 10

# Show hierarchy
psgc hierarchy 1400101001

# Validate code
psgc valid 1400101001

# Statistics
psgc stats

# Export data
psgc export --csv
psgc export --csv --level=provinces
psgc export --yaml --level=barangays
psgc export --geojson --level=cities
```

## Rails Generator

Generate seed data for your Rails app (requires Rails >= 6.1):

```bash
rails generate psgc:seed
rails generate psgc:seed --level=provinces
rails generate psgc:seed --level=cities
rails generate psgc:seed --level=barangays
rails generate psgc:seed --region-model=Region --province-model=Province --city-model=City --barangay-model=Barangay
```

Valid levels: `all` (default), `regions`, `provinces`, `cities` or `cities_municipalities`, `barangays`.

## Data Source

Data is sourced from the PSA PSGC Publication Datafile, released quarterly.
- URL: https://psa.gov.ph/classification/psgc/
- Current data: 1Q 2026

To update data:
1. Download the latest Excel file from PSA
2. Run `rake "data:parse[path/to/file.xlsx]"`
3. Commit the updated JSON files

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for data update instructions.

## License

Released under the [MIT License](./LICENSE).
