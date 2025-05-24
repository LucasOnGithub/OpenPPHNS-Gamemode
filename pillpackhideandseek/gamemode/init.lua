
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


AddCSLuaFile("round/cl_round.lua")
AddCSLuaFile("round/circleavatar.lua")
include("round/sv_round.lua")

include("shared.lua")

function GM:PlayerConnect(name, ip)

    print("Player "..name.." connected with IP ("..ip..")")

end

function GM:PlayerInitialSpawn(ply)

    print("Player "..ply:Name().." has spawned")

end

if string.lower(game.GetMap()) == "contagion_estates" or string.lower(game.GetMap()) == "gm_backrooms" then

resource.AddWorkshop( 3005573843 )

elseif string.lower(game.GetMap()) == "rp_fazbears_fright_night" then

resource.AddWorkshop( 2760638604 )

elseif string.lower(game.GetMap()) == "zs_laurelmall" then

resource.AddWorkshop( 3158214363 )

elseif string.lower(game.GetMap()) == "gm_cabin_in_the_woods" then

resource.AddWorkshop( 3340858553 )

elseif string.lower(game.GetMap()) == "gm_silent_apartments" then

resource.AddWorkshop( 3362335449 )

elseif string.lower(game.GetMap()) == "hns_fazbears_forgotten" then

resource.AddWorkshop( 3316918408 )

elseif string.lower(game.GetMap()) == "cc_new_eden" then

resource.AddWorkshop( 2898535069 )

elseif string.lower(game.GetMap()) == "rp_downpour" then

resource.AddWorkshop( 2028415705 )

elseif string.lower(game.GetMap()) == "rp_fazbears_fright_night" then

resource.AddWorkshop( 2760638604 )

elseif string.lower(game.GetMap()) == "slender_forest" then

resource.AddWorkshop( 142020889 )

elseif string.lower(game.GetMap()) == "gm_viscera_sandbox" then

resource.AddWorkshop( 3175283309 )

elseif string.lower(game.GetMap()) == "rp_eastcoast_remaster" then

resource.AddWorkshop( 3273870020 )


elseif string.lower(game.GetMap()) == "slash_summercamp" then

resource.AddWorkshop( 787938932 )

elseif string.lower(game.GetMap()) == "sc_highschool" then

resource.AddWorkshop( 2844082996 )

elseif string.lower(game.GetMap()) == "rp_sorelane" then

resource.AddWorkshop( 3373875462 )

elseif string.lower(game.GetMap()) == "gm_fever_dream_2" then

resource.AddWorkshop( 3080942746 )

elseif string.lower(game.GetMap()) == "gm_liminal_hotel" then

resource.AddWorkshop( 2556466049 )

elseif string.lower(game.GetMap()) == "sc_asylum" then

resource.AddWorkshop( 2981462975 )

elseif string.lower(game.GetMap()) == "gm_abandonedmall_hd" then

resource.AddWorkshop( 3063216771 )

elseif string.lower(game.GetMap()) == "gm_nightlight" then

resource.AddWorkshop( 2973849259 )

elseif string.lower(game.GetMap()) == "ttt_alstoybarn" then

resource.AddWorkshop( 1829884863 )

elseif string.lower(game.GetMap()) == "gm_shambles" then

resource.AddWorkshop( 151544081 )

elseif string.lower(game.GetMap()) == "rp_sheep_v3" then

resource.AddWorkshop( 1158496801 )
resource.AddWorkshop( 1158491134 )

elseif string.lower(game.GetMap()) == "gm_golden_park_v2" then

resource.AddWorkshop( 2906232048 )

elseif string.lower(game.GetMap()) == "gm_mallparking" then

resource.AddWorkshop( 2619660952 )

elseif string.lower(game.GetMap()) == "gm_magna_vitae" then

resource.AddWorkshop( 3219257394 )

elseif string.lower(game.GetMap()) == "rp_redforest" then

resource.AddWorkshop( 1801953390 )

elseif string.lower(game.GetMap()) == "gm_cyan_dreampools" then

resource.AddWorkshop( 3222604668 )

elseif string.lower(game.GetMap()) == "gm_underground_parking" then

resource.AddWorkshop( 2159885749 )

elseif string.lower(game.GetMap()) == "rp_deadcity" then

resource.AddWorkshop( 1864156937 )

elseif string.lower(game.GetMap()) == "gm_stormwald" then

resource.AddWorkshop( 2983690708 )

elseif string.lower(game.GetMap()) == "gm_hoodcorner_extended" then

resource.AddWorkshop( 3016061508 )

elseif string.lower(game.GetMap()) == "gm_neverlosehopehospital_complete_tweaked" then//2

resource.AddWorkshop( 3308405109 )

