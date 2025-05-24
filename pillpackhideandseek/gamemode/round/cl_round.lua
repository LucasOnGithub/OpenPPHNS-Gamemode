
-- Moat text effects, https://github.com/Mikey-Howell/moat-texteffects/blob/master/moat_TextEffects.lua


	RunConsoleCommand("gmod_mcore_test", "1")
	RunConsoleCommand("mat_queue_mode", "2")
	RunConsoleCommand("cl_threaded_bone_setup", "1")
	RunConsoleCommand("cl_threaded_client_leaf_system", "1")
	RunConsoleCommand("r_threaded_client_shadow_manager", "1")
	RunConsoleCommand("r_threaded_particles", "1")
	RunConsoleCommand("r_threaded_renderables", "1")
	RunConsoleCommand("r_queued_ropes", "1")
	RunConsoleCommand("studio_queue_mode", "1")
	RunConsoleCommand("r_queued_props", "1")
	RunConsoleCommand("r_queued_ropes", "1")
	RunConsoleCommand("r_occludermincount", "1")

	hook.Add( "PreGamemodeLoaded", "widgets_disabler_cpu_client2", function()
		function widgets.PlayerTick()
			-- empty
		end

		hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
		hook.Remove("PostRender", "RenderFrameBlend")
		hook.Remove("PreRender", "PreRenderFrameBlend")
		hook.Remove("Think", "DOFThink")
		hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
		hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
		hook.Remove("PostDrawEffects", "RenderWidgets")
		hook.Remove("Think", "RenderHalos")
		hook.Remove( "PlayerTick", "TickWidgets" )
	end )






hook.Add("ContextMenuOpen", "DisableContextMenuForEveryoneButSuperAdmin", function()
    local ply = LocalPlayer()
    if not ply:IsSuperAdmin() then
        return false
    end
end)



--



local color_red = Color( 255, 0, 0 )

local function GetPlayersWithBadguyNot2()
    local playersFiltered = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWInt("badguy") ~= true then
            table.insert(playersFiltered, ply)
        end
    end
    return playersFiltered
end

local function GetPlayersWithBadguyNot3()
    local playersFiltered = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWInt("badguy") ~= true and ply:Team() ~= 1002 then
            table.insert(playersFiltered, ply)
        end
    end
    return playersFiltered
end

hook.Add( "PlayerFootstep", "DisableFootsteps2", function( ply, pos, foot, sound, volume, rf )
    if ply:GetNWBool("InPill") == false or ply:GetNWInt("badguy") == false then return end
	return true
end )

local cooldown = 0.5
local lastToggleTime = 0
CreateClientConVar("hide_beginner_hud", "0", true, false, "Hide beginner HUD")

local function KeyPress()
    if input.IsKeyDown(KEY_F11) then
    local curTime = CurTime()
    if curTime - lastToggleTime < cooldown then
        return
    end
    
    lastToggleTime = curTime
	    if GetConVar("hide_beginner_hud"):GetBool() == true then
		    LocalPlayer():ConCommand("hide_beginner_hud 0")
		else
		
	    LocalPlayer():ConCommand("hide_beginner_hud 1")
	    end
	end
end


hook.Add("Think","CloseHelpMenu",KeyPress)

hook.Add("HUDPaint", "BeginnerHUD", function()
    if GetConVar("hide_beginner_hud"):GetBool() == true then
        return
    end
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(10, 130, 260, 130)

     draw.SimpleText("Beginner Help Binds", "MiseryFont3", 20, 20 + 120, Color(255, 255, 255))
    draw.SimpleText("F1 - Third Person", "MiseryFont3", 20, 50 + 120, Color(255, 255, 255))
    -- draw.SimpleText("F2 - Shop/Inventory", "MiseryFont3", 20, 80 + 120, Color(255, 255, 255))
    -- draw.SimpleText("F3 - XP/Rank Menu", "MiseryFont3", 20, 110 + 120, Color(255, 255, 255))
    draw.SimpleText("F4 - Pill Night Vision", "MiseryFont3", 20, 80 + 120, Color(255, 255, 255))
    -- draw.SimpleText("F7 - Emote Menu", "MiseryFont3", 20, 170 + 120, Color(255, 255, 255))
    -- draw.SimpleText("I - Pill Rank Menu", "MiseryFont3", 20, 200 + 120, Color(255, 255, 255))

    draw.SimpleText("Press F11 to close this", "MiseryFont3", 20, 110 + 120, Color(255, 255, 65))
    if LocalPlayer():GetNWBool("InPill", false) or LocalPlayer():GetNWBool("badguy", false) then
        surface.DrawRect(ScrW() - 330, 30, 290, 250)

         draw.SimpleText("Seeker Help Binds", "MiseryFont3", ScrW() - 320, 20 + 20, Color(255, 255, 255))
        draw.SimpleText("Depends on Chosen Pill", "MiseryFont3", ScrW() - 320, 50 + 20, Color(255, 255, 255))
        draw.SimpleText("LMB - Attack/Jumpscare", "MiseryFont3", ScrW() - 320, 80 + 20, Color(255, 255, 255))
        draw.SimpleText("RMB - Climb Wall", "MiseryFont3", ScrW() - 320, 110 + 20, Color(255, 255, 255))
        draw.SimpleText("R - Music/Special Ability", "MiseryFont3", ScrW() - 320, 140 + 20, Color(255, 255, 255))
        draw.SimpleText("SPACE - Jump/Sound", "MiseryFont3", ScrW() - 320, 170 + 20, Color(255, 255, 255))
        draw.SimpleText("F - Extra Music/Sound", "MiseryFont3", ScrW() - 320, 200 + 20, Color(255, 255, 255))

        draw.SimpleText("Press F11 to close this", "MiseryFont3", ScrW() - 320, 230 + 20, Color(255, 255, 65))
    end
end)

