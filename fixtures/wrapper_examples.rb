# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'covered/wrapper'

WrapperExamples = Sus::Shared("a wrapper") do
	let(:output) {Covered::Base.new}
	let(:wrapper) {subject.new(output)}
	
	it 'passes #mark through' do
		expect(output).to receive(:mark).with("fleeb.rb", 5, 1)
		
		wrapper.mark("fleeb.rb", 5, 1)
	end
	
	it 'passes #start through' do
		expect(output).to receive(:start)
		
		wrapper.start
	end
	
	it 'passes #finish through' do
		expect(output).to receive(:finish)
		
		wrapper.finish
	end
	
	it 'passes #each through' do
		expect(output).to receive(:each)
		
		wrapper.each do
		end
	end
end
