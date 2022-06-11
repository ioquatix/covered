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

require 'covered/source'
require 'covered/summary'

require 'trenni/template'

RSpec.describe Covered::Source do
	let(:template_path) {File.expand_path("template.trenni", __dir__)}
	let(:template) {Trenni::Template.load_file(template_path)}
	
	let(:files) {Covered::Files.new}
	let(:only) {Covered::Only.new(template_path, files)}
	let(:source) {Covered::Source.new(files)}
	let(:capture) {Covered::Capture.new(source)}
	
	let(:summary) {Covered::Summary.new}
	
	it "correctly generates coverage for template" do
		capture.enable
		template.to_string
		capture.disable
		
		expect(source.paths.size).to be == 1
		expect(source.paths).to include(template_path)

		io = StringIO.new
		summary.call(source, io)
		
		expect(io.string).to include("2/3 lines executed; 66.67% covered")
	end
	
	it "can't parse non-existant path" do
		expect(source.parse("do_not_exist")).to be_nil
	end
end
