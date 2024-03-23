-- local testButton = game:GetService('Players').LocalPlayer.PlayerGui.ChocolateMenu:FindFirstChild('testButton')
-- if testButton then testButton:Destroy() end

-- local testButton = Instance.new('TextButton')

-- testButton.AnchorPoint = Vector2.new(0.5, 0.5)
-- testButton.Position = UDim2.new(0.5, 0, 0.5, 0)
-- testButton.TextColor3 = Color3.fromRGB(0, 0, 0)
-- testButton.Text = 'cancel'
-- testButton.Parent = game:GetService('Players').LocalPlayer.PlayerGui.ChocolateMenu
-- testButton.Size = UDim2.new(0, 50, 0, 50)

-- [[ ESSENTIAL VARIABLES ]]

-- API(s)
-- pcall(function() loadstring(game:HttpGet('https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua'))() end)

-- [[ SERVICES ]]

-- SERVICES VARIABLES
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local WorkspaceService = game:GetService('Workspace')
local LightingService = game:GetService('Lighting')
local Players = game:GetService('Players')

-- SERVICES FOLDERS
local npcFolder : Folder = WorkspaceService.NPC
local unloadedNpcFolder : Folder = LightingService.UnloadedNPC

local preUnloadedNpcFolder : Folder = LightingService.PreUnloadedNPC

-- [[ MODULES ]]

-- MODULES FOLDERS
local Source : Folder = ReplicatedStorage.Source
local Controllers : Folder = Source.Controllers

-- MODULES VARIABLES
local HackingController = require(Controllers.HackingController)

-- [[ REMOTES ]]

-- REMOTES FOLDERS
local Packages : Folder = ReplicatedStorage.Packages
local Index : Folder = Packages._Index['sleitnick_knit@1.4.7']
local knit : Folder = Index.knit
local Services : Folder = knit.Services
local HackingService : Folder = Services.HackingService
local RE : Folder = HackingService.RE

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

	return
end

local function delNpc(npcName : string, npc : Instance) : ()
	table.remove(npcsTabl, table.find(npcsTabl, npcName))
	
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
		-- local _, tabl : {['string'] : boolean | Instance} = coroutine.resume(task.defer(npcIteratorThread))
		local _, tabl : {['string'] : boolean | Instance} = coroutine.resume(npcIteratorThread)
		
		return tabl
	end
end

local function npcHandler(childTabl : {[number] : Instance}) : ()
	for npcTabl in npcIterator(childTabl) do
		if (npcTabl['success']) then
			local npc : Instance = npcTabl['npc']
			
			setNpc(npc.Name, npc)
			print(('[+] %s setted on <npcs>'):format(tostring(npc.Name)))
		
		elseif (not (npcTabl['success'])) then
			print('[-] <npc> already setted, continuing')
			
			continue
		end
	end
	
	return
end

local function npcPrompt() : ()
	local npcPromptIteratorThread = coroutine.create(function(_) : ()
		--
		local count = 0
		for a, b in pairs(npcsTabl) do
			count += 1
		end
		print(count)
		--
		
		for a, npc in pairs(npcsTabl) do
			print('a:', a) --
			print('npc:', npc) --
			
			Players.LocalPlayer.Character:MoveTo(npc.HumanoidRootPart.Position)

			local npcPrompt = npc.HumanoidRootPart:FindFirstChild('ProximityPrompt')

			if (not (npcPrompt)) then
				local connection; connection = npc:GetAttributeChangedSignal('NextCFrame'):Connect(function()
					if (npcPrompt) then connection:Disconnect(); return end
					
					Players.LocalPlayer.Character:MoveTo(npc.HumanoidRootPart.Position)
					npcPrompt = npc.HumanoidRootPart:FindFirstChild('ProximityPrompt')
				end)
				
				while not (npcPrompt) do wait(1) end
				print('got', npcPrompt) --
			end
			
			coroutine.yield(npcPrompt)
		end
	end)
	
	return function() : ()
		-- local _, npcPrompt = coroutine.resume(task.defer(npcPromptIteratorThread))
		local _, npcPrompt = coroutine.resume(npcPromptIteratorThread)
		
		return npcPrompt
	end
end

local function npcPromptHandler() : ()
	for npcPrompt in npcPrompt() do
		local npcPrompt = npcPrompt
		print('prompt:', npcPrompt) --
	end
	
	return
end

npcHandler(npcFolder:GetChildren())

npcPromptHandler()

-- coroutine.close?! (depends of what's needed)
-- task.cancel?! (may)

-- local test; test = npcFolder.ChildAdded:Connect(function(child : Instance) : ()
-- 	if (not (child:FindFirstChildOfClass('Humanoid'))) then return end
-- 	
-- 	npcHandler({child})
-- 	
-- 	return
-- end)

-- testButton.MouseButton1Click:Connect(function() test:Disconnect(); testButton:Destroy() end)