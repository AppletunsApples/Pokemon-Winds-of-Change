class AutoSave
	def auto
		$game_temp.menu_calling = false
    $game_temp.in_menu = true
    $game_player.straighten
    $game_map.update
		# It will store the last save file when you dont file save
		count = FileSave.count
		SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
		Game.save
		SaveData.changeFILEPATH(!$storenamefilesave.nil? ? $storenamefilesave : FileSave.name)
		$game_temp.in_menu = false
	end
end

def pbAutoSave = AutoSave.new.auto