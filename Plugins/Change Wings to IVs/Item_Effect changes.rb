ItemHandlers::UseOnPokemonMaximum.add(:HEALTHWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:HP, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:HEALTHWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:HP, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:MUSCLEWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:MUSCLEWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:RESISTWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:RESISTWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:GENIUSWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:GENIUSWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:CLEVERWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:CLEVERWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:SWIFTWING, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPEED, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:SWIFTWING, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPEED, 1, qty, pkmn, "vitamin", scene)
})