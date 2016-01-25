require_relative '../spec_helper.rb'
RSpec.describe Gitbase do

  before(:all) do
    @testdir = "#{Dir.pwd}/spec/fixtures/projs"
    @jsdir = "#{@testdir}/js"
    @pythondir = "#{@testdir}/python"
    @javadir = "#{@testdir}/java"
    @rubydir = "#{@testdir}/ruby"
    @phpdir = "#{@testdir}/php"
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
  end
end
