require_relative '../spec_helper.rb'
RSpec.describe Gitbase do
  before do
    allow_any_instance_of(BlissLogger).to receive(:log_to_papertrail).and_return(true)
  end

  before(:all) do
    @testdir = "#{Dir.pwd}/spec/fixtures/projs"
    @jsdir = "#{@testdir}/js"
    @pythondir = "#{@testdir}/python"
    @javadir = "#{@testdir}/java"
    @rubydir = "#{@testdir}/ruby"
    @phpdir = "#{@testdir}/php"
    @iosdir = "#{@testdir}/ios"
    @minjsdir = "#{@testdir}/minjs"
    @osdir = "#{@testdir}/osproj"
    @ostestdir = "#{@testdir}/ostest"
    `git clone https://github.com/OwlCarousel2/OwlCarousel2.git #{@osdir}`
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

    it 'removes config from ruby projs' do
      excluded_dirs = 'public,vendor,bin,coverage,db,config'
      excluded_dirs = begin
                         excluded_dirs.split(',')
                       rescue
                         []
                       end
      expect(File.directory?("#{@rubydir}/config")).to be true
      including_class.new.remove_excluded_directories(excluded_dirs, @rubydir)
      expect(File.directory?("#{@rubydir}/config")).to be false
    end

    it 'Removes open source files from a project' do
      FileUtils.copy_file(Dir.glob("#{@osdir}/src/js/*.js").first, "#{@osdir}/src/js/here is a file with spaces.js")
      file_count = Dir.glob("#{@osdir}/src/js/*.js").size
      expect do
        including_class.new.remove_open_source_files(@osdir)
      end.to change { Dir.glob("#{@osdir}/src/js/*.js").size }.from(file_count).to(0)
    end

    it 'Removes open source files from a project when a license is found' do
      file_count = Dir.glob("#{@ostestdir}/**/*.*").size
      expect do
        including_class.new.remove_open_source_files(@ostestdir)
      end.to change { Dir.glob("#{@ostestdir}/**/*.*").size }.from(file_count).to(1)
    end

    it 'Removes min.js files' do
      expect do
        including_class.new.remove_open_source_files(@minjsdir)
      end.to change { Dir.glob("#{@minjsdir}/**/*.js").size }.from(1).to(0)
    end
  end
end
