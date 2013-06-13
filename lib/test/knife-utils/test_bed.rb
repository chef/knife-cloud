# Copyright: Copyright (c) 2012 Opscode, Inc.
# License: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author:: Ameya Varade (<ameya.varade@clogeny.com>)

require File.expand_path(File.dirname(__FILE__) + '/helper')

module KnifeTestBed
	include KnifeTestHelper
	def init_test
	  puts "\nCreating Test Data\n"
	  create_file("#{temp_dir}", "validation.pem", "../../fixtures/validation.pem" )
	  create_file("#{temp_dir}", "knife.rb", "../../fixtures/knife.rb")
	  create_file("#{temp_dir}", "chef-full-chef-zero.erb", "../../templates/chef-full-chef-zero.erb")
	  create_file("#{temp_dir}", "windows-chef-client-msi.erb", "../../templates/windows-chef-client-msi.erb")
	  create_file("#{temp_dir}", "windows-shell.erb", "../../templates/windows-shell.erb")
	end

	def cleanup_test_data
	  puts "\nCleaning Test Data\n"
	  FileUtils.rm_rf("#{temp_dir}")
	  puts "\nDone\n"
	end

	def get_knife_rb_path
		"#{temp_dir}/" + "knife.rb"
	end

	def get_validation_pem_path
		"#{temp_dir}/" + "validation.pem"
	end

	def get_linux_template_file_path
		"#{temp_dir}/" + "chef-full-chef-zero.erb"
	end

	def get_windows_msi_template_file_path
		"#{temp_dir}/" + "windows-chef-client-msi.erb"
	end

	def get_windows_shell_template_file_path
		"#{temp_dir}/" + "windows-shell.erb"
	end
end 