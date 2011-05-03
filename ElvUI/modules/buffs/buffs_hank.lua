setfenv(1, select(2, ...))
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
-- Some useful global variables
-- _G.BUFFS_PER_ROW = .... (Default: 8)
-- _G.BUFF_ROW_SPACING = .... (Default: 0)
-- _G.BUFF_MIN_ALPHA = ... (Default: 0.3)
-- _G.BUFF_DURATION_WARNING_TIME = .... (Default: 60)

--SetCVar("consolidateBuffs", 1)

local UnitAura, unpack, select = UnitAura, unpack, select

local statusbars = {
        -- Width, height, anchorPoint, anchorTo, xOffset, yOffset, upper bound, orientation
        {15, 1, "TOPRIGHT", "TOP", 0, -1, 0.125, "horizontal"},
        {1, 30, "TOPLEFT", "TOPLEFT", 1, -1, 0.375, "vertical"},
        {30, 1, "BOTTOMLEFT", "BOTTOMLEFT", 1, 1, 0.625, "horizontal"},
        {1, 30, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1, 0.875, "vertical"},
        {15, 1, "TOPRIGHT", "TOPRIGHT", -1, -1, 1, "horizontal"}
}

local dragButton

local function UpdateButton(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed < 0.3 then return end
        
        -- Update "statusbar"
        local percent = self.timeLeft / self.durationMax
        
        -- THIS SO NEEDS SOME OPTIMIZATION!!!
        --[[for i = 1, 5 do
                local lowerBound, upperBound = i > 1 and statusbars[i - 1][7] or 0, statusbars[i][7]
                if percent > lowerBound and percent < upperBound then
                        if self.filter == "HARMFUL" then
                                self.statusbars[i]:SetVertexColor(unpack(colors["Green"]:GetBlend(colors["Red"], percent)))
                        else
                                self.statusbars[i]:SetVertexColor(unpack(colors["Red"]:GetBlend(colors["Green"], percent)))
                        end
                        
                        if statusbars[i][8] == "horizontal" then
                                self.statusbars[i]:SetSize(statusbars[i][1] * (percent - lowerBound) / (upperBound - lowerBound), 1)
                        else
                                self.statusbars[i]:SetSize(1, statusbars[i][2] * (percent - lowerBound) / (upperBound - lowerBound))
                        end
                        
                        self.statusbars[i]:Show()
                elseif percent > upperBound then
                        if self.filter == "HARMFUL" then
                                self.statusbars[i]:SetVertexColor(unpack(colors["Green"]:GetBlend(colors["Red"], percent)))
                        else
                                self.statusbars[i]:SetVertexColor(unpack(colors["Red"]:GetBlend(colors["Green"], percent)))
                        end
                        
                        self.statusbars[i]:SetSize(statusbars[i][1], statusbars[i][2])
                        self.statusbars[i]:Show()
                elseif percent < lowerBound then
                        self.statusbars[i]:Hide()
                end
        end]]
        
        
        self.elapsed = 0
end

local function UpdateDurationMax(button, index, filter)
        button.durationMax = select(6, UnitAura(UnitHasVehicleUI("player") and "pet" or "player", index, filter))
                
        if button.durationMax == 0 then
                for i = 1, 5 do
                        button.statusbars[i]:Hide()
                end
        end
end

local function CreateButton(name, index, filter)
        local button = _G[name .. index]
        
        if button and button:IsShown() then
        
                -- Skin button
                if not button.skinned then
                        local icon, oldBorder = _G[name .. index .. "Icon"], _G[name .. index .. "Border"]
                        
                        button:SetSize(32, 32)
                        
                        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        icon:SetPoint("TOPLEFT", 3, -3)
                        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        
                        button.duration:ClearAllPoints()
                        button.duration:SetPoint("BOTTOM", 0, -12)
                        button.duration:SetFontObject("BuffsFontNormal")
                        button.duration:SetTextColor(unpack(colors["White"]))
                        button.duration.SetVertexColor = function() end
                        button.duration:SetDrawLayer("ARTWORK")
        
                        button.count:ClearAllPoints()
                        button.count:SetPoint("TOPRIGHT", -1, -4)
                        button.count:SetFontObject("BuffsFontSmall")
                        button.count.SetFontObject = function() end
                        button.count:SetTextColor(unpack(colors["White"]))
                        button.count:SetDrawLayer("ARTWORK")
                        
                        if oldBorder then oldBorder:Hide() end
                        
                        local border = button:CreateTexture(nil, "BORDER", nil, 0)
                        border:SetAllPoints()
                        border:SetTexture(media.button["Buff"])
                        border:SetVertexColor(unpack(colors["Background light"]))
                        
                        button.statusbars = {}
                        for i = 1, 5 do
                                button.statusbars[i] = button:CreateTexture(nil, "BORDER", nil, 1)
                                button.statusbars[i]:SetTexture(media.background["Flat"])
                                button.statusbars[i]:SetVertexColor(unpack(colors["Green"]))
                                button.statusbars[i]:SetSize(statusbars[i][1], statusbars[i][2])
                                button.statusbars[i]:SetPoint(statusbars[i][3], button, statusbars[i][4], statusbars[i][5], statusbars[i][6])
                        end
                        
                        button.elapsed = 0
                        if button.timeLeft then button:HookScript("OnUpdate", UpdateButton) end
                        
                        -- Yo dawg, I herd you like unregistering scripts?
                        -- So I put a hook in your hook so I can update while you update.
                        hooksecurefunc(button, "SetScript", function(self, type, handler)
                                if type == "OnUpdate" then
                                        if handler ~= nil then
                                                if button.timeLeft then button:HookScript("OnUpdate", UpdateButton) end
                                        else
                                                for i = 1, 5 do button.statusbars[i]:Hide() end
                                        end
                                end
                        end)
                        
                        -- Drag ability
                        button:HookScript("OnMouseDown", function(self, button)
                                if button == "LeftButton" and IsAltKeyDown() then
                                        dragButton = self
                                        BuffFrame:StartMoving()
                                end
                        end)
                        
                        button:HookScript("OnMouseUp", function(self, _)
                                if dragButton == self then
                                        BuffFrame:StopMovingOrSizing()
                                end
                        end)
                        
                        button:HookScript("OnHide", function(self, _)
                                if dragButton == self then
                                        BuffFrame:StopMovingOrSizing()
                                end
                        end)
                        
                        button.skinned = true
                end
                
                -- Skinned, update max duration
                UpdateDurationMax(button, index, filter)

        end
end

-- Skin them
for i = 1, 3 do CreateButton("TempEnchant", i, nil) end
hooksecurefunc("AuraButton_Update", CreateButton)

-- Enchant offset fix
hooksecurefunc("TemporaryEnchantFrame_Update", function(...)
        local enchantsShown = 0
        for i = 1, 3 do
                if _G["TempEnchant" .. i]:IsShown() then enchantsShown = enchantsShown + 1 end
        end
        -- +2 (32 - 30)
        TemporaryEnchantFrame:SetWidth(enchantsShown * 34)
end)

-- Skin consolidated buffs button
local cb, cbIcon = _G.ConsolidatedBuffs, _G.ConsolidatedBuffsIcon
cb:SetSize(32, 32)

cbIcon:ClearAllPoints()
cbIcon:SetPoint("TOPLEFT", 3, -3)
cbIcon:SetPoint("BOTTOMRIGHT", -3, 3)
cbIcon:SetTexture(media.button["Embossed white"])
cbIcon:SetVertexColor(unpack(colors["Background light"]))

local border = cb:CreateTexture(nil, "BORDER")
border:SetAllPoints()
border:SetTexture(media.button["Buff"])
border:SetVertexColor(unpack(colors["Background light"]))

cb.count:SetDrawLayer("ARTWORK")
cb.count:ClearAllPoints()
cb.count:SetPoint("CENTER")
cb.count:SetFontObject("BuffsFontNormal")
cb.count:SetTextColor(unpack(colors["Signature color"]))

hooksecurefunc(cb.count, "SetText", function(self, val)
        if val and not tostring(val):find("%+") then
                self:SetText("+" .. tostring(val))
        end
end)

-- Consolidated buffs tooltip size fix
hooksecurefunc("ConsolidatedBuffs_UpdateAllAnchors", function()
        -- +2 (32 - 30)
        ConsolidatedBuffsTooltip:SetWidth(min(BuffFrame.numConsolidated * 26 + 18, 122))
        ConsolidatedBuffsTooltip:SetHeight(floor((BuffFrame.numConsolidated + 3) / 4 ) * (CONSOLIDATED_BUFF_ROW_HEIGHT + 2) + 16)
end)

-- Standard position
BuffFrame:ClearAllPoints()
BuffFrame:SetPoint("TOPRIGHT", MinimapBackdrop, "TOPLEFT", -20, -4)

-- Make buffs movable
BuffFrame:SetMovable(true)
BuffFrame:SetUserPlaced(true)