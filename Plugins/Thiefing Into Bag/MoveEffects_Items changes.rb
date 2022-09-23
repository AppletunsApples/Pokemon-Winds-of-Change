#===============================================================================
# Stolen Item Icons
#===============================================================================
=begin
it'd probably be simpler to use the ItemIconSprite class rather than manually looking up the graphic. (it'd also account for animated item sprites)
(also, that self.try_get is going to throw you an error - you want cc if you're not working in the GameData modue)
=end

    def Sprite(item)
      return "Graphics/Items/%s" if item.nil?
      item_data = GameData::Item.try_get(item)
      return "Graphics/Items/000" if item_data.nil?
      # Check for files
      ret = sprintf("Graphics/Items/%s", item_data.id)
      return ret if pbResolveBitmap(ret)
    end

#===============================================================================
# Thief and Covet update.
#===============================================================================
class Battle::Move::UserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && target.item == target.initialItem
      $bag.add(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbMessage(_INTL("{1} stole {2}'s item <icon = {3}> {4} and sent it to {5}'s bag.", user.pbThis, target.pbThis(true), user.item_id, itemName, $Trainer.name, $Trainer.name{4}))
    user.pbHeldItemTriggerCheck
  end.name
end
