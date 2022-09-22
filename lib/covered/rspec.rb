# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'config'
require 'rspec/core/formatters'

$covered = Covered::Config.load

module Covered
	module RSpec
		module Policy
			def load_spec_files
				$stderr.puts "load_spec_files"
				$covered.enable
				
				super
			end
			
			def covered
				$covered
			end
			
			def covered= policy
				$covered = policy
			end
		end
	end
end

if $covered.record?
	RSpec::Core::Configuration.prepend(Covered::RSpec::Policy)

	RSpec.configure do |config|
		config.after(:suite) do
			$covered.disable
			$covered.call(config.output_stream)
		end
	end
end
