# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'covered/files'

describe Covered::Files do
	let(:files) {subject.new}
	
	with '#mark' do
		it "can mark lines" do
			files.mark("program.rb", 2, 1)
			
			expect(files.paths["program.rb"][2]).to be == 1
		end
		
		it "can mark the same line twice" do
			2.times do
				files.mark("program.rb", 2, 1)
			end
			
			expect(files.paths["program.rb"][2]).to be == 2
		end
	end
end

describe Covered::Filter do
	let(:filter) {subject.new}
	
	it "accepts everything" do
		expect(filter.accept?("foo")).to be == true
	end
end

describe Covered::Include do
	let(:files) {Covered::Files.new}
	let(:pattern) {File.join(__dir__, "**", "*.rb")}
	let(:include) {subject.new(files, pattern)}
	
	it "should match some files" do
		expect(include.glob).not.to be(:empty?)
	end
	
	let(:path) {include.glob.first}
	
	it "should defer to existing files" do
		include.mark(path, 5, 1)
		
		paths = include.to_h
		
		expect(paths).to have_keys(path)
		expect(paths[path].counts).to be == [nil, nil, nil, nil, nil, 1]
	end
	
	it "should enumerate paths" do
		enumerator = include.to_enum(:each)
		
		expect(enumerator.next).to be_a(Covered::Coverage)
	end
end

describe Covered::Skip do
	let(:files) {Covered::Files.new}
	let(:skip) {subject.new(files, /file.rb/)}
	
	it "should ignore files which match given pattern" do
		skip.mark("file.rb", 1, 1)
		
		expect(files).to be(:empty?)
	end
	
	it "should include files which don't match given pattern" do
		skip.mark("foo.rb", 1, 1)
		
		expect(files).not.to be(:empty?)
		expect(skip.to_h).to have_keys("foo.rb")
	end
end

describe Covered::Only do
	let(:files) {Covered::Files.new}
	let(:only) {subject.new(files, "file.rb")}
	
	it "should ignore files which don't match given pattern" do
		only.mark("foo.rb", 1, 1)
		
		expect(files).to be(:empty?)
	end
	
	it "should include files which match given pattern" do
		only.mark("file.rb", 1, 1)
		
		expect(files).not.to be(:empty?)
	end
end

describe Covered::Root do
	let(:files) {Covered::Files.new}
	let(:root) {subject.new(files, "lib/")}
	
	it "should ignore files which don't match root" do
		root.mark("foo.rb", 1, 1)
		
		expect(files).to be(:empty?)
	end
	
	it "should include files which match root" do
		root.mark("lib/foo.rb", 1, 1)
		
		expect(files).not.to be(:empty?)
	end
end
