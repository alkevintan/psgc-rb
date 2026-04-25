# frozen_string_literal: true

require "optparse"

module Psgc
  class CLI
    COMMANDS = %w[find hierarchy valid stats export help].freeze

    def self.run(argv = ARGV)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv.dup
      @options = {}
      @success = false
    end

    def run
      return help if @argv.empty?

      parse_options

      unless @command && COMMANDS.include?(@command)
        $stderr.puts "Error: unknown command '#{@command}'"
        return false
      end

      send(@command)
      @success
    end

    private

    def parse_options
      @options[:limit] = 20
      @options[:export_format] = :csv
      @options[:export_level] = :regions

      begin
        OptionParser.new do |opts|
          opts.on("-h", "--help") { @options[:help] = true }
          opts.on("--version") { @options[:version] = true }
          opts.on("--limit=N", Integer) { |n| @options[:limit] = n }
          opts.on("--csv") { @options[:export_format] = :csv }
          opts.on("--yaml") { @options[:export_format] = :yaml }
          opts.on("--geojson") { @options[:export_format] = :geojson }
          opts.on("--level=L") { |l| @options[:export_level] = l.to_sym }
        end.parse!(@argv)
      rescue OptionParser::InvalidOption => e
        $stderr.puts "Error: #{e.message}"
        @command = nil
        return
      end

      @command = @argv.shift
      @command ||= "help"
    end

    def find
      return help if @options[:help]
      return version if @options[:version]
      return help_find if @argv.empty?

      query = @argv.join(" ")
      results = Psgc.search(query, limit: @options[:limit])

      has_results = false
      [:regions, :provinces, :cities_municipalities, :barangays].each do |level|
        items = results[level]
        next unless items && !items.empty?

        has_results = true
        puts "=== #{level.to_s.tr('_', ' ').capitalize} (#{items.length}) ==="
        items.each do |item|
          puts "  #{item[:code]} #{item[:name]}"
        end
      end

      @success = has_results
      help_find unless has_results
    end

    def help_find
      puts "Usage: psgc find <query> [options]"
      puts "  Fuzzy search across all geographic levels."
      puts "  --limit=N    Limit results per level (default: 20)"
      puts ""
      puts "Examples:"
      puts "  psgc find Manila"
      puts "  psgc find Cebu --limit 10"
      @success = false
    end

    def hierarchy
      return help if @options[:help]
      return version if @options[:version]
      return help_hierarchy if @argv.empty?

      code = @argv.first
      unless code && code.match?(/^\d{10}$/)
        $stderr.puts "Error: code must be exactly 10 digits"
        @success = false
        return
      end

      result = Psgc.hierarchy(code)
      return help_hierarchy("Invalid code") unless result && result.any? { |k, v| k != :code && v }

      puts "Code: #{result[:code]}"

      if result[:region]
        puts "Region: #{result[:region][:code]} #{result[:region][:name]}"
      end
      if result[:province]
        puts "Province: #{result[:province][:code]} #{result[:province][:name]}"
      end
      if result[:city_municipality]
        puts "City/Municipality: #{result[:city_municipality][:code]} #{result[:city_municipality][:name]}"
      end
      if result[:barangay]
        puts "Barangay: #{result[:barangay][:code]} #{result[:barangay][:name]}"
      end

      @success = true
    end

    def help_hierarchy(msg = nil)
      puts "Usage: psgc hierarchy <code>"
      puts "  Show full hierarchy for a PSGC code."
      puts ""
      puts "Examples:"
      puts "  psgc hierarchy 1378040012"
      puts "  psgc hierarchy 1400000000"
      $stderr.puts msg if msg
      @success = false
    end

    def valid
      return help if @options[:help]
      return version if @options[:version]
      return help_valid if @argv.empty?

      code = @argv.first
      valid = Psgc.valid?(code)

      if valid
        puts "Valid PSGC code: #{code}"
      else
        puts "Invalid PSGC code: #{code}"
      end
      @success = valid
    end

    def help_valid
      puts "Usage: psgc valid <code>"
      puts "  Check if PSGC code exists."
      puts ""
      puts "Examples:"
      puts "  psgc valid 1378040012"
      puts "  psgc valid 9999999999"
      @success = false
    end

    def stats
      return help if @options[:help]
      return version if @options[:version]

      result = Psgc.stats
      printf "%-22s %d\n", "Regions:", result[:regions]
      printf "%-22s %d\n", "Provinces:", result[:provinces]
      printf "%-22s %d\n", "Cities/Municipalities:", result[:cities_municipalities]
      printf "%-22s %d\n", "Barangays:", result[:barangays]

      @success = true
    end

    def export
      return help if @options[:help]
      return version if @options[:version]

      format = @options[:export_format]
      level = @options[:export_level]

      begin
        case format
        when :csv
          puts Psgc.export_csv(level: level)
        when :yaml
          puts Psgc.export_yaml(level: level)
        when :geojson
          puts Psgc.export_geojson(level: level)
        end
      rescue ArgumentError => e
        $stderr.puts "Error: #{e.message}"
        @success = false
        return
      end

      @success = true
    end

    def help
      puts "Usage: psgc <command> [options]"
      puts ""
      puts "Commands:"
      puts "  find <query>       Fuzzy search across all geographic levels"
      puts "  hierarchy <code>   Show full hierarchy for a PSGC code"
      puts "  valid <code>       Check if PSGC code exists"
      puts "  stats              Show statistics"
      puts "  export             Export data in various formats (CSV, YAML, GeoJSON)"
      puts ""
      puts "Run 'psgc <command> --help' for more details."
      @success = true
    end

    def version
      puts "psgc-rb #{Psgc::VERSION}"
      @success = true
    end
  end
end