hook.Add("PreDrawHalos", "AddPlayerHalos", function()
    if LocalPlayer():GetNWInt("last30seconds")  == 2 or LocalPlayer():GetNWInt("AftonH") == 2 then
        halo.Add(GetPlayersWithBadguyNot3(), color_red, 1, 1, 5, true, true)
	end
end)


local color_green = Color(255, 255, 255)

hook.Add("PreDrawHalos", "AddStaffHalos", function()
    local ghosts = ents.FindByClass("base_gmodentity")

    for _, ghost in pairs(ghosts) do
        if IsValid(ghost) and ghost:GetModel() == "models/errolliamp/fnaf_world/crying_child.mdl" then
            halo.Add({ghost}, color_green, 0, 0, 2, true)
        end
    end
end)

local GhostMark = {}

    net.Receive("GhostMark", function()
        local ent = net.ReadEntity()
		ent:EmitSound("marking.wav")
        GhostMark[ent] = true
    end)

    net.Receive("GhostMark2", function()
        local ent = net.ReadEntity()
        if GhostMark[ent] then
            GhostMark[ent] = nil
        end
    end)

    hook.Add("PreDrawHalos", "GhostHalos", function()
        halo.Add(table.GetKeys(GhostMark), Color(255, 255, 255), 5, 5, 2, true, true)
    end)

local function m_AlignText( text, font, x, y, xalign, yalign )

	surface.SetFont( font )

	local textw, texth = surface.GetTextSize( text )

	if ( xalign == TEXT_ALIGN_CENTER ) then

		x = x - ( textw / 2 )

	elseif ( xalign == TEXT_ALIGN_RIGHT ) then
		
		x = x - textw

	end

	if ( yalign == TEXT_ALIGN_BOTTOM ) then
		
		y = y - texth

	end

	return x, y

end

