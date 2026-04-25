# frozen_string_literal: true

require "rails/generators/base"

module Psgc
  module Generators
    class SeedGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      VALID_LEVELS = %w[all regions provinces cities cities_municipalities barangays].freeze

      class_option :level,
        type: :string,
        default: "all",
        desc: "Geographic level: all, regions, provinces, cities/cities_municipalities, barangays"

      class_option :region_model,
        type: :string,
        default: "Region",
        desc: "Model name for regions"

      class_option :province_model,
        type: :string,
        default: "Province",
        desc: "Model name for provinces"

      class_option :city_model,
        type: :string,
        default: "City",
        desc: "Model name for cities/municipalities"

      class_option :barangay_model,
        type: :string,
        default: "Barangay",
        desc: "Model name for barangays"

      def create_seed_file
        validate_level!
        template "seed.rb.erb", "db/seeds.rb"
      end

      private

      def validate_level!
        return if VALID_LEVELS.include?(options[:level])

        raise ArgumentError, "Invalid level: #{options[:level]}. Valid: #{VALID_LEVELS.join(', ')}"
      end

      def level
        options[:level]
      end

      def region_model
        options[:region_model]
      end

      def province_model
        options[:province_model]
      end

      def city_model
        options[:city_model]
      end

      def barangay_model
        options[:barangay_model]
      end
    end
  end
end