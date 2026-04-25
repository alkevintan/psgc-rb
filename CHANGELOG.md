# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-04-25

### Added
- Finder methods (`find_region`, `find_province`, `find_city_municipality`, `find_barangay`) for looking up by code or name
- `hierarchy` method for traversing PSGC relationships (e.g., barangay → city → province → region)
- `search` method for fuzzy name matching across all geographic levels
- `valid?` method to check if a PSGC code exists
- `stats` method to get counts by geographic level
- CLI tool with `find`, `hierarchy`, `valid`, `stats`, and `export` commands
- Rails seed generator (`rails generate psgc:seed`)
- Export methods (`export_csv`, `export_yaml`, `export_geojson`)
- Support for `:cities` as alias for `:cities_municipalities` level

### Changed
- Default export level changed from `:barangays` to `:regions` for safer preview

## [0.1.0] - 2026-04-25

### Added
- Initial release with data loaders for PSGC regions, provinces, cities/municipalities, and barangays