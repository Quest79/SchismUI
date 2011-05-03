------------------------------------------------------------------------
--	ActionBar Functions
------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

function E.ElvuiPetBarUpdate(self, event)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end			
		end
		
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end
		
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		
		-- grid display
		if name then
			if not C["actionbar"].showgrid then
				petActionButton:SetAlpha(1)
			end			
		else
			if not C["actionbar"].showgrid then
				petActionButton:SetAlpha(0)
			end
		end
		
		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end
		
		-- between level 1 and 10 on cata, we don't have any control on Pet. (I lol'ed so hard)
		-- Setting desaturation on button to true until you learn the control on class trainer.
		-- you can at least control "follow" button.
		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(0)
		end
	end
end

function E.ElvuiShiftBarUpdate()
	local numForms = GetNumShapeshiftForms()
	local texture, name, isActive, isCastable
	local button, icon, cooldown
	local start, duration, enable
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ShapeshiftButton"..i]
		icon = _G["ShapeshiftButton"..i.."Icon"]
		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)
			
			cooldown = _G["ShapeshiftButton"..i.."Cooldown"]
			if texture then
				cooldown:SetAlpha(1)
			else
				cooldown:SetAlpha(0)
			end
			
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_SetTimer(cooldown, start, duration, enable)
			
			if isActive then
				ShapeshiftBarFrame.lastSelected = button:GetID()
				button:SetChecked(1)
			else
				button:SetChecked(0)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end



--[[
function SetActiveInactive(frame)
	frame:SetScript("OnEnter", function(self)
			UIFrameFadeIn(frame, .5) 
	end)
	
	frame:SetScript("OnLeave", function(self)
			UIFrameFadeOut(frame, .5)
	end)
end
--]]

function SetActive(frame)
   frame:SetScript("OnUpdate", function(self, elapsed)
         local current = GetMouseFocus()
          
         -- Scan through the parent chain
         while current ~= nil do
            if current == frame then
               UIFrameFadeOut(frame, .1, 1, 1) 
               return
            end
             
            current = current:GetParent()
         end
		 
   end)     
end




--UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)

