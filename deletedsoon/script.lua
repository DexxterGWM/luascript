if not (game:IsLoaded()) then game.Loaded:Wait() end

-- [[ ESSENTIAL ]]

-- API(s)
pcall(function() loadstring(game:HttpGet('https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua'))() end)

-- [[ MODULES ]]

-- MODULES FOLDERS
local Controllers : Folder = game:GetService('ReplicatedStorage').Source.Controllers

-- MODULES VARIABLES
local HackingController : {} = require(Controllers.HackingController)

-- [[ REMOTES ]]

-- REMOTES FOLDERS
local RE : Folder = game:GetService('ReplicatedStorage').Packages._Index['sleitnick_knit@1.4.7'].knit.Services.HackingService.RE

-- REMOTES VARIABLES
local StartedPhoneHack : RemoteEvent, FinishedPhoneHack : RemoteEvent = RE.StartedPhoneHack, RE.FinishedPhoneHack

-- [[ SCRIPT VARIABLES ]]

-- TABLES
local npcsTabl : {[string] : Instance} = {}

-- FUNCTIONS
local coroutine = coroutine
local pairs = pairs

local rawget, rawset = rawget, rawset
local table = table

-- local string = string -- string.format

fireproximityprompt = fireproximityprompt

-- [[ LOCAL FUNCTIONS ]]

-- SETTERS
local function setNpc(npc : Instance) : () -- need sanity check
	print(('setting %s on <npcs>'):format(tostring(npc.Name))) --
	
	rawset(npcsTabl, npc.Name, npc)

	return
end

local function delNpc(npc : Instance) : () -- need sanity check
	print(('deleting %s from <npcs>'):format(tostring(rawget(npcsTabl, npc.Name)))) --
	
	table.remove(npcsTabl, table.find(npcsTabl, npc.Name))

	return
end

-- FUNCTIONAL
local function npcIterator(childTabl : {[number] : Instance}) : () -- need sanity check(s)
	local npcIteratorThread = coroutine.create(function(_) : ()
		for index = 1, #childTabl do
			if (childTabl[index]:IsA('Model') and childTabl[index]:FindFirstChildOfClass('Humanoid')) then
				if (rawget(npcsTabl, childTabl[index].Name)) then
					coroutine.yield({['success'] = false})

					continue
				end

				coroutine.yield({['success'] = true, ['npc'] = childTabl[index]})
			end
		end
	end)

	return function() : {}
		local _, tabl : {['string'] : boolean | Instance} = coroutine.resume(npcIteratorThread) -- coroutine.close

		return tabl
	end
end

local function npcHandler(childTabl : {[number] : Instance}) : () -- need sanity check??
	for npcTabl in npcIterator(childTabl) do
		if (npcTabl['success']) then
			setNpc(rawget(npcTabl, 'npc'))

		elseif (not (npcTabl['success'])) then
			warn(('%s already setted, continuing'):format(tostring(rawget(npcTabl, 'npc')))) --

			continue
		end
	end

	return
end

local function getPrompt(npc : Instance) : ProximityPrompt | boolean
	if (not (npc.ClassName == 'Model' and npc:FindFirstChildOfClass('Humanoid'))) then warn('error getting prompt'); return false end
	
	local debugModel = ('%s getting prompt of %s')
	local prompt : ProximityPrompt

	local connection; connection = npc:GetAttributeChangedSignal('NextCFrame'):Connect(function()
		print(debugModel:format('attempt', tostring(npc.Name))) --
		
		game:GetService('Players').LocalPlayer.Character:MoveTo(npc.HumanoidRootPart.Position)
		prompt = npc.HumanoidRootPart:FindFirstChild('ProximityPrompt')

		if (prompt) then connection:Disconnect() end
	end)

	while (not (prompt)) do
		if (not (npc.Parent)) then warn(debugModel:format('failed', tostring(npc.Name))); return false end -- AncestryChanged
		
		wait(1)
	end
	
	print(('got %s of %s'):format(tostring(prompt.Name), tostring(npc.Name))) --

	return prompt
end

local function firePrompt(prompt) : boolean
	local waitFor : boolean = false

	local connection : RBXScriptConnection
	connection = game:GetService('Players').LocalPlayer.PlayerGui.PhoneHackDialog.Holder:GetPropertyChangedSignal('Visible'):Connect(function()
		connection:Disconnect(); HackingController.CancelAndCleanFromOutside()
	end)

	fireproximityprompt(prompt, 1, true)
	
	-- SimpleSpy come from _G
	SimpleSpy:GetRemoteFiredSignal(FinishedPhoneHack):Connect(function() waitFor = true end)
	SimpleSpy:GetRemoteFiredSignal(StartedPhoneHack):Connect(function(npc) FinishedPhoneHack:FireServer(0) end)

	while (not (waitFor)) do wait(1) end

	return true
end

local function npcPromptHandler() : ()
	for _, npc in pairs(npcsTabl) do
		local prompt = getPrompt(npc)

		if (prompt) then
			firePrompt(prompt)
			delNpc(npc)
		end
	end

	return
end

npcHandler(game:GetService('Workspace').NPC:GetChildren())
-- game:GetService('Lighting').UnloadedNPC
-- game:GetService('Lighting').PreUnloadedNPC

npcPromptHandler()

-- local test; test = npcFolder.ChildAdded:Connect(function(child : Instance) : ()
-- 	if (not (child:FindFirstChildOfClass('Humanoid'))) then return end
-- 	
-- 	npcHandler({child})
-- 	
-- 	return
