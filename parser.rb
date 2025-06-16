# frozen_string_literal: true

require 'optparse'
Options = Struct.new(:file, :write, :algo, :error)
VALID_ALGOS = [['phone'], ['email'], %w[email phone]].freeze
# Parses command line arguments
class Parser
  def self.parse(options)
    args = Options.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: ruby csv_matcher.rb -a phone,email -f file -w true'

      opts.on('-a', '--algo ALGO', 'algorithm separated by comma') do |algo|
        args.algo = algo.strip.split(',').sort
        unless VALID_ALGOS.include?(args.algo)
          args.error = 'Invalid Algo, must be email, phone, or both separated by a comma'
        end
      end

      opts.on('-f', '--file FILE', 'input file') do |f|
        args.file = f
      end

      opts.on('-w', '--write WRITE', 'write to disk') do |w|
        args.write = w.downcase == 'false' || true
      end
    end

    opt_parser.parse!(options)
    args
  end
end
