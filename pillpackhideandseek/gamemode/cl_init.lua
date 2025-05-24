include("shared.lua")
include("round/cl_round.lua")
include("round/circleavatar.lua")


hook.Add( "SpawnMenuOpen", "SpawnMenuWhitelist", function()

		return false

end )

