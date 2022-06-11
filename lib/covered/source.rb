# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'wrapper'

require 'thread'
require 'parser/current'

module Covered
	# The source map, loads the source file, parses the AST to generate which lines contain executable code.
	class Source < Wrapper
		def initialize(output)
			super(output)
			
			@paths = {}
			@mutex = Mutex.new
			
			@annotations = {}
			
			begin
				@trace = TracePoint.new(:script_compiled) do |trace|
					instruction_sequence = trace.instruction_sequence

					# We only track source files which begin at line 1, as these represent whole files instead of monkey patches.
					if instruction_sequence.first_lineno <= 1
						# Extract the source path and source itself and save it for later:
						if path = instruction_sequence.path and source = trace.eval_script
							@mutex.synchronize do
								@paths[path] = source
							end
						end
					end
				end
			rescue
				warn "Script coverage disabled: #{$!}"
				@trace = nil
			end
		end
		
		def enable
			super
			
			@trace&.enable
		end
		
		def disable
			@trace&.disable
			
			super
		end
		
		attr :paths
		
		def executable?(node)
			node.type == :send
		end
		
		def ignore?(node)
			node.nil? or node.type == :arg
		end
		
		def expand(node, coverage, level = 0)
			if node.is_a? Parser::AST::Node
				if ignore?(node)
					# coverage.annotate(node.location.line, "ignoring #{node.type}")
				else
					if executable?(node)
						# coverage.annotate(node.location.line, "executable #{node.type}")
						coverage.counts[node.location.line] ||= 0
					elsif node.location
						# coverage.annotate(node.location.line, "not executable #{node.type}") rescue nil
					end
					
					if node.type == :send
						# coverage.annotate(node.location.line, "ignoring #{node.type} children")
					end
					
					expand(node.children, coverage, level + 1)
				end
			elsif node.is_a? Array
				node.each do |child|
					expand(child, coverage, level)
				end
			else
				return false
			end
		end
		
		def parse(path)
			if source = @paths[path]
				Parser::CurrentRuby.parse(source)
			elsif File.exist?(path)
				Parser::CurrentRuby.parse_file(path)
			else
				warn "Couldn't parse #{path}, file doesn't exist?"
			end
		rescue
			warn "Couldn't parse #{path}: #{$!}"
		end
		
		def each(&block)
			@output.each do |coverage|
				if top = parse(coverage.path)
					self.expand(top, coverage)
				end
				
				yield coverage.freeze
			end
		end
	end
end
