# Psgc

A Ruby gem providing up-to-date Philippine geographic data from the PSA (Philippine Statistics Authority). Includes Philippine Standard Geographic Codes (PSGC) for regions, provinces, cities/municipalities, and barangays.

## Installation

```bash
gem install psgc-rb
```

Or add to Gemfile:

```ruby
gem "psgc-rb"
```

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
```

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

## License

The gem is available as open source under the terms of the MIT License.