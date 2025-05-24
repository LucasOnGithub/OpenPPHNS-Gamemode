util.AddNetworkString("ResetRoundTimer")
util.AddNetworkString("StarChaseRound")
util.AddNetworkString("StarChaseRound2")
util.AddNetworkString("StarChaseRound3")
util.AddNetworkString("StarChaseRound4")
util.AddNetworkString("StarChaseRound5")
util.AddNetworkString("StarChaseRound6")
util.AddNetworkString("roundending")
util.AddNetworkString("preroundmusic")
util.AddNetworkString("joininround")
util.AddNetworkString("firstround")
util.AddNetworkString("OpenDonateUrl")
util.AddNetworkString("SendToServerDonate")
util.AddNetworkString("GhostMark")
util.AddNetworkString("GhostMark2")


resource.AddWorkshop("3440271589")
    


skybox = GetConVar("sv_skyname"):GetString()
oldskybox = skybox

    local DonatorGroups = {
        ["vip"] = true,
        ["vipplus"] = true,
        ["supporter"] = true,
    }

-- You can either use this avatar link function or the older one commented out below. Comment out this one if you want to use the older one.
function getAvatarLink(ply, callback)
    if not IsValid(ply) then callback(false) return end
    local avatarURL = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/" .. string.sub(ply:SteamID64(), -2) .. "/" .. ply:SteamID64() .. "_full.jpg"

    -- Since this URL pattern is unofficial, optional verification can happen if it exists
    http.Fetch(avatarURL,
        function(body, len, headers, code)
            if code == 200 then
                callback(avatarURL)
            else
                callback(false)
            end
        end,
        function(err)
            callback(false)
        end
    )
end

-- Older code kept for reference, may be needed for ashop initialization on your server.
-- function getAvatarLink(ply, callback)
--     http.Fetch("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&steamids=" .. ply:SteamID64() .. "&format=json", -- You must provide your own Steam API key. Do not share it with anyone.
--     function(body)
--         local response = util.JSONToTable(body).response
--         if istable(response) and response.players[1] then
--             local avatarLink = response.players[1].avatarfull
--             callback(avatarLink)
--         else
--             callback(false) -- Return false if no avatar found
--         end
--     end, 
--     function(error) 
--         callback(false) -- Return false if there's an error (e.g., Steam API down)
--     end)
-- end

local function RGBToHex(r, g, b)
    return (r * 65536) + (g * 256) + b
end

net.Receive( "SendToServerDonate", function()
    local ply = net.ReadEntity()
	net.Start("OpenDonateUrl")
	net.Send(ply)
end )


hook.Add( "PlayerFootstep", "DisableFootsteps", function( ply, pos, foot, sound, volume, rf )
	return true
end )

hook.Add("PlayerSpawnProp", "RestrictPropSpawn2", function(ply, model)
    if not ply:IsAdmin() then
        ply:ChatPrint("You are not allowed to spawn props!")
        return false
    end
end)

hook.Add("PlayerSpawnNPC", "RestrictNPCSpawn2", function(ply, npc_type)
    if not ply:IsAdmin() then
        ply:ChatPrint("You are not allowed to spawn NPCs!")
        return false
    end
end)

hook.Add("PlayerSpawnSENT", "RestrictSENTSpawn2", function(ply, class)
    if not ply:IsAdmin() then
        ply:ChatPrint("You are not allowed to spawn entities!")
        return false
    end
end)

hook.Add("PlayerSpawnSWEP", "RestrictSWEPSpawn2", function(ply, weapon_class)
    if not ply:IsAdmin() then
        ply:ChatPrint("You are not allowed to spawn weapons!")
        return false
    end
end)

concommand.Add("give", function(ply, cmd, args)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then
        ply:ChatPrint("You are not allowed to use the 'give' command!")
        return
    end

    local weapon = args[1]
    if weapon then
        ply:Give(weapon)
    end
end)

local function ragdollAttackerDissolver(dissolveType, ragdoll, attacker)
    local Dissolver = ents.Create( "env_entity_dissolver" )
    timer.Simple(5, function()
        if IsValid(Dissolver) then
            Dissolver:Remove() -- backup edict save on error
        end
    end)
    if IsValid(ragdoll) then
    Dissolver.Target = "dissolve"..ragdoll:EntIndex()
    Dissolver:SetKeyValue( "dissolvetype", dissolveType )
    Dissolver:SetKeyValue( "magnitude", 0 )
    Dissolver:SetPos( ragdoll:GetPos() )
    Dissolver:Spawn()

    ragdoll:SetName( Dissolver.Target )

    Dissolver:Fire( "Dissolve", Dissolver.Target, 0 )
    Dissolver:Fire( "Kill", "", 0.1 )
	end
end

function NV( ply )
    if ply:GetNWBool("NV") == true and ply:GetNWInt("badguy") == true then
	    ply:SetNWBool("NV", false)
	elseif ply:GetNWInt("badguy") == true then
	    ply:SetNWBool("NV", true)
	end
end
hook.Add("ShowSpare2", "NVToggle", NV)

-- Round states
local ROUND_WAITING = 0
local ROUND_PREPARING = 1
local ROUND_ACTIVE = 2
local ROUND_ENDING = 3
local function applyEffects(ply, vanny)
    ply:SetNWInt("badguy", true)
    if game.GetMap() == "sc_highschool" or game.GetMap() == "slender_forest" or game.GetMap() == "slash_summercamp" or GetGlobalString("RoundType") == "Twisted" then
        ply:SetNWBool("NV", true)
    end
	
    ply:SetNWBool("didspringlock", false) 
    ply:Freeze(true)
	table.insert(nextbots_tbl, ply)
	ply:SetTeam( 1 )
    ply:SetNoCollideWithTeammates( true )
    timer.Simple(0.1, function() ply:Freeze(true) end)
    timer.Simple(32, function() ply:Freeze(false) end)
	if vanny == true then
	     pk_pills.apply(ply, "pill_vanny")
		 
    elseif ply:GetPData("buyablepill") == nil or ply:GetPData("buyablepill") == "none" then
	    pk_pills.apply(ply, GetRandomPill())
	else

	    if GetGlobalString("RoundType") == "Everyone" then
            pk_pills.apply(ply, tostring(ply:GetPData("buyablepill")))
			
		else
	        pk_pills.apply(ply, GetRandomPill())
		end
		
	end
end

function forcepill(steamid, pill)

   for _, ply in ipairs(player.GetAll()) do
        if ply:SteamID() == steamid then
	        ply:SetNWInt("badguy", true)
        	table.insert(nextbots_tbl, ply)
        	ply:SetTeam( 1 )
            ply:SetNoCollideWithTeammates( true )
	        pk_pills.apply(ply, pill)
			    ply:SetRunSpeed( 560 ) 
			    ply:SetMaxSpeed( 560 ) 
			    ply:SetWalkSpeed( 200 )

	    end
   end
    
    
end
-- Round variables
local roundState = ROUND_WAITING
local roundStartTime = 0
local roundDuration = 600 -- 10 minutes in seconds

local pointInterval = 60 -- Points awarded every 60 seconds
local pointAmount = 20 -- Points awarded per interval

-- PLAYERS LEFT CODE
util.AddNetworkString("playerleftui")
util.AddNetworkString("playerleftui2")
function TestAvatar()

net.Start("playerleftui")
net.Broadcast()


end
function GetRoundState()
    return roundState
end
function GetPlayersWithBadguyNot3()
    local playersFiltered = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWInt("badguy") ~= true and ply:Team() ~= 1002 then
            table.insert(playersFiltered, ply)
        end
    end
    return playersFiltered
