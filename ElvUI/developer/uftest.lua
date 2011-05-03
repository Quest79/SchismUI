local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = function()
	for _, frames in pairs({"ElvDPS_player", "ElvDPS_target", "ElvDPS_targettarget", "ElvDPS_pet", "ElvDPS_focus", "ElvDPSBoss1", "ElvDPSMainTank", "ElvuiDPSParty"}) do
		_G[frames].unit = "player"
		_G[frames].Hide = function() end
		_G[frames]:Show()
	end
    --[[
    for _, frames in pairs({"ElvDPS_Arena", "ElvDPS_ArenaUnitButton"}) do
        for i = 1, 5 do
            _G[frames..i].Hide = function() end
            _G[frames..i].unit = "player"
            _G[frames..i]:Show()
        end
    end
    --]]--[[
    for _, frames in pairs({"ElvuiDPSR6R25"}) do
        _G[frames].Hide = function() end
        _G[frames].unit = "player"
        _G[frames]:Show()
    end
	--]]--[[
    for _, frames in pairs({"ElvuiDPSR6R25UnitButton"}) do
        for i = 1, 25 do
		_G[frames..i]:Show()
		_G[frames..i].unit = "player"
            _G[frames..i].Hide = function() end
        end
    end
	--]]
end

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
		ElvDPSArena1:Show(); ElvDPSArena1.Hide = function() end; ElvDPSArena1.unit = "player"
		ElvDPSArena2:Show(); ElvDPSArena2.Hide = function() end; ElvDPSArena2.unit = "player"
		ElvDPSArena3:Show(); ElvDPSArena3.Hide = function() end; ElvDPSArena3.unit = "player"
		ElvDPSArena4:Show(); ElvDPSArena4.Hide = function() end; ElvDPSArena4.unit = "player"
		ElvDPSArena5:Show(); ElvDPSArena5.Hide = function() end; ElvDPSArena5.unit = "player"
	elseif msg == "boss" or msg == "b" then
		ElvDPSBoss1:Show(); ElvDPSBoss1.Hide = function() end; ElvDPSBoss1.unit = "player"
		ElvDPSBoss2:Show(); ElvDPSBoss2.Hide = function() end; ElvDPSBoss2.unit = "player"
		ElvDPSBoss3:Show(); ElvDPSBoss3.Hide = function() end; ElvDPSBoss3.unit = "player"
	--elseif msg == "party" or msg == "p" then
		--ElvDPSParty:Show(); ElvDPSParty.Hide = function() end; ElvDPSParty.unit = "player"
		--ElvDPSPartyUnitButton1:Show(); ElvDPSPartyUnitButton1.Hide = function() end; ElvDPSPartyUnitButton1.unit = "player"
		--ElvDPSPartyUnitButton2:Show(); ElvDPSPartyUnitButton2.Hide = function() end; ElvDPSPartyUnitButton2.unit = "player"
		--ElvDPSPartyUnitButton3:Show(); ElvDPSPartyUnitButton3.Hide = function() end; ElvDPSPartyUnitButton3.unit = "player"
		--ElvDPSPartyUnitButton4:Show(); ElvDPSPartyUnitButton4.Hide = function() end; ElvDPSPartyUnitButton4.unit = "player"
	--elseif msg == "pet" or msg == "pe" then
		--ElvDPS_Pet:Show(); ElvDPS_Pet.Hide = function() end; ElvDPS_Pet.unit = "player"
	--elseif msg == "raid" or msg == "r" then
		--ElvuiDPSR6R25Unit2:Show(); ElvuiDPSR6R25Unit2.Hide = function() end; ElvuiDPSR6R25Unit2.unit = "player"
		--ElvuiDPSR6R25UnitButton1:Show() ElvuiDPSR6R25UnitButton1.Hide = function() end; ElvuiDPSR6R25UnitButton1.unit = "player"
		--ElvuiDPSR6R25UnitButton2.unit = "player" ElvuiDPSR6R25UnitButton2:Show() ElvuiDPSR6R25UnitButton2.Hide = function() end;
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
            -- name, rank, texture, count, dtype, duration, timeLeft, caster
            return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
	end
	
	if(oUF) then
            for i, v in pairs(oUF.units) do
                if(v.UNIT_AURA) then
                    v:UNIT_AURA("UNIT_AURA", v.unit)
                end
            end
        end
    end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"