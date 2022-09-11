#==============================================================================
# Config
# LA Move Relearner base by IndianAnimator script by Kotaro
module Settings
  EGGMOVESSWITCH  = 60
  TMMOVESSWITCH   = 61
end
EGGMOVES = false
TMMOVES = false
#==============================================================================
class MoveRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def self.pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
      moves.push(m[1]) if !moves.include?(m[1])
    end
    if Settings::MOVE_RELEARNER_CAN_TEACH_MORE_MOVES && pkmn.first_moves
      tmoves = []
      pkmn.first_moves.each do |i|
        tmoves.push(i) if !moves.include?(i) && !pkmn.hasMove?(i)
      end
      species = pkmn.species
      species_data = GameData::Species.get(species)
      if $game_switches[Settings::EGGMOVESSWITCH] || EGGMOVES == true
        babyspecies = species_data.get_baby_species
        GameData::Species.get(babyspecies).egg_moves.each { |m| moves.push(m) }
      end
      if $game_switches[Settings::TMMOVESSWITCH] || TMMOVES==true
        species_data.tutor_moves.each { |m| moves.push(m) }
      end
      moves = tmoves + moves
      moves = tmoves + moves   # List first moves before level-up moves
    end
    return moves | []   # remove duplicates
  end

  def pbStartScreen(pkmn)
    moves = MoveRelearnerScreen.pbGetRelearnableMoves(pkmn)
    @scene.pbStartScene(pkmn, moves)
    loop do
      move = @scene.pbChooseMove
      if move
        if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
          if pbLearnMove(pkmn, move)
            $stats.moves_taught_by_reminder += 1
            @scene.pbEndScene
            return true
          end
        end
      elsif @scene.pbConfirm(_INTL("Give up trying to teach a new move to {1}?", pkmn.name))
        @scene.pbEndScene
        return false
      end
    end
  end
end

MenuHandlers.add(:party_menu, :relearn, {
  "name"      => _INTL("Relearn"),
  "order"     => 21,
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    if MoveRelearnerScreen.pbGetRelearnableMoves(pkmn).empty?
      pbDisplay(_INTL("This Pokémon doesn't have any moves to remember yet."))
    else
      pbRelearnMoveScreen(pkmn)
    end
  }
})
