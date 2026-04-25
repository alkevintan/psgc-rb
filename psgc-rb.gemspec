# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "psgc-rb"
  spec.version = "0.1.0"
  spec.authors = ["Al Kevin Tan"]
  spec.email = ["alkevintan@gmail.com"]

  spec.summary = "Philippine Standard Geographic Codes (PSGC) - Regions, Provinces, Cities, Municipalities, Barangays"
  spec.description = "A Ruby gem providing up-to-date Philippine geographic data from the PSA. Includes all regions, provinces, cities, municipalities, and barangays with PSGC codes."
  spec.homepage = "https://github.com/alkevintan/psgc-rb"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.add_dependency "csv", ">= 2.0.0"
  spec.add_dependency "psych", ">= 4.0.0"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files = spec.files.grep(%r{\Atest/}) { |f| f }
end