function DrawShadowedText( shadow, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	draw.SimpleText( text, font, x + shadow, y + shadow, Color( 0, 0, 0, color.a or 255 ), xalign, yalign )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end


function GlowColor( col1, col2, mod )

	local newr = col1.r + ( ( col2.r - col1.r ) * ( mod ) )

	local newg = col1.g + ( ( col2.g - col1.g ) * ( mod ) )

	local newb = col1.b + ( ( col2.b - col1.b ) * ( mod ) )

	return Color( newr, newg, newb )

end


function DrawEnchantedText( speed, text, font, x, y, color, glow_color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	local glow_color = glow_color or Color( 127, 0, 255 )

	local texte = string.Explode( "", text )

	local x, y = m_AlignText( text, font, x, y, xalign, yalign )

	surface.SetFont( font )

	local chars_x = 0

	for i = 1, #texte do

		local char = texte[i]

		local charw, charh = surface.GetTextSize( char )

		local color_glowing = GlowColor( glow_color, color, math.abs( math.sin( ( RealTime() - ( i * 0.08 ) ) * speed ) ) )

		draw.SimpleText( char, font, x + chars_x, y, color_glowing, xalign, yalign )

		chars_x = chars_x + charw

	end

end

function DrawFadingText( speed, text, font, x, y, color, fading_color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	local yalign = yalign or TEXT_ALIGN_TOP

	local color_fade = GlowColor(color, fading_color, math.abs(math.sin((RealTime() - 0.08) * speed)))

	local obfuscated_text = ""
	for i = 1, #text do
		if math.random(1,100) < 10 then
			obfuscated_text = obfuscated_text .. string.char(math.random(32, 126))
		else
			obfuscated_text = obfuscated_text .. text:sub(i, i)
		end
	end

	draw.SimpleText(obfuscated_text, font, x, y, color_fade, xalign, yalign)

end


local col1 = Color( 0, 0, 0 )

local col2 = Color( 255, 255, 255 )

local next_col = 0

function DrawRainbowText( speed, text, font, x, y, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	next_col = next_col + 1 / ( 100 / speed )

	if ( next_col >= 1 ) then 

		next_col = 0

		col1 = col2

		col2 = ColorRand()

	end

	draw.SimpleText( text, font, x, y, GlowColor( col1, col2, next_col ), xalign, yalign )

end

function DrawEnhancedRainbowText( speed, text, font, x, y, xalign, yalign, saturated)

	local xalign = xalign or TEXT_ALIGN_LEFT

	local yalign = yalign or TEXT_ALIGN_TOP

	local saturated = saturated or false

	local texte = string.Explode( "", text )

	local x, y = m_AlignText( text, font, x, y, xalign, yalign )

	surface.SetFont( font )

	local chars_x = 0

	for i = 1, #texte do

		local char = texte[i]

		local charw, charh = surface.GetTextSize( char )

		local time = RealTime() - (i * 0.08)

		local r = math.sin(time * (speed * 1.5) + 0) * 127 + 128

		local g = math.sin(time * (speed * 1.5) + 2) * 127 + 128

		local b = math.sin(time * (speed * 1.5) + 4) * 127 + 128

		if saturated == true then
			r = math.sin(time * (speed * 1.5) + 0) / 127
			g = math.sin(time * (speed * 1.5) + 2) / 127
			b = math.sin(time * (speed * 1.5) + 4) / 127
		end

		draw.SimpleText( char, font, x + chars_x, y, Color(r, g, b), xalign, yalign )

		chars_x = chars_x + charw

	end

end


function DrawGlowingText( static, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local initial_a = 20

	local a_by_i = 5

	local alpha_glow = math.abs( math.sin( ( RealTime() - 0.1 ) * 2 ) )

	if ( static ) then alpha_glow = 1 end

	for i = 1, 5 do

		draw.SimpleTextOutlined( text, font, x, y, color, xalign, yalign, i, Color( color.r, color.g, color.b, ( initial_a - ( i * a_by_i ) ) * alpha_glow ) )

	end

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end


function DrawBouncingText( style, intesity, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local texte = string.Explode( "", text )

	surface.SetFont( font )

	local chars_x = 0

	local x, y = m_AlignText( text, font, x, y, xalign, yalign )

	for i = 1, #texte do

		local char = texte[i]

		local charw, charh = surface.GetTextSize( char )

		local y_pos = 1

		local mod = math.sin( ( RealTime() - ( i * 0.1 ) ) * ( 2 * intesity ) )

		if ( style == 1 ) then

			y_pos = y_pos - math.abs( mod )

		elseif ( style == 2 ) then
			
			y_pos = y_pos + math.abs( mod )

		else

			y_pos = y_pos - mod

		end

		draw.SimpleText( char, font, x + chars_x, y - ( 5 * y_pos ), color, xalign, yalign )

		chars_x = chars_x + charw

	end

end

local next_electic_effect = CurTime() + 0

local electric_effect_a = 0

function DrawElecticText( intensity, text, font, x, y, color, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local charw, charh = surface.GetTextSize( text )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

	if ( electric_effect_a > 0 ) then
		
		electric_effect_a = electric_effect_a - ( 1000 * FrameTime() )

	end

	surface.SetDrawColor( 102, 255, 255, electric_effect_a )

	for i = 1, math.random( 5 ) do

		line_x = math.random( charw )

		line_y = math.random( charh )

		line_x2 = math.random( charw )

		line_y2 = math.random( charh )

		surface.DrawLine( x + line_x, y + line_y, x + line_x2, y + line_y2 )

	end

	local effect_min = 0.5 + ( 1 - intensity )

	local effect_max = 1.5 + ( 1 - intensity )

	if ( next_electic_effect <= CurTime() ) then

		next_electic_effect = CurTime() + math.Rand( effect_min, effect_max )
		
		electric_effect_a = 255

	end

end


function DrawFireText( intensity, text, font, x, y, color, xalign, yalign, glow, shadow )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	surface.SetFont( font )

	local charw, charh = surface.GetTextSize( text )

	local fire_height = charh * intensity

	for i = 1, charw do
		
		local line_y = math.random( fire_height, charh )

		local line_x = math.random( -4, 4 )

		local line_col = math.random( 255 )

		surface.SetDrawColor( 255, line_col, 0, 150 )

		surface.DrawLine( x - 1 + i, y + charh, x - 1 + i + line_x, y + line_y )

	end

	if ( glow ) then
		
		DrawGlowingText( true, text, font, x, y, color, xalign, yalign )

	end

	if ( shadow ) then

		draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0 ), xalign, yalign )

	end

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

end

function DrawSnowingText( intensity, text, font, x, y, color, color2, xalign, yalign )

	local xalign = xalign or TEXT_ALIGN_LEFT
	
	local yalign = yalign or TEXT_ALIGN_TOP

	local color2 = color2 or Color( 255, 255, 255 )

	draw.SimpleText( text, font, x, y, color, xalign, yalign )

	surface.SetFont( font )

	local textw, texth = surface.GetTextSize( text )

	surface.SetDrawColor( color2.r, color2.g, color2.b, 255 )

	for i = 1, intensity do
		
		local line_y = math.random( 0, texth )

		local line_x = math.random( 0, textw )

		surface.DrawLine( x + line_x, y + line_y, x + line_x, y + line_y + 1 )

	end

end













hook.Add("PlayerBindPress", "ToggleThirdPersonBind", function(ply, bind, pressed)

	if bind == "gm_showhelp" and pressed and ply:GetNWInt("badguy") == true then
	
	    if GetConVar("pk_pill_cl_thirdperson"):GetInt() == 1 then
            ply:ConCommand("pk_pill_cl_thirdperson 0")
        else
            ply:ConCommand("pk_pill_cl_thirdperson 1")
		
		
		end
		return true
	end
    if bind == "gm_showhelp" and pressed then
        RunConsoleCommand("simple_thirdperson_enable_toggle")
        return true -- Prevent the default action of the bind
    end
end)


local round_status = 0

net.Receive("UpdateRoundStatus",function(len)

    round_status = net.ReadInt(4)

end)

	surface.CreateFont("MiseryFont", {
		font = "Misery",
		extended = false,
		size = 50,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	
	surface.CreateFont("MiseryFont2", {
		font = "Misery",
		extended = false,
		size = 25,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont("MiseryFont3", {
		font = "Misery",
		extended = false,
		size = 20,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	
	surface.CreateFont("MiseryFont4", {
		font = "Misery",
		extended = false,
		size = 18,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	surface.CreateFont("MiseryFont5", {
		font = "Misery",
		extended = false,
		size = 16,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	
	
function getRoundStatus()

    return round_status

end


local roundTime = 0
local remainingTime = 0
local curtimee = 0
local endroundtext = false
local orangec = Color(255, 0, 0)
local orangec2 = Color(220,20,60)
local orangeco = Color(247, 197, 14)
local nightmarec = Color(105,105,105)
local nightmarec2 = Color(150,150,150, 255)
local redcolor = Color(255,0,0)
local redcolor2 = Color(128,0,128)
local darkredcolor = Color(200,0,0)
local darkredcolor2 = Color(100,0,0)
local whitecolor = Color(35,35,35)
local yellowcolor = Color(238,232,170)
-- local yellowcolor = Color(196,185,73)
local yellowc2 = Color(228, 197, 0)
local brownc = Color(159, 119, 0)
local bluecolor = Color(88,0,128)
local roundTimer = 0
local lastFrameTime = RealTime()
local swingSpeed = 1 -- Speed of the swinging effect
local swingAmplitude = 15 -- Maximum angle for the swinging effect

function drawNextRoundTimer()
    
    local curTime = RealTime()
    
    local deltaTime = curTime - lastFrameTime
    lastFrameTime = curTime
    
    roundTimer = math.max(0, roundTimer - deltaTime)

    local minutes = math.floor(roundTimer / 60)
    local seconds = math.floor(roundTimer % 60)
    local milliseconds = math.floor((roundTimer - math.floor(roundTimer)) * 100)

    local timerText = string.format("%02d:%02d:%02d", minutes, seconds, milliseconds)

    surface.SetFont("MiseryFont") -- standard font
    local textWidth, textHeight = surface.GetTextSize(timerText)

    -- The position for the timer text is to be centered at the top-middle of the screen as shown here
    local xPos = ScrW() / 2.2 - 25
    local yPos = 20
    //local players = #GetPlayersWithBadguyNot2()
    //local numPlayers = #players 
    local boxWidth = 340
    local boxHeight = textHeight + 50
    local boxX = xPos - 5 - 50
    local boxY = yPos - 10
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(boxX, boxY, boxWidth, boxHeight + 20)
    if endroundtext == true then
        draw.DrawText("Round Over", "MiseryFont", xPos - 40, yPos + 40, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Ignited" then
        DrawEnchantedText(3, timerText, "MiseryFont", xPos, yPos + 35, orangeco, orangec, TEXT_ALIGN_LEFT)
        DrawEnchantedText(3, "Ignited", "MiseryFont2", xPos + 53, yPos, orangeco, orangec, TEXT_ALIGN_LEFT) -- Ignited
		DrawEnchantedText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, orangeco, orangec, TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Nightmare" then
        DrawEnchantedText(3, timerText, "MiseryFont", xPos, yPos + 35, nightmarec, nightmarec2, TEXT_ALIGN_LEFT)
        DrawEnchantedText(3, "Nightmare", "MiseryFont2", xPos + 37, yPos, nightmarec, nightmarec2, TEXT_ALIGN_LEFT) -- Nightmare
		DrawEnchantedText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, nightmarec, nightmarec2, TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Poppy" then
        DrawEnhancedRainbowText(3, timerText, "MiseryFont", xPos, yPos + 35, TEXT_ALIGN_LEFT) -- was DrawRainbowText(0.75, ...)
        DrawEnhancedRainbowText(3, "The Hour of Joy", "MiseryFont2", xPos + 7, yPos, TEXT_ALIGN_LEFT, true) -- Hour of Joy
		DrawEnhancedRainbowText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, TEXT_ALIGN_LEFT)
    elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Twisted" then
        DrawGlowingText(false, timerText, "MiseryFont", xPos, yPos + 35, nightmarec, TEXT_ALIGN_LEFT)
        DrawGlowingText(false, "The Twisted Ones", "MiseryFont2", xPos, yPos, nightmarec, TEXT_ALIGN_LEFT) -- The Twisted Ones
		DrawGlowingText(false, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, nightmarec, TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Glitch" then
        DrawEnchantedText(9, timerText, "MiseryFont", xPos, yPos + 35, yellowcolor, redcolor2, TEXT_ALIGN_LEFT)
        DrawEnchantedText(9, "The Anomaly", "MiseryFont2", xPos + 25, yPos, yellowcolor, redcolor2, TEXT_ALIGN_LEFT) -- The Anomaly
		DrawEnchantedText(9, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, yellowcolor, redcolor2, TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Shadow" then
        DrawFadingText(3, timerText, "MiseryFont", xPos, yPos + 35, nightmarec, nightmarec2, TEXT_ALIGN_LEFT)
        DrawFadingText(3, "Fear the Shadow", "MiseryFont2", xPos + 5, yPos, nightmarec, nightmarec2, TEXT_ALIGN_LEFT) -- Fear The Shadow
		DrawFadingText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, nightmarec, nightmarec2, TEXT_ALIGN_LEFT)
	elseif roundTimer > 0 and roundState == ROUND_ACTIVE and GetGlobalString("RoundType") == "Afton" then
        DrawEnchantedText(3, timerText, "MiseryFont", xPos, yPos + 35, redcolor, redcolor2, TEXT_ALIGN_LEFT)
        DrawEnchantedText(3, "The Man Behind The Slaughter", "MiseryFont3", xPos + 120, yPos, redcolor, redcolor2, TEXT_ALIGN_CENTER) -- The Man Behind The Slaughter
		DrawEnchantedText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, redcolor, redcolor2, TEXT_ALIGN_LEFT)
    elseif roundTimer > 0 and roundState == ROUND_ACTIVE then
        DrawEnchantedText(3, timerText, "MiseryFont", xPos, yPos + 35, orangec, orangec2, TEXT_ALIGN_LEFT)
        DrawEnchantedText(3, "Hide and Seek", "MiseryFont2", xPos + 30, yPos, orangec, orangec2, TEXT_ALIGN_LEFT) -- Hide and Seek (to be used with ashop's "commandes")
		DrawEnchantedText(3, "Players left: " .. #GetPlayersWithBadguyNot3(), "MiseryFont2", xPos + 10, yPos + 80, orangec, orangec2, TEXT_ALIGN_LEFT)
		
    else
        draw.DrawText("Waiting for round..", "MiseryFont2", xPos - 15, yPos + 45, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    end
end


function ResetRemainingRoundTime()
    roundTimer = GetGlobalInt("roundtimer", 0)
	roundTimer = 600
end

function ResetRemainingRoundTime2()
    roundTimer = 0
    remainingTime = GetGlobalInt("roundtimer", 0)
end

net.Receive("ResetRoundTimer", function()
    chat.AddText(Color(100, 100, 255), "Round started, survivors must last 10 minutes, RUN OR HIDE!")
	surface.PlaySound("mysterious_perc_02.wav")

	timer.Simple(2, function()
		local roundType = GetGlobalString("RoundType")

		if roundType == "Twisted" then
			surface.PlaySound("dreamscape.mp3")
		elseif roundType == "Glitch" then
			surface.PlaySound("glitchround.mp3")
		elseif roundType == "Afton" then
			surface.PlaySound("afton2.mp3")
		elseif roundType == "Shadow" then
			surface.PlaySound("shadowtrapmusic.mp3")
		else
			if math.random(1,5) == 1 then
				surface.PlaySound("amb2.mp3")
			elseif math.random(1,4) == 1 then
				surface.PlaySound("amb1.mp3")
			elseif math.random(1,3) == 1 then
				surface.PlaySound("amb3.mp3")
			elseif math.random(1,2) == 1 then
				surface.PlaySound("amb4.mp3")
			else
			
				surface.PlaySound("fnaf3ambient.mp3")
			end
			-- end
		end
	end)

    roundTimer = GetGlobalInt("roundtimer", 0)
	roundTimer = 600

    ResetRemainingRoundTime()
end)

net.Receive( "StarChaseRound", function()
    if IsValid(LocalPlayer()) then
         LocalPlayer():StopSound( "fnaf3ambient.mp3" )
         LocalPlayer():StopSound( "dreamscape.mp3" )
         LocalPlayer():StopSound( "amb1.mp3" )
         LocalPlayer():StopSound( "amb2.mp3" )
         LocalPlayer():StopSound( "amb3.mp3" )
         LocalPlayer():StopSound( "amb4.mp3" )
		 LocalPlayer():StopSound("GENTOI_LAST_30_SECS.mp3")
		 LocalPlayer():StopSound("shadowtrapmusic.mp3")
		 LocalPlayer():StopSound("afton2.mp3")
		 LocalPlayer():StopSound("glitchround.mp3")
	end
    chat.AddText( Color( 100, 100, 255 ), "Round starts in 30 seconds, find a spot to hide!" )
	endroundtext = false
	timer.Simple(0.1, function()
	
	surface.PlaySound("ambient_mp3/spacebase/spacebase_bang_0" .. math.random(1,4) .. ".mp3")
	end )
	timer.Simple(0.40, function()
		if GetGlobalString("RoundType") == "Glitch" then
			surface.PlaySound("30timer.mp3")
		else
			surface.PlaySound("GENTOI_SCARY_BUILD.mp3")
		end
	end)
	timer.Simple(5, function() surface.PlaySound("ambient_mp3/spacebase/spacebase_rumble_0" .. math.random(1,9) .. ".mp3") end )
end )

net.Receive( "FirstRoundMsg", function()
    if IsValid(LocalPlayer()) then
         LocalPlayer():StopSound( "fnaf3ambient.mp3" )
         LocalPlayer():StopSound( "dreamscape.mp3" )
         LocalPlayer():StopSound( "amb1.mp3" )
         LocalPlayer():StopSound( "amb2.mp3" )
         LocalPlayer():StopSound( "amb3.mp3" )
         LocalPlayer():StopSound( "amb4.mp3" )
		 LocalPlayer():StopSound("GENTOI_LAST_30_SECS.mp3")
		 LocalPlayer():StopSound("shadowtrapmusic.mp3")
		 LocalPlayer():StopSound("afton2.mp3")
		 LocalPlayer():StopSound("glitchround.mp3")
	end
    chat.AddText( Color( 100, 100, 255 ), "Round starts in 90 seconds, find a spot to hide!" )
	endroundtext = false
	timer.Simple(0.05, function()
	
	surface.PlaySound("ambient_mp3/spacebase/spacebase_bang_0" .. math.random(1,4) .. ".mp3")
	end )
	timer.Simple(0.33, function()
		if GetGlobalString("RoundType") == "Glitch" then
			surface.PlaySound("30timer.mp3")
		else
			surface.PlaySound("GENTOI_SCARY_BUILD.mp3")
		end
	end)
	timer.Simple(5, function() surface.PlaySound("ambient_mp3/spacebase/spacebase_rumble_0" .. math.random(1,9) .. ".mp3") end )
end )

net.Receive( "StarChaseRound2", function()

    chat.AddText( Color( 100, 100, 255 ), "Round ended!" )
	remainingTime = 0
	endroundtext = true
	surface.PlaySound("ambient_mp3/spacebase/spacebase_bang_0" .. math.random(1,4) .. ".mp3")
	ResetRemainingRoundTime2()
	//timer.Simple(5, function() surface.PlaySound("ambient_mp3/spacebase/spacebase_rumble_0" .. math.random(1,9) .. ".mp3") end )
end )

net.Receive( "StarChaseRound3", function()

    chat.AddText( Color( 100, 100, 255 ), "A rare round is beginning.." )
    chat.AddText( Color( 0, 255, 0 ), "Double point gain and 2x elo gain for this round!" )
end )

net.Receive( "StarChaseRound4", function()
    chat.AddText( Color( 100, 100, 255 ), "A ULTRA RARE round is beginning.." )
	chat.AddText( Color( 0, 255, 0 ), "There is only a max of 3 very powerful seekers..." )
    chat.AddText( Color( 0, 255, 0 ), "5x point gain and 3x elo gain for this round!" )
end )

net.Receive( "StarChaseRound5", function()
    chat.AddText( Color( 100, 100, 255 ), "A UNIQUE round is beginning.." )
	chat.AddText( Color( 0, 255, 0 ), "Overwhelm Afton and spring lock him to win the round early or hide until the timer is up." )
	chat.AddText( Color( 0, 255, 0 ), "Spring locking afton rewards 2500 points to the children." )
    chat.AddText( Color( 0, 255, 0 ), "2x point gain and 1.5x elo gain for this round!" )
end )

net.Receive( "StarChaseRound6", function()
    chat.AddText( Color( 100, 100, 255 ), "A UNIQUE round is beginning.." )
	chat.AddText( Color( 0, 255, 0 ), "Vanny is on the lose, looking for prey to bring back to Glitchtrap." )
	chat.AddText( Color( 0, 255, 0 ), "If Glitchtrap merges with a player, he bcomes faster and the player turns into a random seeker.." )
    chat.AddText( Color( 0, 255, 0 ), "4x point gain and 2x elo gain for this round!" )
end )


net.Receive( "OpenDonateUrl", function()
    gui.OpenURL( "https://www.example.com" ) -- put your own donation URL here.
	print("OpeningStore")
end )

net.Receive( "roundending", function()


    surface.PlaySound("GENTOI_LAST_30_SECS.mp3")
end )

net.Receive( "joininround", function()


if GetGlobalString("RoundType") == "Twisted" then 
     surface.PlaySound("dreamscape.mp3") 
elseif GetGlobalString("RoundType") == "Afton" then 
     surface.PlaySound("afton2.mp3") 
elseif GetGlobalString("RoundType") == "Shadow" then 
     surface.PlaySound("shadowtrapmusic.mp3") 
elseif GetGlobalString("RoundType") == "Glitch" then 
     surface.PlaySound("glitchround.mp3") 
else      
			    if math.random(1,5) == 1 then
				    surface.PlaySound("amb2.mp3")
			    elseif math.random(1,4) == 1 then
				    surface.PlaySound("amb1.mp3")
			    elseif math.random(1,3) == 1 then
				    surface.PlaySound("amb3.mp3")
			    elseif math.random(1,2) == 1 then
				    surface.PlaySound("amb4.mp3")
				else
				
                    surface.PlaySound("fnaf3ambient.mp3")
				end
				-- end
end

roundTimer = GetGlobalInt("TimerFix")

end )


hook.Add("HUDPaint", "DrawTimer", drawNextRoundTimer)








-- NV



local function GenDynLight(color)
  local dlight = DynamicLight(963001)
  if dlight then
    if color == 1 then --red
      dlight.r = 60
      dlight.g = 0
      dlight.b = 0
    elseif color == 2 then --blue
      dlight.r = 0
      dlight.g = 0
      dlight.b = 60
    elseif color == 3 then --purple
      dlight.r = 30
      dlight.g = 0
      dlight.b = 30
    elseif color == 4 then --yellow
      dlight.r = 30
      dlight.g = 30
      dlight.b = 0
    elseif color == 5 then --turquoise
      dlight.r = 0
      dlight.g = 30
      dlight.b = 30
    elseif color == 6 then --orange
      dlight.r = 45
      dlight.g = 15
      dlight.b = 0
    elseif color == 7 then --white
      dlight.r = 20
      dlight.g = 20
      dlight.b = 20
    else --green
      dlight.r = 0
      dlight.g = 60
      dlight.b = 0
    end
  end
  return dlight
end

local function GetColorTab(color)
  local tab = {
    ["$pp_colour_brightness"] = 0.75,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 0.15,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
  }
  if color == 1 then --red
    tab["$pp_colour_addr"] = 0
    tab["$pp_colour_addg"] = -1
    tab["$pp_colour_addb"] = -1
  elseif color == 2 then --blue
    tab["$pp_colour_addr"] = -1
    tab["$pp_colour_addg"] = -1
    tab["$pp_colour_addb"] = 0
  elseif color == 3 then --purple
    tab["$pp_colour_addr"] = -0.5
    tab["$pp_colour_addg"] = -1
    tab["$pp_colour_addb"] = -0.5
  elseif color == 4 then --yellow
    tab["$pp_colour_addr"] = -0.5
    tab["$pp_colour_addg"] = -0.5
    tab["$pp_colour_addb"] = -1
  elseif color == 5 then --turquoise
    tab["$pp_colour_addr"] = -1
    tab["$pp_colour_addg"] = -0.5
    tab["$pp_colour_addb"] = -0.5
  elseif color == 6 then --orange
    tab["$pp_colour_addr"] = -0.25
    tab["$pp_colour_addg"] = -0.75
    tab["$pp_colour_addb"] = -1
  elseif color == 7 then --white
    tab["$pp_colour_addr"] = -0.66
    tab["$pp_colour_addg"] = -0.66
    tab["$pp_colour_addb"] = -0.66
  else --green
    tab["$pp_colour_addr"] = -1
    tab["$pp_colour_addg"] = 0
    tab["$pp_colour_addb"] = -1
  end
  return tab
end

hook.Add("RenderScreenspaceEffects", "NVFilter", function()
  local ply = LocalPlayer()
  if ply:GetNWBool("NV") == true then
    local tr = ply:GetEyeTraceNoCursor()
    DrawColorModify(GetColorTab(0))
    DrawSharpen(1, 1)
  end
end)

hook.Add("Think", "NVLight", function()
  local ply = LocalPlayer()
  if ply:GetNWBool("NV") == true then
    local tr = ply:GetEyeTraceNoCursor()
  	local dlight = GenDynLight(0)
    if dlight then
      dlight.pos = tr.StartPos - tr.Normal*15
  		dlight.brightness = 1
      dlight.size = 10000
  		dlight.decay = 10000
  		dlight.dieTime = CurTime() + 1
      dlight.style = 0
    end
  end
end)


hook.Add("SetupWorldFog", "CustomWorldFog", function()
    if GetGlobalString("RoundType") == "Twisted" then
    render.FogMode(MATERIAL_FOG_LINEAR)
    render.FogStart(1000)
    render.FogEnd(2000)
    render.FogColor(10, 10, 10) -- Black color
    return true
	end
end)

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = -0.1,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 0,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = -0.001,
	[ "$pp_colour_contrast" ] = 1.5,
	[ "$pp_colour_colour" ] = 0,
	[ "$pp_colour_mulr" ] = 100,
	[ "$pp_colour_mulg" ] = 100,
	[ "$pp_colour_mulb" ] = 0
}

	local NoiseTexture = Material("filmgrain/noise")
	local NoiseTexture2 = Material("filmgrain/noiseadd")
hook.Add( "RenderScreenspaceEffects", "color_modify_grey", function()
if GetGlobalString("RoundType") == "Twisted" then
	DrawColorModify( tab )
elseif GetGlobalString("RoundType") == "Shadow"  then
       //DrawColorModify( tab2 )
        surface.SetMaterial(NoiseTexture)
        surface.SetDrawColor(255, 255, 255, 13)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		
		surface.SetMaterial(NoiseTexture2)
        surface.SetDrawColor(255, 255, 255, 13*10)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end
end )



local dodelete = 0
local matb = Material("xbleed")
local matb1 = Material("x_symbol.png")
local matb2 = Material("skullbones.png")
local matb3 = Material("deathcircle.png")

local disablefeed = true

hook.Add("DrawDeathNotice", "DisableKills", function()
	if disablefeed then
		return 0,0
	end
end)

net.Receive("playerleftui", function(len)
    -- Define variables
	    dodelete = 0
    local avatarSize = 32
    local spacing = 5
    local players = GetPlayersWithBadguyNot3()
    local numPlayers = #players
    local totalWidth = numPlayers * (avatarSize + spacing) - spacing

    local posY = ScrH() * 0.125
    local startX = (ScrW() - totalWidth) / 2

    for i, ply in ipairs(players) do
        local posX = startX + (i - 1) * (avatarSize + spacing)

        local avatarPanel = vgui.Create("CircularAvatar")
        avatarPanel:SetSize(avatarSize, avatarSize)
        avatarPanel:SetPos(posX, posY)
        avatarPanel:SetPlayer(ply, 32)
        avatarPanel.PlayerEntity = ply
        avatarPanel.PaintOver = function(self, w, h)
		    if dodelete == 1 then avatarPanel:Remove() end
			if not IsValid(avatarPanel.PlayerEntity) then avatarPanel:Remove() end
            if IsValid(avatarPanel.PlayerEntity) and avatarPanel.PlayerEntity:Team() == 1002 then
			    if avatarPanel.PlayerEntity:IsBot() then
				    surface.SetDrawColor(255, 255, 255, 205)  -- should be white with most opacity
				else
				
                surface.SetDrawColor(255, 255, 255, 25)  -- should be white with least opacity
				end
                surface.SetMaterial(matb3)
                surface.DrawTexturedRect(0, 0, 32, 32)  -- should be over the entire panel
                surface.SetDrawColor(255, 255, 255, 255)  -- should be white with full opacity
				-- surface.SetMaterial(matb1)
                -- surface.DrawTexturedRect(0, 0, 32, 32)  -- should be over the entire panel
				-- !!comment the code above and uncomment the code below to use the static x symbol instead of the animated one.
                surface.SetMaterial(matb)
                surface.DrawTexturedRect(-16, -16, 64, 64)  -- should be over the entire panel
            end
        end
    end
end)

net.Receive("playerleftui2", function()

dodelete = 1
end )


hook.Add("HUDShouldDraw", "DisableDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" then
        return false -- false to disable the default HUD
    end
end)







local cooldownTime = 1
local lastVoiceTime = {}






local lastTexture = nil
local mat_Overlay = Material("vhs/vhsover")
local vhs = Material("vhs/vhsover")
local function DrawMaterialOverlay( texture, refractamount )

	


	render.UpdateScreenEffectTexture()

	mat_Overlay:SetFloat("$envmap",			0)
	mat_Overlay:SetFloat("$envmaptint",		0)
	mat_Overlay:SetFloat("$refractamount",	0.3)
	mat_Overlay:SetInt("$ignorez",		1)

	render.SetMaterial( mat_Overlay )
	render.DrawScreenQuad()
	
end

local function DrawInternal()


    if GetGlobalString("RoundType") == "Afton" then

	DrawMaterialOverlay( 
			true, 
			0.3	);
			
	end

end

hook.Add( "RenderScreenspaceEffects", "RenderMaterialOverlay", DrawInternal )



-- Post-processing to darken the screen


