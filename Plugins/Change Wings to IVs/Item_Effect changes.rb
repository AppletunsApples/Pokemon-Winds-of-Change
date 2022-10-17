ItemHandlers::UseOnPokemonMaximum.add(:HEALTHFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:HP, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:HEALTHFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:HP, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:MUSCLEFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:MUSCLEFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:RESISTFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:RESISTFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:GENIUSFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:GENIUSFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:CLEVERFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:CLEVERFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:SWIFTFEATHER, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPEED, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:SWIFTFEATHER, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPEED, 1, qty, pkmn, "vitamin", scene)
})