end


local function isEmpty(vector, ignore)
    ignore = ignore or {}

    local point = util.PointContents(vector)
    local a = point ~= CONTENTS_SOLID
        and point ~= CONTENTS_MOVEABLE
        and point ~= CONTENTS_LADDER
        and point ~= CONTENTS_PLAYERCLIP
        and point ~= CONTENTS_MONSTERCLIP
    if not a then return false end

    local b = true

    for _, v in ipairs(ents.FindInSphere(vector, 85)) do
        if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos) and not table.HasValue(ignore, v) then
            b = false
            break
        end
    end

    return a and b
end

function findEmptyPos(pos, ignore, distance, step, area)
    if isEmpty(pos, ignore) and isEmpty(pos + area, ignore) then
        return pos
    end

    for j = step, distance, step do
        for i = -1, 1, 2 do -- alternate in direction
            local k = j * i

            -- Look North/South
            if isEmpty(pos + Vector(k, 0, 0), ignore) and isEmpty(pos + Vector(k, 0, 0) + area, ignore) then
                return pos + Vector(k, 0, 0)
            end

            -- Look East/West
            if isEmpty(pos + Vector(0, k, 0), ignore) and isEmpty(pos + Vector(0, k, 0) + area, ignore) then
                return pos + Vector(0, k, 0)
            end

            -- Look Up/Down
            if isEmpty(pos + Vector(0, 0, k), ignore) and isEmpty(pos + Vector(0, 0, k) + area, ignore) then
                return pos + Vector(0, 0, k)
            end
        end
    end

    return pos
end


hook.Add( "PlayerShouldTakeDamage", "AntiTeamkill", function( ply, attacker )
	if not attacker:IsPlayer() then
	    return true
	
	elseif ply ~= attacker and  ply:GetNWInt("badguy") == true and attacker:GetNWInt("badguy") == true then
	
	

		    return false -- that will block damage if attacker and ply is on the same team.

	elseif ply ~= attacker and ply:GetNWInt("badguy") ~= true and attacker:GetNWInt("badguy") ~= true then
		    return false -- that will block damage if attacker and ply is on the same team.
    		
	
	
	end
end )

hook.Add( "GetFallDamage", "0ALLDMG", function( ply, speed )
    return  0
end )

