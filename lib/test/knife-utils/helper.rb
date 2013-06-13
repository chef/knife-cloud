require "securerandom"
require 'tmpdir'
require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/knife_test_utils')
require File.expand_path(File.dirname(__FILE__) + '/matchers')

module KnifeTestHelper
  extend RSpec::KnifeTestUtils
  def temp_dir
    @_temp_dir ||= Dir.mktmpdir
  end

  def match_status(test_run_expect)
    if "#{test_run_expect}" == "should fail"
      should_not have_outcome :status => 0
    elsif "#{test_run_expect}" == "should succeed"
      should have_outcome :status => 0
    elsif "#{test_run_expect}" == "should return empty list"
      should have_outcome :status => 0
    else
      should have_outcome :status => 0
    end
  end

  def match_stdout(test_run_expect)
    should have_outcome :stdout => test_run_expect
  end

  def create_file(file_dir, file_name, data_to_write_file_path)
    puts "Creating: #{file_name}"
    begin
      data_to_write = File.read(File.expand_path("#{data_to_write_file_path}", __FILE__))
      File.open("#{file_dir}/#{file_name}", 'w') {|f| f.write(data_to_write)}
    rescue
      puts "Error while creating file - #{file_name}"
    end
  end
  
end
