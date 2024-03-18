if not (game:IsLoaded()) then game.Loaded:Wait() end

-- [[ VARIABLES ]]

-- REMOTES
local startedEvent : RemoteEvent = game:GetService('ReplicatedStorage').Packages._Index['sleitnick_knit@1.4.7'].knit.Services.HackingService.RE.StartedPhoneHack
local finishedEvent : RemoteEvent = game:GetService('ReplicatedStorage').Packages._Index['sleitnick_knit@1.4.7'].knit.Services.HackingService.RE.FinishedPhoneHack

-- PLAYER
local player = game:GetService('Players').LocalPlayer
local playerChar = player.Character

-- //
local hackedGui = player.PlayerGui.PhoneHackDialog
local hackedGuiFrame = hackedGui.Holder

hackedGui.Enabled = false --
-- //

-- WORKSPACE
local npcFolder : Fodler = game:GetService('Workspace').NPC

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
			playerChar:MoveTo(npcRootPart.Position)
			npcPrompt = npcRootPart:FindFirstChild('ProximityPrompt')
			wait(1)
		end

		print('npc name', npc.Name)
		fireproximityprompt(npcPrompt, 1, true)

		-- startedEvent:FireServer(tostring(npc.Name))

		repeat
			wait(1) --
		until
			not (hackedGuiFrame.Visible) --
		
		finishedEvent:FireServer(tostring(npc.Name))
		hackedGuiFrame.Visible = false

		-- table.remove(npcsTabl, table.find(npcsTabl, tostring(npc.Name)))
		call(delNpcs, npc)
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
			--[[
			npc.AncestryChanged:Connect(function(npc, parent)
				if not (npc.Parent) then call(delNpcs, {npc})
				elseif npc.Parent then print(npc.Name, 'New parent:', parent)
				end
			end)
			--]]

		elseif not (success) then print('[-] Failed on <npcs path>:', returnVal)
		end
	end
	
	call(getNpcPrompt)

	--[[
	path.ChildAdded:Connect(
		function(child)
			call(childEvents, {[1] = child, [2] = true})
		end
	)
	
	path.ChildRemoved:Connect(
		function(child)
			call(childEvents, {[1] = child, [2] = false})
		end
	)
	--]]

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
