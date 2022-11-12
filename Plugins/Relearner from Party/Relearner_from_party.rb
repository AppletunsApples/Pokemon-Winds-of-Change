#==============================================================================
# Config
# Move Relearner Script by Marin
module Settings
  EGGMOVESSWITCH  = 59
end
EGGMOVES = false
#==============================================================================

class Pokemon
  attr_writer :unlocked_relearner
  
  def unlocked_relearner
    return @unlocked_relearner ||= false
  end
end

MenuHandlers.add(:party_menu, :relearner, {
  "name"      => _INTL("Move Relearner"),
  "order"     => 65,
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    if pkmn.egg?
      pbMessage(_INTL("You can't use the Move Relearner on an egg."))
    elsif pkmn.shadowPokemon?
      pbMessage(_INTL("You can't use the Move Relearner on a shadow Pokémon."))
    elsif pkmn.unlocked_relearner
      if !pkmn.can_relearn_move?
        pbMessage(_INTL("This Pokémon has no moves to relearn."))
      else
        pbRelearnMoveScreen(party[party_idx])
      end
    else
      if $bag.has?(:HEARTSCALE)
        yes = pbConfirmMessage(
            _INTL("Would you like to unlock the Move Relearner for this Pokémon for 1 Heart Scale?"))
        if yes
          pkmn.unlocked_relearner = true
          $bag.remove(:HEARTSCALE)
          pbMessage(_INTL("You can now use the Move Relearner for this Pokémon."))
          pbRelearnMoveScreen(party[party_idx])
        end
      else
        pbMessage(_INTL("You can unlock the Move Relearner for this Pokémon for 1 Heart Scale."))
      end
    end
  }
})

class MoveRelearnerScreen
  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
      moves.push(m[1]) if !moves.include?(m[1])
    end
    GameData::Species.get(pkmn.species).get_egg_moves.each do |m|
      next if pkmn.hasMove?(m)
      moves.push(m)
    end
    if $game_switches[Settings::EGGMOVESSWITCH] && pkmn.first_moves || EGGMOVES==true && pkmn.first_moves
      tmoves = []
      pkmn.first_moves.each do |i|
        tmoves.push(i) if !moves.include?(i) && !pkmn.hasMove?(i)
      end
      moves = tmoves + moves   # List first moves before level-up moves
    end
    return moves | []   # remove duplicates
  end
end