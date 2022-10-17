class PokemonBag
	def add(item, qty = 1)
		item_data = GameData::Item.try_get(item)
		return false if !item_data
		pocket = item_data.pocket
		max_size = max_pocket_size(pocket)
		max_size = @pockets[pocket].length + 1 if max_size < 0   # Infinite size
		ret = ItemStorageHelper.add(@pockets[pocket],
                                max_size, Settings::BAG_MAX_PER_SLOT, item_data.id, qty)
		if ret && Settings::BAG_POCKET_AUTO_SORT[pocket - 1]
			@pockets[pocket].sort! { |a, b| GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name }
		end
		return ret
	end
end