function E.PositionAllPanels()
	ElvuiActionBarBackground:ClearAllPoints()
	ElvuiPetActionBarBackground:ClearAllPoints()
	ElvuiLineToPetActionBarBackground:ClearAllPoints()
	
	if C["actionbar"].bottompetbar ~= true then
		ElvuiActionBarBackground:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, E.Scale(4))
		if E["actionbar"].rightbars > 0 then
			ElvuiPetActionBarBackground:SetPoint("RIGHT", ElvuiActionBarBackgroundRight, "LEFT", E.Scale(-6), 0)
		else
			ElvuiPetActionBarBackground:SetPoint("RIGHT", UIParent, "RIGHT", E.Scale(-6), E.Scale(-13.5))
		end
		ElvuiPetActionBarBackground:SetSize(E.petbuttonsize + (E.buttonspacing * 2), (E.petbuttonsize * 10) + (E.buttonspacing * 11))
		ElvuiLineToPetActionBarBackground:SetSize(30, 265)
		ElvuiLineToPetActionBarBackground:SetPoint("LEFT", ElvuiPetActionBarBackground, "RIGHT", 0, 0)
	else
		ElvuiActionBarBackground:SetPoint("TOP", UIParent, "BOTTOM", 0, (E.buttonsize + (E.buttonspacing * 2)) + E.Scale(4))	
		ElvuiPetActionBarBackground:SetSize((E.petbuttonsize * 10) + (E.buttonspacing * 11), E.petbuttonsize + (E.buttonspacing * 2))
		ElvuiPetActionBarBackground:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, E.Scale(8))
		
		-- Frame/panel linking/seperating mainbar from petbar.
		ElvuiLineToPetActionBarBackground:SetTemplate("Transparent", true)
		ElvuiLineToPetActionBarBackground:CreateShadow("Transparent")
		ElvuiLineToPetActionBarBackground:SetSize(250, 8)
		ElvuiLineToPetActionBarBackground:SetPoint("TOP", ElvuiPetActionBarBackground, "BOTTOM", 0, 0)
	end
	
	if E.lowversion == true then
		if E["actionbar"].bottomrows == 3 then
			ElvuiActionBarBackground:SetHeight((E.buttonsize * 3) + (E.buttonspacing * 4))
		elseif E["actionbar"].bottomrows == 2 then
			ElvuiActionBarBackground:SetHeight((E.buttonsize * 2) + (E.buttonspacing * 3))
		else
			ElvuiActionBarBackground:SetHeight(E.buttonsize + (E.buttonspacing * 2))
		end
	else
		if E["actionbar"].bottomrows > 1 then
			ElvuiActionBarBackground:SetHeight((E.buttonsize * 2) + (E.buttonspacing * 3))
			ElvuiActionBarBackground:Point("TOP", UIParent, "BOTTOM", 0, (E.buttonsize*2 + (E.buttonspacing * 3)) + 4)
		else
			ElvuiActionBarBackground:SetHeight(E.buttonsize + (E.buttonspacing * 2))
		end	
	end
	
	--SplitBar
	if E["actionbar"].splitbar == true then
	
		ElvuiSplitActionBarLeftBackground:Show()
		ElvuiSplitActionBarRightBackground:Show()
		ElvuiSplitActionBarLeftBackground2:Show()
		ElvuiSplitActionBarRightBackground2:Show()
		
		ElvuiSplitActionBarLeftBackground:SetHeight(ElvuiActionBarBackground:GetHeight())
		ElvuiSplitActionBarRightBackground:SetHeight(ElvuiActionBarBackground:GetHeight())
		ElvuiSplitActionBarLeftBackground2:SetHeight(ElvuiActionBarBackground:GetHeight())
		ElvuiSplitActionBarRightBackground2:SetHeight(ElvuiActionBarBackground:GetHeight())
		
		if E.lowversion == true then
			if E["actionbar"].bottomrows < 3 then
				ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 3) + (E.buttonspacing * 4))
				ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 3) + (E.buttonspacing * 4))			
			else
				ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
				ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
			end
		else
			ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
			ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
			ElvuiSplitActionBarLeftBackground2:SetWidth((E.buttonsize * 2) + (E.buttonspacing * 3))
			ElvuiSplitActionBarRightBackground2:SetWidth((E.buttonsize * 2) + (E.buttonspacing * 3))
		end
	else
		ElvuiSplitActionBarLeftBackground:Hide()
		ElvuiSplitActionBarRightBackground:Hide()
		ElvuiSplitActionBarLeftBackground2:Hide()
		ElvuiSplitActionBarRightBackground2:Hide()
	end
	
	if E.lowversion == true then
		if E["actionbar"].bottomrows < 3 then
			ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 3) + (E.buttonspacing * 4))
			ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 3) + (E.buttonspacing * 4))			
		else
			ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
			ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))					
		end
	else
		ElvuiSplitActionBarLeftBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
		ElvuiSplitActionBarRightBackground:SetWidth((E.buttonsize * 4) + (E.buttonspacing * 5))
	end
	ElvuiSplitActionBarLeftBackground:SetHeight(ElvuiActionBarBackground:GetHeight())
	
	--RightBar
	ElvuiActionBarBackgroundRight:Show()
	
	if E.lowversion == true then
		if E["actionbar"].rightbars == 1 then
			ElvuiActionBarBackgroundRight:SetWidth(E.buttonsize + (E.buttonspacing * 2))
		elseif E["actionbar"].rightbars == 2 then
			ElvuiActionBarBackgroundRight:SetWidth((E.buttonsize * 2) + (E.buttonspacing * 3))
		else
			ElvuiActionBarBackgroundRight:Hide()
		end	
	else
		if E["actionbar"].rightbars == 1 then
			ElvuiActionBarBackgroundRight:SetWidth(E.buttonsize + (E.buttonspacing * 2))
		elseif E["actionbar"].rightbars == 2 then
			ElvuiActionBarBackgroundRight:SetWidth((E.buttonsize * 2) + (E.buttonspacing * 3))
		elseif E["actionbar"].rightbars == 3 then
			ElvuiActionBarBackgroundRight:SetWidth((E.buttonsize * 3) + (E.buttonspacing * 4))			
		else
			ElvuiActionBarBackgroundRight:Hide()
		end	
	end
end


function E.PositionAllBars()
	if E.lowversion == true then
		if E.actionbar.rightbars > 2 then
			E.actionbar.rightbars = 2
		end
	else
		if E.actionbar.rightbars > 1 and E.actionbar.splitbar == true then
			E.actionbar.rightbars = 1
		end
		
		if E.actionbar.bottomrows > 2 then
			E.actionbar.bottomrows = 2
		end
	end
	
	E.PositionAllPanels()
	E.PositionMainBar()
	E.PositionBar2()
	E.PositionBar3()
	E.PositionBar4()
	E.PositionBar5()
	E.PositionBarPet(ElvuiPetBar)
	if E.PositionWatchFrame then
		E.PositionWatchFrame()
	end
end