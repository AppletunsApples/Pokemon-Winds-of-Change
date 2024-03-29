#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click F, #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#

# When the user clicks M, it'll pick the next number in this array.
SPEEDUP_STAGES = [1,2,3]

def pbAllowSpeedup
  $CanToggle = true
end

def pbDisallowSpeedup
  $CanToggle = false
end

# Default game speed.
$GameSpeed = 1

$frame = 0
$CanToggle = true
module Graphics
  class << Graphics
    alias fast_forward_update update
  end
  
  def self.update
    if Input.trigger?(Input::AUX2) && $CanToggle# && Input.trigger?(Input::AUX2)
      
      $GameSpeed += 1
      
      $GameSpeed = 1 if $GameSpeed >= 4
    end
    $frame += 1
    return unless $frame % $GameSpeed == 0
    fast_forward_update
    $frame = 0
  end
end
