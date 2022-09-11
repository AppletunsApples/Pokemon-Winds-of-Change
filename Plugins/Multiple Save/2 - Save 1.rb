#-------------------------#
# Set for module SaveData #
#-------------------------#
module SaveData
	def self.delete_file(file = FILE_PATH)
    File.delete(file)
    File.delete(file + '.bak') if File.file?(file + '.bak')
  end
	def self.move_old_windows_save
		FileSave.dir_new
		FileSave.dir_old
	end
	def self.changeFILEPATH(new = nil)
		return if new.nil?
		const_set(:FILE_PATH, new)
	end
end