hook.Add("PlayerSelectSpawn", "RandomSpawnPosFix", function(ply)
    if game.GetMap() == "sc_highschool" then
	
    local spawnsTerrorist = ents.FindByClass("info_player_terrorist")
    local spawnsCounterTerrorist = ents.FindByClass("info_player_counterterrorist")
    
    local randomTerrorist = math.random(#spawnsTerrorist)
    local randomCounterTerrorist = math.random(#spawnsCounterTerrorist)
    
    local spawnTerrorist = spawnsTerrorist[randomTerrorist]
    local spawnCounterTerrorist = spawnsCounterTerrorist[randomCounterTerrorist]

    local spawn
    local POS
    
    if spawnTerrorist and spawnCounterTerrorist then
        if math.random(2) == 1 then
            spawn = spawnTerrorist
        else
            spawn = spawnCounterTerrorist
        end
    elseif spawnTerrorist then
        spawn = spawnTerrorist
    elseif spawnCounterTerrorist then
        spawn = spawnCounterTerrorist
    end

    if spawn then
        POS = spawn:GetPos()
    else
        POS = ply:GetPos()
    end

    local _, hull = ply:GetHull()
    POS = findEmptyPos(POS, { ply }, 600, 150, hull)

    return spawn, POS
	
	--
	elseif game.GetMap() == "slash_summercamp" then
	
    local spawnsTerrorist = ents.FindByClass("info_player_terrorist")
    local spawnsCounterTerrorist = ents.FindByClass("info_player_counterterrorist")
    
    local randomTerrorist = math.random(#spawnsTerrorist)
    local randomCounterTerrorist = math.random(#spawnsCounterTerrorist)
    
    local spawnTerrorist = spawnsTerrorist[randomTerrorist]
    local spawnCounterTerrorist = spawnsCounterTerrorist[randomCounterTerrorist]

    local spawn
    local POS
    
    if spawnTerrorist and spawnCounterTerrorist then
        if math.random(2) == 1 then
            spawn = spawnTerrorist
        else
            spawn = spawnCounterTerrorist
        end
    elseif spawnTerrorist then
        spawn = spawnTerrorist
    elseif spawnCounterTerrorist then
        spawn = spawnCounterTerrorist
    end

    if spawn then
        POS = spawn:GetPos()
    else
        POS = ply:GetPos()
    end

    local _, hull = ply:GetHull()
    POS = findEmptyPos(POS, { ply }, 600, 150, hull)

    return spawn, POS
	
	--
	
	else
	
	
    local spawns = ents.FindByClass("info_player_start")
	local random_entry = math.random(#spawns)
	local spawn = spawns[random_entry]


    local POS
    if spawn and spawn.GetPos then
        POS = spawn:GetPos()
    else
        POS = ply:GetPos()
    end




    local _, hull = ply:GetHull()

    POS = findEmptyPos(POS, {ply}, 600, 150, hull)

    return spawn, POS
	end


end)


hook.Add( "PlayerTick", "NoPlayerCollision", function( Player, CMoveData )
	
	if Player.Walkth == true then
		
		Player:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		
	else
		
		//Player:SetCollisionGroup( COLLISION_GROUP_NONE )
		Player:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		
	end
	
	Player:SetAvoidPlayers( false )
	
end )



local function getRandomPlayer()
    local players = player.GetAll()
    if #players > 0 then
        local randomIndex = math.random(1, #players)
        return players[randomIndex]
    else
        return nil
    end
end


local function getRandomPlayer2()
    local players = player.GetAll()
    local nonTeam1002Players = {}

    for _, ply in ipairs(players) do
        if ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
            table.insert(nonTeam1002Players, ply)
        end
    end

    if #nonTeam1002Players > 0 then
        local randomIndex = math.random(1, #nonTeam1002Players)
        return nonTeam1002Players[randomIndex]
    else
        return nil
    end
end

hook.Add( "PlayerInitialSpawn", "setmodel", function( ply )
	ply:SetModel("models/player/Group01/male_07.mdl")
end)

function GetRandomPill()
    local whatpil = nil
    if GetGlobalString("RoundType") == "Nightmare" then
        if math.random(1, 5) == 1 then
            whatpil = "Pill_9R_Mimic_G"
        elseif math.random(1, 4) == 1 then
            whatpil = "Pill_9_Burntrap_G"
        elseif math.random(1, 4) == 1 then
            whatpil = "Pill_5_Ennard_G"
        elseif math.random(1, 2) == 1 then
            whatpil = "Pill_4_NMFreddy_G"
        elseif math.random(1, 2) == 1 then
            whatpil = "Pill_4_NMBonnie_G"
        end
    elseif GetGlobalString("RoundType") == "Ignited" then
        if math.random(1, 2) == 1 then
            whatpil = "IgnitedFreddy"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedChica"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedFoxy"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedBonnie"
        else
            whatpil = "IgnitedSpringtrap"
        end
    elseif GetGlobalString("RoundType") == "Poppy" then -- TODO: Add chapter 2 models when they are available
        if math.random(1, 12) == 1 then
            whatpil = "pill_Thedoctor"
        elseif math.random(1, 8) == 1 then
            whatpil = "pill_Yarnman"
        elseif math.random(1, 8) == 1 then
            whatpil = "pill_Pianoman"
        elseif math.random(1, 8) == 1 then
            whatpil = "pill_Doughman"
        elseif math.random(1, 4) == 1 then
            whatpil = "pill_Doctorminion"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_Huggywuggych4"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_Injuredkissyhostile"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_Boxyboo"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_Mommylonglegs"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_Catnap"
        else
            whatpil = "pill_Injuredhuggy"
        end
    elseif GetGlobalString("RoundType") == "Everyone" then -- similar pill entry like Ignited to prevent logical errors
        if math.random(1, 2) == 1 then
            whatpil = "IgnitedFreddy"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedChica"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedFoxy"
        elseif math.random(1, 2) == 1 then
            whatpil = "IgnitedBonnie"
        else
            whatpil = "IgnitedSpringtrap"
        end
    elseif GetGlobalString("RoundType") == "Twisted" then
        if math.random(1, 4) == 1 then
            whatpil = "pill_twistedfoxy_69"
        elseif math.random(1, 3) == 1 then
            whatpil = "pill_twistedgoldenfreddy_69"
        elseif math.random(1, 2) == 1 then
            whatpil = "pill_twistedwolfnoflex"
        else
            whatpil = "pill_sdkfj_fupprr1"
        end
    elseif GetGlobalString("RoundType") == "Shadow" then

        whatpil = "pill_shadowtrap_fupprr2"
    elseif GetGlobalString("RoundType") == "Afton" then

        whatpil = "pill_purple"
    elseif GetGlobalString("RoundType") == "Glitch" then

        whatpil = "pill_SBMHW"
    end
    return whatpil
end

local function startRound()

	

    if player.GetCount() < 2 then
        roundState = ROUND_WAITING
	return
	end
	if roundState == ROUND_PREPARING then return end
	if IsValid(nextbots_tbl) then
	table.Empty(nextbots_tbl)
	end
    SetGlobalInt("playersui", 1 )
    SetGlobalString("RoundType", "EndRound")
	
         SetGlobalBool("chasen", false)
	
	 for i, v in ipairs(player.GetAll()) do
        if v:GetNWInt("badguy") == true or v:GetNWInt("InPill") == true then
            pk_pills.restore(v, true)
        end
		v:SetNWBool("canghost", false)
		v:SetNWBool("NV", false)
		v:SetNWBool("InPill", false)
		v:SetNWInt("isghost", 0)
	    v:SetFrags( 0 )
		v:SetNWFloat("EloSurvival", 0)
		v:SetNWFloat("cameralook", 0)
		v:SetNWFloat("Distance", 0)
        v:SetNWInt("badguy", false)
        v:SetTeam(0)
		v:SetNWInt("last30seconds", 0)
        GWS_SPAWNS.STOP_SPECTATE(v)
        v:KillSilent()
        print(v:Spawn())
		if v.trail and v.trail:IsValid() then
            v.trail:Fire('Enable')
        end
		v:GodEnable()
    end
    SetGlobalInt("GhostChild", 0 )
    local ragdolls = ents.FindByClass("prop_ragdoll")
    for _, ragdoll in pairs(ragdolls) do
        ragdoll:Remove()
    end
	
	if math.random(1,28) == 1 then
	    SetGlobalString("RoundType", "Shadow")
	elseif math.random(1,4) == 1 then
	    SetGlobalString("RoundType", "Nightmare")
    elseif math.random(1,4) == 1 then
	    SetGlobalString("RoundType", "Poppy")
	elseif math.random(1,99999999) == 1 then -- set this math.random to 1,4 if you are listing pills via ashop's commandes section -- AKA buyable pills.
	    SetGlobalString("RoundType", "Everyone")
	elseif math.random(1,22) == 1 then
		SetGlobalString("RoundType", "Afton")
	elseif math.random(1,22) == 1 then
		SetGlobalString("RoundType", "Glitch")
	elseif math.random(1,20) == 1 then
		SetGlobalString("RoundType", "Twisted")

	else
		SetGlobalString("RoundType", "Ignited")
		//SetGlobalString("RoundType", "Nightmare")
	end
	

	if GetGlobalString("ForceRoundType") == 1 then
	    SetGlobalString("RoundType", "Ignited")

    elseif GetGlobalString("ForceRoundType") == 2 then
	    SetGlobalString("RoundType", "Shadow")

	elseif  GetGlobalString("ForceRoundType") == 3 then
	
	    SetGlobalString("RoundType", "Twisted")
	
	elseif  GetGlobalString("ForceRoundType") == 4 then
	
	    SetGlobalString("RoundType", "Afton")
	elseif  GetGlobalString("ForceRoundType") == 5 then
	
	    SetGlobalString("RoundType", "Glitch")
	elseif  GetGlobalString("ForceRoundType") == 6 then
	
	    SetGlobalString("RoundType", "Nightmare")
	elseif  GetGlobalString("ForceRoundType") == 7 then
	
	    SetGlobalString("RoundType", "Poppy")
    elseif  GetGlobalString("ForceRoundType") == 8 then
	
	    SetGlobalString("RoundType", "Everyone")
	end
	
	
	SetGlobalInt("PointGain", 2)
	SetGlobalInt("EloGain", 3)
	if GetGlobalString("RoundType") == "Twisted" then
	    net.Start("StarChaseRound3")
		net.Broadcast()
			SetGlobalInt("PointGain", 3)
	    SetGlobalInt("EloGain", 6)
	
	elseif GetGlobalString("RoundType") == "Shadow" then
	    net.Start("StarChaseRound4")
		net.Broadcast()
		SetGlobalInt("PointGain", 5)
	    SetGlobalInt("EloGain", 12)
	elseif GetGlobalString("RoundType") == "Afton" then
	    net.Start("StarChaseRound5")
		net.Broadcast()
		SetGlobalInt("PointGain", 3)
	    SetGlobalInt("EloGain", 5)
	elseif GetGlobalString("RoundType") == "Glitch" then
	    net.Start("StarChaseRound6")
		net.Broadcast()
		SetGlobalInt("PointGain", 4)
	    SetGlobalInt("EloGain", 6)
	end
	
-- GET RANDOM BAD GUY
	
	
-- GET RANDOM BAD GUY PITY

local players = player.GetAll()
local numBadGuys = math.min(math.floor(#players / 8), 4)

if game.GetMap() == "rp_unioncity" then
    numBadGuys = math.min(math.floor(#players / 8), 6)
elseif game.GetMap() == "rp_southside" then
    numBadGuys = math.min(math.floor(#players / 8), 6)
elseif game.GetMap() == "gm_abandonedmall_hd" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "zs_laurelmall" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "hns_alstoybarn" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "gm_silent_apartments" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "rp_sorelane" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "rp_eastcoast_remaster" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "gm_golden_park_v2" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "gm_underground_parking" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "gm_descent" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "gm_subterranean_complex" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "contagion_estates" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
elseif game.GetMap() == "sc_highschool" then
    numBadGuys = math.min(math.floor(#players / 8), 3)
elseif game.GetMap() == "hns_fazbears_forgotten" then
    numBadGuys = math.min(math.floor(#players / 8), 2)
end
-- Initialize or update the pity chances for players
for _, ply in ipairs(players) do
    ply.pityChance = ply:GetPData("pityChance", 0)
end

local function getPityWeightedRandomPlayer()
    local totalWeight = 0
    for _, ply in ipairs(players) do
        totalWeight = totalWeight + (1 + ply.pityChance)
    end

    local randomWeight = math.random() * totalWeight
    for _, ply in ipairs(players) do
        randomWeight = randomWeight - (1 + ply.pityChance)
        if randomWeight <= 0 then
            return ply
        end
    end
    return players[#players] -- Fallback in case of rounding errors
end

local function applyEffectsToRandomPlayer(increasePity, vanny)
    local ply = getPityWeightedRandomPlayer()
	if vanny and vanny == true then
	    applyEffects(ply, true)
	else
	
        applyEffects(ply)
	end
    for _, player in ipairs(players) do
        if player ~= ply then
            player.pityChance = player.pityChance + 0.03
            player:SetPData("pityChance", player.pityChance)
        else
            player.pityChance = 0
            player:SetPData("pityChance", 0)
        end
    end
end

if GetGlobalString("RoundType") == "Shadow" then
    if #players >= 10 then
        applyEffectsToRandomPlayer(true)
        applyEffectsToRandomPlayer(true)
        applyEffectsToRandomPlayer(true)
    elseif #players >= 6 then
        applyEffectsToRandomPlayer(true)
        applyEffectsToRandomPlayer(true)
    else
        applyEffectsToRandomPlayer(true)
    end

elseif GetGlobalString("RoundType") == "Afton" then
    applyEffectsToRandomPlayer(true)

elseif GetGlobalString("RoundType") == "Glitch" then
    applyEffectsToRandomPlayer(true)
    applyEffectsToRandomPlayer(true, true)

elseif numBadGuys > 0 then
    for i = 1, numBadGuys + 1 do
        applyEffectsToRandomPlayer(true)
    end
else
    applyEffectsToRandomPlayer(true)
end




    for i, v in ipairs(player.GetAll()) do
	    v:SetNWInt("JUMPCOOL", 0 )
		if GetGlobalString("RoundType") == "Afton" and v:GetNWInt("badguy") ~= true then
	    	v:SetModel("models/Cryingchild/cryingchild.mdl")
			
		else
		    v:SetModel("models/player/Group01/male_07.mdl")
		end
		if IsValid( v.Ragdoll ) then v.Ragdoll:Remove() end

    end
	
	
	
	
	
	
	
	
	
	
	
	
	---


		net.Start("playerleftui2")
net.Broadcast()

    roundState = ROUND_PREPARING
    roundStartTime = CurTime() + 32 -- Add preparation time before the round starts
    net.Start("StarChaseRound")
    net.Broadcast()
    print("Pre Round")
if game.GetMap() == "contagion_estates" then	

    for k, v in ipairs( ents.FindByClass( "env_fog_controller" ) ) do
    	v:Remove() 
	end
	
end

         for k, v in ipairs( ents.FindByClass( "env_spritetrail" ) ) do 
	         if v:GetParent() and v:GetParent():IsPlayer() then

				
				    v:SetColor(Color(255, 255, 255, 255)) 

			 
			 end
	     end






end

local function startRound2()
	SetGlobalInt("roundtimer", 600)
    SetGlobalInt("TimerFix", 600)
timer.Create("SurvivalPointsTimer", pointInterval, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
            -- ply:ashop_addCoinsSafe2(pointAmount * GetGlobalInt("PointGain")) -- uncomment if you use ashop
        end
    end
end)

timer.Create("SurvivalPointsTimer2", 1, 0, function()
    SetGlobalInt("TimerFix", GetGlobalInt("TimerFix") - 1 )
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
            ply:SetNWFloat("EloSurvival", ply:GetNWFloat("EloSurvival") + 0.6 )
            if ply:IsOnGround() then
                local oldPos = ply:GetNWVector("LastPosition") or ply:GetPos()
                local distance = oldPos:Distance(ply:GetPos())
                ply:SetNWFloat("Distance", ply:GetNWFloat("Distance") + ( distance / 3000 ) )
                ply:SetNWVector("LastPosition", ply:GetPos())
            end
        end
    end
end)

timer.Create("GhostChild2", 300, 0, function()
    SetGlobalInt("GhostChild", 2 )
    print("Auto-Ghost Activated!")
end)




local donationURL = "https://www.example.com" -- put your own donation URL here.



local function OpenDonationURL(ply, text)
    local lowerText = string.lower(text)

    if string.match(lowerText, "!donate") or string.match(lowerText, "/donate") then
        -- Use the player's console to open the URL
        print("Donation command detected from player:", ply:Nick())
        net.Start("OpenDonateUrl")
        net.Send(ply)
        return "" -- Prevent the message from being sent in chat
    end
end

hook.Add("PlayerSay", "OpenDonationURLCommand", OpenDonationURL)

-- To print the location the player is looking at
local function PrintLookLocation(ply, cmd, args)
    local trace = ply:GetEyeTrace()
    local lookPos = trace.HitPos
    ply:ChatPrint("You are looking at: " .. tostring(lookPos))
end

concommand.Add("print_look_location", PrintLookLocation)

timer.Create("GhostChild", 60, 0, function() -- was 40
    local randFactor = 4
    if GetGlobalInt("GhostChild") ~= 2 then return end
    if math.random(1, randFactor) == 1 then return end -- separated from global int due to logical issues
    if GetGlobalString("RoundType") == "Twisted" or GetGlobalString("RoundType") == "Afton" then return end
    if GetGlobalInt("TimerFix", 600) < 45 or #GetPlayersWithBadguyNot3() < 11 then return end
    local ply = getRandomPlayer2()
    local animent = ents.Create( 'base_gmodentity' )
	animent:Spawn()
	animent:Activate()

    local _, hull = ply:GetHull()
    local forwardVector = ply:GetForward() * 150
    local emptyspot = findEmptyPos(ply:GetPos() + Vector(0,0,100) + forwardVector, {ply}, 600, 150, hull)
	animent:SetPos(emptyspot)
	

	animent:SetModel("models/errolliamp/fnaf_world/crying_child.mdl")
	
	animent:SetSolid( SOLID_OBB ) -- This stuff isn't really needed, but just for physics
	animent:PhysicsInit( SOLID_OBB )
	animent:SetMoveType( MOVETYPE_NOCLIP )
	animent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
    local function UpdateAngles()
        if IsValid(animent) and IsValid(ply) then
            local targetAngle = (ply:GetPos() - animent:GetPos()):Angle()
            local currentAngle = animent:GetAngles()
            local newAngle = LerpAngle(1, currentAngle, targetAngle)
            animent:SetAngles(newAngle)
        end
    end
	UpdateAngles()
	local timeleft = 5
	if math.random(1,2) == 1 then
	     animent:EmitSound("echo1.mp3", 110)
		 	         timeleft = 2
	elseif math.random(1,2) == 1 then
		     animent:EmitSound("goldenbear.mp3", 110)
			 	         timeleft = 15
	else
	         timeleft = 4.5
		     animent:EmitSound("ghostlaugh.mp3", 110)
	end
	
    timer.Create("UpdateAnglesTimer", 0.01, 0, UpdateAngles)
	
        net.Start("GhostMark")
        net.WriteEntity(ply)
        net.Broadcast()

        timer.Simple(2, function()
            if IsValid(ply) then
                net.Start("GhostMark2")
                net.WriteEntity(ply)
                net.Broadcast()
            end
        end)
	
	print("Auto-Ghost Happened!")
	timer.Simple(timeleft, function() if IsValid(animent) then  timer.Remove("UpdateAnglesTimer") animent:Remove() end end )
end)

timer.Create("endroundsoundtimer", 567, 0, function()
	net.Start("roundending")
	net.Broadcast()
	for i, v in ipairs(player.GetAll()) do
        if v:GetNWInt("badguy") == true then
		    
		   v:SetNWInt("last30seconds", 2)
		else
		    v:SetNWInt("last30seconds", 3)
		end
	end
end)


    SetGlobalBool("chasen", true)
    for i, v in ipairs(player.GetAll()) do
        v.Walkth = false
		v:GodDisable()
		v:SetNWBool("didelogain", true)
		v:SetNWBool("firstjoin", false)
	end
	net.Start("ResetRoundTimer")
	net.Broadcast()
	print( "Round Started" )
    if tonumber(#GetPlayersWithBadguyNot3()) < 11 then
	
	   
		if GetGlobalInt("pui") ~= 2 then
		     SetGlobalInt("pui", 2)
	        net.Start("playerleftui")
            net.Broadcast()
		end
	
	end

end

local function endRound()
    net.Start("playerleftui2")
    net.Broadcast()
    SetGlobalInt("pui", 1)
    
    if roundState == ROUND_PREPARING then return end
    if roundState == ROUND_WAITING then return end
    if roundState == ROUND_ENDING then return end

    SetGlobalString("RoundType", "EndRound")
    SetGlobalInt("Roundsleft", GetGlobalInt("Roundsleft") - 1)
    roundState = ROUND_ENDING
    print("Round Ended")

    net.Start("StarChaseRound2")
    net.Broadcast()
    timer.Remove("SurvivalPointsTimer")
    timer.Remove("SurvivalPointsTimer2")
    timer.Remove("endroundsoundtimer")
    timer.Remove("GhostChild")
    timer.Remove("GhostChild2")

    if GetGlobalInt("Roundsleft") <= 0 then
        MapVote.Start()
        print("MAP VOTE INITIATED!")
    else
        timer.Simple(10, function()
            startRound()
        end)
    end

    if #player.GetAll() >= 5 then
        for _, ply in pairs(player.GetAll()) do
            if ply:GetNWBool("didelogain") == true then
                ply:SetNWInt("AftonH", 3)
                ply:SetNWInt("spookmeter", 0)
                if ply:GetNWBool("firstjoin") ~= true then
                    local xp = 0
                    local survivaltime = 0
                    local survivaltime2 = 0
                    local badguyalive = false
                    local fragMultiplier = 5 + (ply:Frags() * 1.5) -- Adjust scaling factor as needed
                    if IsValid(ply) and ply:Frags() > 1 and ply:GetNWInt("badguy") == true then
                        xp = xp + (ply:Frags() * fragMultiplier) * GetGlobalInt("EloGain")
                        for _, child in pairs(ply:GetChildren()) do
                            if child:GetClass() == "pill_ent_costume" then
                                if child.formTable.printName and ply.PillData and ply.PillData[child.formTable.printName] then
                                    GivePillRankXP(ply, child.formTable.printName, ply:Frags() * 5 + fragMultiplier)
                                end
                            end
                        end
                    end

                    if IsValid(ply) and ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
                        xp = xp + 60 * GetGlobalInt("EloGain")
                    end

                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("EloSurvival") > 0 then
                        survivaltime = math.Round(ply:GetNWFloat("EloSurvival"))
                        xp = xp + survivaltime * GetGlobalInt("EloGain")
                    end

                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("cameralook") > 0 then
                        survivaltime = math.Round(ply:GetNWFloat("cameralook"))
                        xp = xp + survivaltime * GetGlobalInt("EloGain")
                    end

                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("Distance") > 0 then
                        survivaltime2 = math.Round(ply:GetNWFloat("Distance"))
                        xp = xp + (survivaltime2 * GetGlobalInt("EloGain"))
                    end

                    if IsValid(ply) and ply:Team() ~= 1002 and ply:GetNWInt("badguy") == true then
                        xp = xp + 60 * GetGlobalInt("EloGain")
                    end

                    xp = xp
                    local playerLevel = ply:GetNWInt("Elite_Level")
                    local divisionFactor = playerLevel / 20

                    if playerLevel == 1 then -- unranked
                        divisionFactor = 18 -- was 20
                    elseif playerLevel >= 2 or playerLevel <= 4 then -- bronze
                        divisionFactor = 22 -- was 24
                    elseif playerLevel >= 5 or playerLevel <= 6 then -- silver
                        divisionFactor = 26 -- was 28
                    elseif playerLevel >= 7 or playerLevel <= 10 then -- gold
                        divisionFactor = 30 -- was 32
                    elseif playerLevel >= 11 or playerLevel <= 14 then -- platinum
                        divisionFactor = 34 -- was 36
                    elseif playerLevel >= 15 or playerLevel <= 17 then -- diamond
                        divisionFactor = 39 -- was 40
                    elseif playerLevel >= 18 or playerLevel <= 20 then -- emerald
                        divisionFactor = 44 -- was 44
                    elseif playerLevel >= 21 or playerLevel <= 23 then -- sapphire
                        divisionFactor = 49 -- was 48
                    elseif playerLevel >= 24 or playerLevel <= 26 then -- ruby
                        divisionFactor = 55 -- was 52
                    elseif playerLevel >= 27 or playerLevel <= 31 then -- champion
                        divisionFactor = 65 -- was 60
                    end

                    -- if ply:GetPData("hs_disableelogain", false) ~= "true" then -- uncomment if you want to provide the option for players to disable elo gain
                        local dividedXP = xp / divisionFactor
                        ply:SetNWBool("didelogain", false)
                        -- print("Xp divison now is: " .. dividedXP .. " | utilized from factor: " .. divisionFactor) -- for debugging purposes
                        dividedXP = math.abs(dividedXP)
                        -- print("Xp divison after absolute value now is: " .. dividedXP .. " | utilized from factor: " .. divisionFactor) -- for debugging purposes

                        if dividedXP < 0 then
                            dividedXP = math.Truncate(dividedXP)
                                -- EliteXP.RemoveXP(ply, math.abs(dividedXP)) -- uncomment if you are using the elitexp system
                            --  net.Start("XP_NotificationsInfo") -- uncomment if you are using the elitexp system
                                 net.WriteInt(math.Round(dividedXP), 32)
                                 net.WriteUInt(15, 6)
                                 net.WriteEntity(ply)
                             net.Send(ply)
                        else
                            dividedXP = math.abs(dividedXP)
                            --  EliteXP.GiveXP(ply, math.Round(dividedXP)) -- uncomment if you are using the elitexp system
                            --  net.Start("XP_NotificationsInfo") -- uncomment if you are using the elitexp system
                                 net.WriteInt(math.Round(dividedXP), 32)
                                 net.WriteUInt(15, 6)
                                 net.WriteEntity(ply)
                             net.Send(ply)
                        end
                    -- end -- uncomment if you want to provide the option for players to disable elo gain
                end
            end
        end
    else
        -- net.Start("XP_NotificationsInfo") -- uncomment if you are using the elitexp system
            net.WriteInt(0, 32)
            net.WriteUInt(16, 6)
        net.Broadcast(ply)
    end

    net.Start("playerleftui2")
    net.Broadcast()

end

local reviveTarget = ""
function revive(name)
    name = string.lower(name) -- Lowercase for case-insensitive comparison
    for _, ply in pairs(player.GetAll()) do
        if string.lower(ply:Nick()) == name then
            ply:KillSilent()
            ply:Spawn()
        end
    end




end
local didrunc = false
-- This is to check and update the round state
local function updateRoundState()
    if roundState == ROUND_WAITING then
	    if GetGlobalBool("FirstRound") == true then
		
		    if player.GetCount() >= 2 then
			    print("OMG") -- for debugging purposes
				SetGlobalBool("FirstRound", false)
			    timer.Simple(60, function()  startRound() didrunc = true end )
				return
            end
	    elseif didrunc == true then
		
            if player.GetCount() >= 2 then
			    print("OMG2") -- for debugging purposes
			    startRound()
            end
		 
		end
    elseif roundState == ROUND_PREPARING then
        if CurTime() >= roundStartTime then
            roundState = ROUND_ACTIVE -- Start the round
			startRound2()
        end
    elseif roundState == ROUND_ACTIVE then
        if CurTime() >= roundStartTime + roundDuration then
            endRound() -- End the round when the duration is over
        end
        -- Additional logic for handling gameplay during the active round can go here
    elseif roundState == ROUND_ENDING then
        -- Additional logic for handling the end of round state can go here
    end
end

hook.Add( "PlayerDisconnected", "Playerleave", function(ply)
	local allPlayersDead2 = true
	local allPlayersDead = true


        for _, ply in pairs(player.GetAll()) do
            if ply:Team() ~= 1002 and ply:GetNWInt("badguy") == true then
                allPlayersDead2 = false
                break
            end
        end

	
    if allPlayersDead2 == true then
		for _, ply in pairs(player.GetAll()) do
            if ply:GetNWInt("badguy") ~= true then
			
			    -- ply:ashop_addCoinsSafe2(350 * GetGlobalInt("PointGain")) -- uncomment if you use ashop
			
            end
        end
        endRound()
    end
	
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
            allPlayersDead = false
            break
        end
    end

    if allPlayersDead == true then
		for _, ply in pairs(player.GetAll()) do
            if ply:GetNWInt("badguy") == true then
			
			    -- ply:ashop_addCoinsSafe2(350 * GetGlobalInt("PointGain")) -- uncomment if you use ashop
			
            end
        end
        endRound()
    end
end )

hook.Add("PlayerDeath", "EndRoundOnDeath", function(victim, _, attacker)
    if GetGlobalString("RoundType") == "Afton" then
	    if attacker:IsPlayer() and attacker:GetNWBool("InPill") == true then
		    attacker:SetNWInt("spookmeter", attacker:GetNWInt("spookmeter") - 4 )
		   
		   
		  
		end
	    ragdollAttackerDissolver(0, victim:GetRagdollEntity())
		attacker:EmitSound("killsoundafton" .. math.random(1,2) .. ".ogg", 110)
	
	end
    if roundState == ROUND_ACTIVE then
        if #player.GetAll() >= 5 and GetGlobalInt("TimerFix", 600) < 540  then
            if IsValid(victim) and victim:GetNWBool("didelogain") == true then
			    local ply = victim
                ply:SetNWInt("AftonH", 3)
                ply:SetNWInt("spookmeter", 0)
                if ply:GetNWBool("firstjoin") ~= true then
                    local xp = 0
                    local survivaltime = 0
                    local survivaltime2 = 0
                    local badguyalive = false
                    local fragMultiplier = 5 + (ply:Frags() * 1.5) -- Adjust scaling factor as needed
                    if IsValid(ply) and ply:Frags() > 1 and ply:GetNWInt("badguy") == true then
                        xp = xp + ( ply:Frags() * fragMultiplier ) * GetGlobalInt("EloGain")
						
                        for _, child in pairs(ply:GetChildren()) do
                            if child:GetClass() == "pill_ent_costume" then
                                print("didgivexptest")
                                if child.formTable.printName and ply.PillData and ply.PillData[child.formTable.printName] then
                                    print("didgivexp")
                                    GivePillRankXP(ply, child.formTable.printName, ply:Frags() * 5 + fragMultiplier)    
                                end
                            end
                        end
                    end


                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("EloSurvival") > 0 then
                        survivaltime = math.Round( ply:GetNWFloat("EloSurvival") )
                        xp = xp + survivaltime * GetGlobalInt("EloGain")
                    end
					
		                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("cameralook") > 0 then
		                        survivaltime = math.Round( ply:GetNWFloat("cameralook") )
		                        xp = xp + survivaltime * GetGlobalInt("EloGain")
		
		
	                    	end

                    if IsValid(ply) and ply:GetNWInt("badguy") ~= true and ply:GetNWFloat("Distance") > 0 then
                        survivaltime2 = math.Round( ply:GetNWFloat("Distance") )
                        xp = xp + ( survivaltime2 * GetGlobalInt("EloGain")  )
                    end

                    -- Levels are ranks, so level 1 is unranked and so on.
                    xp = xp 
                    local playerLevel = ply:GetNWInt("Elite_Level")
                    local divisionFactor = playerLevel / 20

                    if playerLevel == 1 then -- unranked
                        divisionFactor = 18 -- was 20
                    elseif playerLevel >= 2 or playerLevel <= 4 then -- bronze
                        divisionFactor = 22 -- was 24
                    elseif playerLevel >= 5 or playerLevel <= 6 then -- silver
                        divisionFactor = 26 -- was 28
                    elseif playerLevel >= 7 or playerLevel <= 10 then -- gold
                        divisionFactor = 30 -- was 32
                    elseif playerLevel >= 11 or playerLevel <= 14 then -- platinum
                        divisionFactor = 34 -- was 36
                    elseif playerLevel >= 15 or playerLevel <= 17 then -- diamond
                        divisionFactor = 38 -- was 40
                    elseif playerLevel >= 18 or playerLevel <= 20 then -- emerald
                        divisionFactor = 44 -- was 44
                    elseif playerLevel >= 21 or playerLevel <= 23 then -- sapphire
                        divisionFactor = 49 -- was 48
                    elseif playerLevel >= 24 or playerLevel <= 26 then -- ruby
                        divisionFactor = 55 -- was 52
                    elseif playerLevel >= 27 or playerLevel <= 31 then -- champion
                        divisionFactor = 65 -- was 60
                    end

                    local dividedXP = xp / divisionFactor

                    if ply then
                        dividedXP = dividedXP - 23 * ( playerLevel / 6 )
                    end
                    ply:SetNWBool("didelogain", false)
					-- if ply:GetPData("hs_disableelogain", false) ~= "true" then -- uncomment if you want to provide the option for players to disable elo gain
                        -- dividedXP = math.abs(dividedXP)
                        if dividedXP < 0 then
                            dividedXP = math.Truncate(dividedXP)
                            local adjustedXPRemoval = dividedXP / 1.15
                            if ply:GetNWInt("last30seconds") == 3 then
                                adjustedXPRemoval = adjustedXPRemoval / 1.3
                                
                            end
                            adjustedXPRemoval = math.Round(adjustedXPRemoval)
                            --  EliteXP.RemoveXP(ply, math.abs(adjustedXPRemoval)) -- uncomment if you are using the elitexp system
                            --  net.Start("XP_NotificationsInfo") -- uncomment if you are using the elitexp system
                                net.WriteInt(adjustedXPRemoval, 32)
                                net.WriteUInt(15, 6)
                                net.WriteEntity(ply)
                            net.Send(ply)
                        else
                            dividedXP = math.abs(dividedXP)
                            -- EliteXP.GiveXP(ply, math.Round(dividedXP)) -- uncomment if you are using the elitexp system
                            --  net.Start("XP_NotificationsInfo") -- uncomment if you are using the elitexp system
                                net.WriteInt(math.Round(dividedXP), 32)
                                net.WriteUInt(15, 6)
                                net.WriteEntity(ply)
                            net.Send(ply)
                        end
					-- end -- uncomment if you want to provide the option for players to disable elo gain
                end
            end
        else

            victim:fupprmessage( Color( 255, 0, 0), "You were not eligible to gain or lose ELO this round!" )
        end
	    if victim:GetNWInt("badguy") ~= true then
		    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetNWInt("badguy") == true then
			  
			
			    -- attacker:ashop_addCoinsSafe2(75 * GetGlobalInt("PointGain")) -- uncomment if you use ashop
				local ply = attacker
			end
		end
		victim:SetTeam(TEAM_SPECTATOR)
		victim:SetTeam(1002)
         for k, v in ipairs( ents.FindByClass( "env_spritetrail" ) ) do 
	         if v:GetParent() and v:GetParent():IsPlayer() then
			    if v:GetParent():Team() == 1002 then
				
				    v:SetColor(Color(255, 255, 255, 0)) 
				end
			 
			 end
	     end
		timer.Simple(3, function()
		victim:SetTeam(TEAM_SPECTATOR)
	    GWS_SPAWNS.START_SPECTATE(victim)

	    end )
		if GetGlobalInt("pui") ~= 2 then

		     if tonumber(#GetPlayersWithBadguyNot3()) < 11 then
			     
		         timer.Simple(0.2, function() net.Start("playerleftui")
			     net.Broadcast()
				 end )
				 SetGlobalInt("pui", 2)
			 end
		
		
		end
	end
    if roundState == ROUND_PREPARING or roundState == ROUND_WAITING then
	
		victim:SetTeam(TEAM_SPECTATOR)
	    GWS_SPAWNS.START_SPECTATE(victim)
	
	end
	
	if roundState == ROUND_ENDING then return end
	local allPlayersDead = true
	local allPlayersDead2 = true


        for _, ply in pairs(player.GetAll()) do
            if ply:Team() ~= 1002 and ply:GetNWInt("badguy") == true then
                allPlayersDead2 = false
                break
            end
        end

	
    if allPlayersDead2 == true then
		for _, ply in pairs(player.GetAll()) do
            if ply:GetNWInt("badguy") ~= true then
			
			    -- ply:ashop_addCoinsSafe2(350 * GetGlobalInt("PointGain")) -- uncomment if you use ashop
			
            end
        end
        endRound()
    end
	
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() ~= 1002 and ply:GetNWInt("badguy") ~= true then
            allPlayersDead = false
            break
        end
    end

    if allPlayersDead == true then
		for _, ply in pairs(player.GetAll()) do
            if ply:GetNWInt("badguy") == true then
			
			    -- ply:ashop_addCoinsSafe2(350 * GetGlobalInt("PointGain")) -- uncomment if you use ashop
			
            end
        end
        endRound()
    end
end)

-- Needed to update the round state every frame
hook.Add("Think", "UpdateRoundState", function()
    updateRoundState()
end)

hook.Add("PlayerSpawn", "PreventRespawnDuringRound", function(ply)

if ply:GetNWBool("canghost") == true then

else

if  roundState == ROUND_ACTIVE then

        ply:KillSilent()
		ply:SetTeam(TEAM_SPECTATOR)
	    GWS_SPAWNS.START_SPECTATE(ply)
		
end

end

end)

hook.Add("PlayerInitialSpawn", "fixspecspawn", function(ply)
    if roundState == ROUND_ACTIVE then
        ply:KillSilent()
        ply:SetTeam(TEAM_SPECTATOR)
		ply:SetNWBool("firstjoin", true)
        GWS_SPAWNS.START_SPECTATE(ply)
        timer.Simple(10, function()
            if roundState == ROUND_ACTIVE then
                ply:SetTeam(TEAM_SPECTATOR)
				ply:SetNWBool("firstjoin", true)
                GWS_SPAWNS.START_SPECTATE(ply)
				net.Start("joininround")
				net.Send(ply)
            end
        end)
    end
end)

function playerforcerespawn( ply )
    if ply:GetNWBool("canghost") == true then
	
	else
	
    if roundState == ROUND_ACTIVE or roundState == ROUND_ENDING then
	
        return false
    end
	end

end
 
hook.Add( "PlayerDeathThink", "player_step_forcespawn", playerforcerespawn );

local AmmoRegen = 0




function GM:ShowSpare1( ply )



end


function Loadout( ply, kit )
    ply.Walkth = true
	//timer.Simple(30, function() ply.Walkth = false end )

	if GetGlobalString("RoundType") == "Afton" then
	
	        ply:SetRunSpeed( 630 )
        ply:SetMaxSpeed( 660 )
         ply:SetWalkSpeed( 500 )
    	 ply:SetJumpPower(200)
	
	else
	    ply:SetRunSpeed( 530 )
        ply:SetMaxSpeed( 560 )
        ply:SetWalkSpeed( 400 )
    	ply:SetJumpPower(200)
		timer.Simple(0.5, function()
		    ply:SetMoveType( MOVETYPE_WALK )
		
		end )
	
	
	end
    ply:RemoveAllItems()
	ply:StripWeapons()

   if ply:IsBot() then return end
    if kit == 1 then

        ply:SetHealth( ply:GetMaxHealth() )


        ply:CanUseFlashlight( true )
        ply:AllowFlashlight( true )

    elseif kit == 2 then

        ply:CanUseFlashlight( true ) 
        ply:AllowFlashlight( true )

    elseif kit == 3 then

        ply:CanUseFlashlight( true )
        ply:AllowFlashlight( true  )

    end 
	



	
	
	if ply:GetNWInt("badguy") ~= true then
	    timer.Simple(0.1, function()
		
		ply:Give("weapon_empty_hands")  end ) -- if using the apex swep, change the value to "apexswep", else leave it at 
		timer.Simple(1, function() if GetGlobalString("RoundType") == "Afton" then
		
		    	    ply:Give("ghostchild")
					
					elseif GetGlobalString("RoundType") == "Glitch" then
					 ply:Give("weapon_push")
					
				
		
		end
	    end )
	end
	        ply:CanUseFlashlight( true )
        ply:AllowFlashlight( true )
		ply.CanUseFlashlight = true

		
		if GetGlobalString("RoundType") == "Shadow" then
		     timer.Simple(5, function() if ply:GetNWInt("badguy") == true then     ply:SetRunSpeed( 640 ) ply:SetMaxSpeed( 680 ) ply:SetWalkSpeed( 500 ) ply:SetJumpPower(4) end end )  -- jumppower was 1
        else
		    timer.Simple(5, function() if ply:GetNWInt("badguy") == true then     ply:SetRunSpeed( 528 ) ply:SetMaxSpeed( 540 ) ply:SetWalkSpeed( 150 ) ply:SetJumpPower(4) end end )  -- jumppower was 1
		end
	end


-- Player Spawn Hook:
local function Respawn( ply )

    if round_status == 1 then
        Loadout(ply, 1)
    else
        Loadout(ply, 3)
    end

end
hook.Add( "PlayerSpawn", "Respawn", Respawn)


hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
-- if ply:IsAdmin() or ply:IsSuperAdmin() then return true else -- commented out for now until I think of what is a good idea to use it on.
		return false
end )


hook.Add( "KeyPress", "ghostchildenable", function( ply, key )
	if ( key == IN_RELOAD ) and ply:Team() == 1002 then
		if ply:GetNWBool("InPill") == false and ply:GetNWBool("canghost", false) == false and roundState == ROUND_ACTIVE then
		    print("DIDUSEGHOST2")
		    ply:SetNWBool("canghost", true)
			timer.Simple(0.1, function()
			ply:SetTeam(0)
            GWS_SPAWNS.STOP_SPECTATE(ply)
			ply:KillSilent()
			print(ply:Spawn())
		    pk_pills.apply(ply, "pill_ghostchild")
			end )
		end
	end
end )



hook.Add("PlayerSpawnProp", "RyzenGm_SpawnDisable", function(ply, model)
    return false
end)

hook.Add( "PlayerSpray", "DisableDeadPlayerSpray", function( ply )
	if ply:Team() == 1002 then return true end
	if ply:GetNWInt("isghost") == 2 then return true end
end )


    local sprayGroups = {
        ["admin"] = true,
        ["superadmin"] = true,
        ["vip"] = true,
        ["vip+"] = true,
        ["vip++"] = true,
        ["dev"] = true
    }

hook.Add("PlayerSpray", "RestrictSprayToGroups", function(ply)


    if sprayGroups[ply:GetUserGroup()] then
        return false -- Allow spraying for allowed groups
    else
        return true -- Disallow spraying for other groups
    end
end)

hook.Add("InitPostEntity", "FixSpawnsOnMaps", function()
    print("Initialization hook called")

    local current_map = game.GetMap()

    if current_map == "rp_fazbears_fright_night" then
        local new_positions = {
            Vector(276.305634, -2157.527588, -32.031250),
            Vector(6.292483, -2144.871582, -32.031250),

Vector(-398.519714, -702.085999, -32.031250),

Vector(-407.698059, -1178.510498, -32.031250),

Vector(359.259552, -1230.213745, -32.031250),


Vector(-4066.328857, -9094.948242, 16.031250),
 
Vector(-4067.025879, -9213.873047, 16.031250),

Vector(-4224.120117, -7799.572754, 16.031250),


Vector(-4054.630615, -4943.642090, 32.031250),
Vector(-4079.693359, -5304.809570, 32.031250),

Vector(390.978424, -844.713379, -32.031250),

Vector(665.182129, -841.689880, -32.031250),

            Vector(-84.030273, -2813.231689, -32.031250)
        }

        local player_spawns = ents.FindByClass("info_player_*")

        for _, ent in ipairs(player_spawns) do
            ent:Remove()
        end

        for _, pos in ipairs(new_positions) do
            local new_spawn = ents.Create("info_player_start")
            new_spawn:SetPos(pos)
            new_spawn:Spawn()
        end
    end

    if current_map == "gm_abandonedmall_hd" then
        local new_positions = {
            -- Vector(-1489.770020 4451.259766 64.000000),
        }

        local player_spawns = ents.FindByClass("info_player_zombie")

        for _, ent in ipairs(player_spawns) do
            ent:Remove()
        end

        local positions_to_remove = {
            Vector(-232.042999, 794.346008, 64.000000),
        }
    
        local player_spawns = ents.FindByClass("info_player_*")

        for _, ent in ipairs(player_spawns) do
            local pos = ent:GetPos()
    
            for _, remove_pos in ipairs(positions_to_remove) do
                if pos:DistToSqr(remove_pos) < 1 then
                    ent:Remove()
                    break
                end
            end
        end

        -- for _, pos in ipairs(new_positions) do
        --     local new_spawn = ents.Create("info_player_start")
        --     new_spawn:SetPos(pos)
        --     new_spawn:Spawn()
        -- end
    end

    if current_map == "rp_downpour" then
	    local new_positions = {
		
		
		
Vector(-346.306793, -4274.183594, 352.031250),
Vector(-150.300674, -4276.702148, 352.031250),
Vector(-296.128052, -4049.121826, 352.031250),
Vector(-146.378586, -4055.060791, 352.031250),
Vector(-3192.047119, -3681.486572, 352.031250),
Vector(-2537.746094, -3675.183105, 352.031250),
Vector(-2532.561279, -2990.931885, 352.031250),
Vector(-4789.974609, -2304.301025, -35.968750),
Vector(-5141.426758, -2291.981689, -35.968750),
Vector(-7527.063965, -1807.109497, 352.031250),
Vector(-7622.330566, -1715.986328, 352.031250),
Vector(-7610.729492, -1432.570068, 352.031250),
Vector(-7495.130859, -1341.974121, 352.031250),
Vector(-5099.531250, -1417.866089, 384.031250),
Vector(-4523.487305, -1420.278931, 384.031250),
Vector(-4536.745605, -1755.578857, 384.031250),
Vector(-5063.904785, -1781.435425, 384.031250),
Vector(-4460.859863, -9.038083, 352.035370),
Vector(-5181.291016, -1.567846, 352.031250),
Vector(-5912.002441, 12.870982, 352.074036),
Vector(-6592.144531, -1.588542, 352.031250)
		
		
		}
        for _, pos in ipairs(new_positions) do
            local new_spawn = ents.Create("info_player_start")
            new_spawn:SetPos(pos)
            new_spawn:Spawn()
        end
	end
    if current_map == "gm_nightlight" then
	    local new_positions = {
		
		
		
Vector(2322.411377, 993.068726, -10167.968750),
Vector(3478.227783, 1352.233643, -10167.968750),
Vector(-5089.604004, 5277.831543, -10167.968750),
Vector(-5094.539062, 3546.441895, -10167.968750),
Vector(-7001.978027, 5587.992188, -10175.968750),
Vector(-6826.566406, 7090.931152, -10167.968750),
Vector(-5324.855957, 7320.550781, -10169.787109),
Vector(-3801.720459, 7580.969238, -10167.968750),
Vector(-2014.680664, 7578.251953, -10167.968750)
		
		
		}
        for _, pos in ipairs(new_positions) do
            local new_spawn = ents.Create("info_player_start")
            new_spawn:SetPos(pos)
            new_spawn:Spawn()
        end
	end
    if current_map == "gm_vacant_industry" then
        local new_positions = {
            Vector(-0, 1708, 4),
            Vector(112, 1708, 4),
            Vector(-112, 1708, 4),
            Vector(-0, 1808, 4),
            Vector(112, 1808, 4),
            Vector(-112, 1808, 4),

            Vector(224, 1708, 4),
            Vector(-224, 1708, 4),
            Vector(336, 1708, 4),
            Vector(-336, 1708, 4),
            Vector(448, 1708, 4),
            Vector(-448, 1708, 4),
            Vector(560, 1708, 4),
            Vector(-560, 1708, 4),
            Vector(224, 1808, 4),
            Vector(-224, 1808, 4),
            Vector(336, 1808, 4),
            Vector(-336, 1808, 4),
            Vector(448, 1808, 4),
            Vector(-448, 1808, 4),
            Vector(560, 1808, 4),
            Vector(-560, 1808, 4),

            Vector(-0, 1758, 4),
            Vector(112, 1758, 4),
            Vector(-112, 1758, 4),
            Vector(-0, 1858, 4),
            Vector(112, 1858, 4),
            Vector(-112, 1858, 4),

            Vector(224, 1758, 4),
            Vector(-224, 1758, 4),
            Vector(336, 1758, 4),
            Vector(-336, 1758, 4),
            Vector(448, 1758, 4),
            Vector(-448, 1758, 4),
            Vector(560, 1758, 4),
            Vector(-560, 1758, 4),
            Vector(224, 1858, 4),
            Vector(-224, 1858, 4),
            Vector(336, 1858, 4),
            Vector(-336, 1858, 4),
            Vector(448, 1858, 4),
            Vector(-448, 1858, 4),
            Vector(560, 1858, 4),
            Vector(-560, 1858, 4),
        }

        local player_spawns = ents.FindByClass("info_player_*")

        for _, ent in ipairs(player_spawns) do
            ent:Remove()
        end

        for _, pos in ipairs(new_positions) do
            local new_spawn = ents.Create("info_player_start")
            new_spawn:SetPos(pos)
            new_spawn:Spawn()
        end
    end
end)