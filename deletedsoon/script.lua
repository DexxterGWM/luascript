if not (game:IsLoaded()) then game.Loaded:Wait() end

-- [[ SERVICES VARIABLES ]]

-- API(s)
loadstring(game:HttpGet('https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua'))()

-- GAME SERVICES
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')

-- [[ MODULES/REMOTES FOLDERS ]]

-- MODULES
local Source = ReplicatedStorage.Source
local Controllers = Source.Controllers

-- REMOTES
local Packages : Folder = ReplicatedStorage.Packages
local Index : Folder = Packages._Index['sleitnick_knit@1.4.7']
local knit : Folder = Index.knit
local Services : Folder = knit.Services
local HackingService : Folder = Services.HackingService
local RE = HackingService.RE

-- [[ MODULES/REMOTES VARIABLES ]]

-- MODULES
local HackingController = require(Controllers.HackingController)

-- REMOTES
local StartedPhoneHack = RE.StartedPhoneHack
local FinishedPhoneHack = RE.FinishedPhoneHack

print(StartedPhoneHack)
print(FinishedPhoneHack)

-- [[ SCRIPT VARIABLES ]]

-- PLAYER VARIABLES
local player = game:GetService('Players').LocalPlayer
local playerChar = player.Character

-- may won't need these*
-- local hackedGui = player.PlayerGui.PhoneHackDialog
-- local hackedGuiFrame = hackedGui.Holder
local NPCHackDialog = player.PlayerGui.NPCHackDialog

-- WORKSPACE
local npcFolder : Fodler = Workspace.NPC

-- FUNCTIONS VARIABLES
fireproximity = fireproximity

local taskDefer = task.defer
local xpCall = xpcall

-- [[ TABLES ]]
local npcsStatesTabl = {
	[1] = 'loaded'
	-- [2] = 'preunloaded',
	-- [3] = 'unloaded'
}

local npcsTabl = {}
local npcsPlacesTabl = {}

-- [[ FUNCTIONS ]]

-- AUX FUNCTIONS
local function call(funct, args, ...) : ()
	local success, returnVal = xpCall(
		function()
			if not (args) then funct()
			elseif args then funct(args)
			end
		end,

		function(err) print(('%s...'):format(err)) end
	)

	return (success and true) or (returnVal and false)
end

-- FUNCTIONAL FUNCTIONS
local function delNpcs(npc) : ()
	local npc = rawget(npc, 1)
	if not (npc) then return end

	if rawget(npcsTabl, npc.Name) then
		table.remove(npcsTabl, table.find(npcsTabl, npc.Name))
		print(('[*] %s Got deleted from <npcs>'):format(tostring(npc.Name)))
	end

	return
end

local function setNpcs(npc) : ()
	local npc = rawget(npc, 1)
	if not (npc) then return end

	if rawget(npcsTabl, npc.Name) then return end

	rawset(npcsTabl, npc.Name, {
		['npc'] = npc,
		['state'] = rawget(npcsStatesTabl, (rawget(npcsPlacesTabl, npc.Parent.Name)))
	})

	print(('[*] %s Got added on <npcs>'):format(tostring(npc.Name)))

	return
end

local function childEvents(child) : ()
	local event = rawget(child, 2)
	local child = rawget(child, 1)

	if not (child or event ~= nil) then return
	elseif not (typeof(child) == 'Instance') then return
	end

	if child.ClassName == 'Model' then
		if not (rawget(npcsTabl, child.Name)) then
			if event then call(setNpcs, {child})
			elseif not (event) then call(delNpcs, {child})
			end
		end
	end

	return
end

local function getNpcPrompt() : ()
	for npc, npcTabl in pairs(npcsTabl) do
		local npc = npcTabl['npc']
		
		local npcRootPart = npc.HumanoidRootPart
		playerChar:MoveTo(npcRootPart.Position)
		
		local npcPrompt = npcRootPart:FindFirstChild('ProximityPrompt')

		while not (npcPrompt) do -- GetAttributeChangedSignal?
			wait(1)
			
			playerChar:MoveTo(npcRootPart.Position)
			npcPrompt = npcRootPart:FindFirstChild('ProximityPrompt')
		end

		-- [[ need abstraction ("fireNpcPrompt" may)
		
		fireproximityprompt(npcPrompt, 1, true)
		
		local waitFor = false

		local test1 = SimpleSpy:GetRemoteFiredSignal(StartedPhoneHack):Connect(function(npc)
			-- HackingController.CancelAndCleanFromOutside() -- ?
			FinishedPhoneHack:FireServer(0)
		end)
		local test2 = SimpleSpy:GetRemoteFiredSignal(FinishedPhoneHack):Connect(function()
			local guiConnection; guiConnection = NPCHackDialog:GetPropertyChangedSignal('Enabled'):Connect(function()
				guiConnection:Disconnect()
				waitFor = true
			end)
			
			HackingController.CancelAndCleanFromOutside() -- ?
		end)
		
		while not (waitFor) do wait(1) end

		--
		-- HackingController.CancelAndCleanFromOutside() -- ?
		call(delNpcs, {npc})
		
		-- ]]
	end
end

local function setNpcsFromPath(path) : ()
	local path = rawget(path, 1)
	if not (path) then return end

	for _, npc in pairs(path:GetDescendants()) do
		if not (npc.ClassName == 'Model') then continue end
		if rawget(npcsTabl, npc.Name) then continue end

		local success, returnVal = call(setNpcs, {npc})

		if success then
			-- ?
			
			-- npc.AncestryChanged:Connect(function(npc, parent)
			--	if not (npc.Parent) then call(delNpcs, {npc})
			--	elseif npc.Parent then print(npc.Name, 'New parent:', parent)
			--	end
			-- end)

		elseif not (success) then print('[-] Failed on <npcs path>:', returnVal)
		end
	end
	
	call(getNpcPrompt)

	-- path.ChildAdded:Connect(function(child)
	--	call(childEvents, {[1] = child, [2] = true})
	-- end)
	
	-- path.ChildRemoved:Connect(function(child)
	--	call(childEvents, {[1] = child, [2] = false})
	-- end)

	return
end

local function setNpcsPlaces(path) : ()
	for ind = 1, #npcsStatesTabl do
		if rawget(path, ind) then
			rawset(npcsPlacesTabl, rawget(path, ind).Name, ind)
		end
	end

	return
end

-- OTHERS FUNCTIONS
local function getNpcsPlaces() : ()
	local success, returnVal = call(setNpcsPlaces, {
		[1] = npcFolder
		-- [2] = preUnloadedNPC,
		-- [3] = unloadedNPC
	})

	if success then print('[+] Success on <npcs places>')
	elseif not (success) then print('[-] Failed on <npcs places>:', returnVal)
	end

	return
end

local function getLoadedNpc() : ()
	local success, returnVal = call(setNpcsFromPath, {npcFolder})

	if success then print('[+] Success on <loaded npcs>')
	elseif not (success) then print('[-] Failed on <loaded npcs>:', returnVal)
	end

	return
end

-- getPreUnloadedNpc()
-- game:GetService('Lighting').PreUnloadedNPC

-- getUnloadedNpc() : ()
-- game:GetService('Lighting').UnloadedNPC

-- [[ SCRIPT ]]

-- SETTINGS
call(getNpcsPlaces)

-- STARTING
call(getLoadedNpc)
-- preUnloadedNpc
-- unloadedNpc

-- taskDefer
