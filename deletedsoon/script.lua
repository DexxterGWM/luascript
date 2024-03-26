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
local StartedPhoneHack : RemoteEvent = RE.StartedPhoneHack
local FinishedPhoneHack : RemoteEvent = RE.FinishedPhoneHack

-- [[ SCRIPT VARIABLES ]]

-- TABLES
local npcsTabl : {[string] : Instance} = {}

-- FUNCTIONS
fireproximityprompt = fireproximityprompt
local pairs = pairs

-- [[ LOCAL FUNCTIONS ]]

-- SETTERS
local function setNpc(npcName : string, npc : Instance) : ()
	npcsTabl[npcName] = npc
	print(('[*] %s setted on <npcs>'):format(tostring(npcName)))

	return
end

local function delNpc(npcName : string) : ()
	table.remove(npcsTabl, table.find(npcsTabl, npcName))
	print(('[*] %s deleted from <npcs>'):format(tostring(npcName)))

	return
end

-- FUNCTIONAL
local function npcIterator(childTabl : {[number] : Instance}) : ()
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

local function npcHandler(childTabl : {[number] : Instance}) : ()
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

local function getPrompt(npc : Instance) : boolean -- prompt type
	if (not (npc.ClassName == 'Model' and npc:FindFirstChildOfClass('Humanoid'))) then warn('error getting prompt'); return false end
	print(('attempt to get prompt of %s'):format(tostring(npc.Name))) --
	
	local prompt -- :? type

	local connection; connection = npc:GetAttributeChangedSignal('NextCFrame'):Connect(function()
		game:GetService('Players').LocalPlayer.Character:MoveTo(npc.HumanoidRootPart.Position)
		prompt = npc.HumanoidRootPart:FindFirstChild('ProximityPrompt')

		if (prompt) then connection:Disconnect() end
	end)

	while (not (prompt)) do
		if (not (npc.Parent)) then warn(('failed getting prompt of %s'):format(tostring(npc.Name))); return false end
		wait(1)
	end
	
	print(('got %s of %s | %s'):format(tostring(prompt.Name), tostring(npc.Name), typeof(prompt))) --

	return prompt
end

local function firePrompt(prompt) : boolean
	local waitFor = false

	local connection; connection = game:GetService('Players').LocalPlayer.PlayerGui.PhoneHackDialog.Holder:GetPropertyChangedSignal('Visible'):Connect(function()
		connection:Disconnect()
		HackingController.CancelAndCleanFromOutside()
	end)

	fireproximityprompt(prompt, 1, true)

	--SimpleSpy:GetRemoteFiredSignal(FinishedPhoneHack):Connect(function()
	--	waitFor = true
	--end)

	--SimpleSpy:GetRemoteFiredSignal(StartedPhoneHack):Connect(function(npc)
	--	FinishedPhoneHack:FireServer(0)
	--end)

	while not (waitFor) do wait(1) end

	return true
end

local function npcPromptHandler() : ()
	for _, npc in pairs(npcsTabl) do
		local prompt = getPrompt(npc)

		if (prompt) then
			firePrompt(prompt)
			delNpc(npc.Name)
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
