-----------------------------------------------------
-- All starts here baby!

-- Credit Nightcracker
-----------------------------------------------------

-- including system
local addon, engine = ...
engine[1] = {} -- E, functions, constants
engine[2] = {} -- C, config
engine[3] = {} -- L, localization

ElvUI = engine --Allow other addons to use Engine

--[[
	This should be at the top of every file inside of the ElvUI AddOn:
	
	local E, C, L = unpack(select(2, ...))

	This is how another addon imports the ElvUI engine:
	
	local E, C, L = unpack(ElvUI)
]]