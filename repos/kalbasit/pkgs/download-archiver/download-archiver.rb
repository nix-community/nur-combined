#! @ruby_bin@
#
# Copyright (c) 2014-2017 Wael Nasreddine <wael.nasreddine@gmail.com>
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
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

require 'fileutils'
require 'digest/md5'

class DownloadArchiver

	attr_reader :files
	attr_reader :md5_to_files

	def initialize(dir)
		@base_dir = dir
		_scan_for_files
		_hash_files
	end

	def remove_duplicates
		@md5_to_files.each_value do |v|
			if v.size > 1
				for i in 1..v.size - 1
					@removed_files ||= Array.new
					@removed_files << v[i]
					FileUtils.rm v[i]
				end
			end
		end
		puts "#{@removed_files.size} files were removed" if @removed_files && @removed_files.size > 0
		@md5_to_files.clear
		# Re-scan the folder to update the internal list of files.
		# TODO: remove manually from self to speed it up
		_scan_for_files
	end

	def archive
		_archive_files_by_date
	end

	private

	def _scan_for_files
		@files = Array.new
		@md5_to_files = Hash.new
		Dir.glob(@base_dir + File::Separator +  '*').each do |f|
			if !File.directory? f
				@files << f
			end
		end
	end

	def _hash_files
		@files.each do |f|
			digest = Digest::MD5.hexdigest(File.read f)
			@md5_to_files[digest] ||= Array.new
			@md5_to_files[digest] << f
		end
	end

	def _archive_files_by_date
		# Register today's date
		today = Time.new()

		@files.each do |f|
			fh = File.new(f)
			if !File.directory?(f) && (fh.mtime.year != today.year || fh.mtime.month != today.month)
				f_year_path = @base_dir + File::Separator + fh.mtime.year.to_s
				f_month_path = f_year_path + File::Separator + fh.mtime.month.to_s

				FileUtils.mkdir f_year_path if !File::exists?(f_year_path) || !File.directory?(f_year_path)
				FileUtils.mkdir f_month_path if !File::exists?(f_month_path) || !File.directory?(f_month_path)

				FileUtils.mv(f, f_month_path + File::Separator + File.basename(f))
			end
		end
	end

end

# Register the base downloads path
downloads_path = ENV['HOME'] + '/Downloads'

da = DownloadArchiver.new(downloads_path)
da.remove_duplicates
da.archive
