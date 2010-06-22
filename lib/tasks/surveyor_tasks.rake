desc "generate and load survey (specify FILE=surveys/your_survey.rb)"
task :surveyor => :"surveyor:default"

namespace :surveyor do
  
  task :default => [:generate_fixtures, :load_fixtures]
  
  desc "generate survey fixtures from survey file (specify FIXTURES=surveys/your_survey.rb"
  task :generate_fixtures => :environment do
    require File.join(File.dirname(__FILE__), "../../script/surveyor/parser")
    raise "USAGE: file name required e.g. 'FILE=surveys/kitchen_sink_survey.rb'" if ENV["FILE"].blank?
    fixture_dir = File.join(RAILS_ROOT, "surveys", "fixtures")
    mkdir fixture_dir unless File.exists?(fixture_dir)
    SurveyParser::Parser.parse(File.join(RAILS_ROOT, ENV["FILE"]))
  end

  desc "load survey fixtures (optional FIXTURES=surveys/foo/fixtures)"
  task :load_fixtures => :environment do
    require 'active_record/fixtures'
    require 'fixtures_extensions' unless ENV["APPEND"].blank?
    ENV["FIXTURES"] ||= "surveys/fixtures"
    ActiveRecord::Base.establish_connection(Rails.env)

    fixture_dir = File.join(RAILS_ROOT, ENV["FIXTURES"])
    fixtures = Dir.glob("#{fixture_dir}/*.yml")
    raise "No fixtures found." if fixtures.empty?
    
    fixtures.each do |file_name|
      puts "Loading #{file_name}..."
      Fixtures.create_fixtures(fixture_dir, File.basename(file_name, '.*'))
    end
  end

end
