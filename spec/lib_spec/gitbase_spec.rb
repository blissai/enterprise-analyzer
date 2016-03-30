require_relative '../spec_helper.rb'
RSpec.describe Gitbase do
  before(:all) do
    @testdir = "#{Dir.pwd}/spec/fixtures/projs"
    @jsdir = "#{@testdir}/js"
    @pythondir = "#{@testdir}/python"
    @javadir = "#{@testdir}/java"
    @rubydir = "#{@testdir}/ruby"
    @phpdir = "#{@testdir}/php"
    @iosdir = "#{@testdir}/ios"
    @osdir = "#{Dir.pwd}/spec/fixtures/projs/osproj"
    `git clone https://github.com/OwlCarousel2/OwlCarousel2.git #{@osdir}`

    FileUtils.mkdir_p("#{@iosdir}/Pods")
    FileUtils.mkdir_p("#{@iosdir}/Frameworks")
    File.open("#{@iosdir}/Pods/test.txt", 'w+') { |file| file.write('A pod.') }
    File.open("#{@iosdir}/Frameworks/test.txt", 'w+') { |file| file.write('A framework.') }

    FileUtils.mkdir_p("#{@iosdir}/Nested/Pods")
    FileUtils.mkdir_p("#{@iosdir}/Nested/Frameworks")
    File.open("#{@iosdir}/Nested/Pods/test.txt", 'w+') { |file| file.write('A pod.') }
    File.open("#{@iosdir}/Nested/Frameworks/test.txt", 'w+') { |file| file.write('A framework.') }
  end

  after(:all) do
    FileUtils.rm_rf(@osdir)
  end

  let(:including_class) { Class.new { include Gitbase } }

  context 'given some projects' do
    it 'determines the language of a javascript project' do
      langs = including_class.new.sense_project_type(@jsdir)
      expect(langs).to include('nodejs')
    end

    it 'determines the language of a python project' do
      langs = including_class.new.sense_project_type(@pythondir)
      expect(langs).to include('Python')
    end

    it 'determines the language of a java project' do
      langs = including_class.new.sense_project_type(@javadir)
      expect(langs).to include('Java')
    end

    it 'determines the language of a ruby project' do
      langs = including_class.new.sense_project_type(@rubydir)
      expect(langs).to include('ruby')
    end

    it 'determines the language of a php project' do
      langs = including_class.new.sense_project_type(@phpdir)
      expect(langs).to include('php')
    end

    it 'determines the language of a ios project' do
      langs = including_class.new.sense_project_type(@iosdir)
      expect(langs).to include('Objective-C')
      expect(langs).to include('ios')
    end

    it 'removes Pods and Frameworks from iOS projects' do
      including_class.new.remove_excluded_directories(%w(Pods Frameworks), @iosdir)
      expect(File.directory?("#{@iosdir}/Pods")).to be false
      expect(File.directory?("#{@iosdir}/Frameworks")).to be false
      expect(File.directory?("#{@iosdir}/Nested/Frameworks")).to be false
      expect(File.directory?("#{@iosdir}/Nested/Frameworks")).to be false
    end

    it 'Removes open source files from a project' do
      file_count = Dir.glob("#{@osdir}/src/js/*.js").size
      expect {
        including_class.new.remove_open_source_files(@osdir)
      }.to change { Dir.glob("#{@osdir}/src/js/*.js").size }.from(file_count).to(0)
    end
  end
end