elseif string.lower(game.GetMap()) == "gm_macmillanestates" then

resource.AddWorkshop( 2128911338 )

elseif string.lower(game.GetMap()) == "gm_northbury" then

resource.AddWorkshop( 3251774364 )

elseif string.lower(game.GetMap()) == "rp_yantar" then

resource.AddWorkshop( 1858789063 )

elseif string.lower(game.GetMap()) == "rp_clocktowerdawn" then

resource.AddWorkshop( 2833160254 )

elseif string.lower(game.GetMap()) == "rp_unioncity" then

resource.AddWorkshop( 1656078410 )

elseif string.lower(game.GetMap()) == "gm_port_trajan" then

resource.AddWorkshop( 3239363152 )

elseif string.lower(game.GetMap()) == "gm_oxidation" then

resource.AddWorkshop( 3020385572 )




end


if string.lower(game.GetMap()) == "gm_vacant_industry" then
resource.AddWorkshop("2985579279")

elseif string.lower(game.GetMap()) == "gm_subterranean_complex" then
resource.AddWorkshop("2979380011")
elseif string.lower(game.GetMap()) == "gm_facade" then
resource.AddWorkshop("3302364964")
elseif string.lower(game.GetMap()) == "gm_descent" then
resource.AddWorkshop("3055424196")
elseif string.lower(game.GetMap()) == "hns_deadcity" then

resource.AddWorkshop("3314078527")
elseif string.lower(game.GetMap()) == "hns_neverlosehopehospital_complete_v2" then
resource.AddWorkshop("3341827675")
elseif string.lower(game.GetMap()) == "hns_oxidation" then
resource.AddWorkshop("3318975051")
elseif string.lower(game.GetMap()) == "hns_necro_forest_revamped" then
resource.AddWorkshop("3318255292")
elseif string.lower(game.GetMap()) == "hns_redforest" then
resource.AddWorkshop("3344561703")
elseif string.lower(game.GetMap()) == "hns_stormwald" then
resource.AddWorkshop("3356271076")
end


resource.AddWorkshop( 2947598424 )
resource.AddWorkshop( 2155366756 )

resource.AddWorkshop( 3483371038 ) -- open pphns content pack 1

local enabled = true
local onground = true


local function CheckAndRemoveRagdoll( ply ) -- Remove the player's ragdoll when they respawn or disconnect
	//if IsValid( ply.Ragdoll ) then ply.Ragdoll:Remove() end
end

local function SetEntityStuff( ent1, ent2 ) -- Transfer most of the set things on entity 2 to entity 1
	if !IsValid( ent1 ) or !IsValid( ent2 ) then return false end
	ent1:SetModel( ent2:GetModel() )
	ent1:SetPos( ent2:GetPos() )
	ent1:SetAngles( ent2:GetAngles() )
	ent1:SetColor( ent2:GetColor() )
	ent1:SetSkin( ent2:GetSkin() )
	ent1:SetFlexScale( ent2:GetFlexScale() )
	for i = 0, ent2:GetNumBodyGroups() - 1 do ent1:SetBodygroup( i, ent2:GetBodygroup( i ) ) end
	for i = 0, ent2:GetFlexNum() - 1 do ent1:SetFlexWeight( i, ent2:GetFlexWeight( i ) ) end
	for i = 0, ent2:GetBoneCount() do
		ent1:ManipulateBoneScale( i, ent2:GetManipulateBoneScale( i ) )
		ent1:ManipulateBoneAngles( i, ent2:GetManipulateBoneAngles( i ) )
		ent1:ManipulateBonePosition( i, ent2:GetManipulateBonePosition( i ) )
		ent1:ManipulateBoneJiggle( i, ent2:GetManipulateBoneJiggle( i ) )
	end
end

local function TransferBones( base, ragdoll ) -- Transfers the bones of one entity to a ragdoll's physics bones (modified version of some of RobotBoy655's code)
	if !IsValid( base ) or !IsValid( ragdoll ) then return end
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum( i )
		if ( IsValid( bone ) ) then
			local pos, ang = base:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )
			if ( pos ) then bone:SetPos( pos ) end
			if ( ang ) then bone:SetAngles( ang ) end
		end
	end
end


hook.Add( 'PlayerDeath', 'DeathAnimation', function( victim, inflictor, attacker )


//2

end )


hook.Add( 'PlayerDeathThink', 'DeathAnimationThink', function( ply )
	if enabled then -- Don't do anything if the convar is not enabled
		if !ply.LetRespawn then return false end -- Don't let the player respawn yet
	end
end )


hook.Add( 'PlayerDisconnected', 'DeathAnimationRemoveRagdoll', CheckAndRemoveRagdoll )
