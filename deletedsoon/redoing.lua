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
pcall(function() loadstring(game:HttpGet('https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua'))() end)

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

-- GUIS
local PhoneHackDialog : ScreenGui = Players.LocalPlayer.PlayerGui.PhoneHackDialog

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
		local _, tabl : {['string'] : boolean | Instance} = coroutine.resume(npcIteratorThread)
		
		return tabl
	end
end

local function npcHandler(childTabl : {[number] : Instance}) : ()
	for npcTabl in npcIterator(childTabl) do
		if (npcTabl['success']) then
			local npc : Instance = npcTabl['npc']
			setNpc(npc.Name, npc)
		
		elseif (not (npcTabl['success'])) then
			print('[-] <npc> already setted, continuing')
			
			continue
		end
	end
	
	return
end

local function getPrompt(npc : Instance) : ()
	local prompt

	local connection; connection = npc:GetAttributeChangedSignal('NextCFrame'):Connect(function()
		Players.LocalPlayer.Character:MoveTo(npc.HumanoidRootPart.Position)
		prompt = npc.HumanoidRootPart:FindFirstChild('ProximityPrompt')
		
		if (prompt) then connection:Disconnect() end
	end)
	
	while (not (prompt)) do
		wait(1)
	end
	
	return prompt
end

local function firePrompt(prompt) : boolean
	local waitFor = false

	local connection; connection = PhoneHackDialog.Holder:GetPropertyChangedSignal('Visible'):Connect(function()
		connection:Disconnect()
		HackingController.CancelAndCleanFromOutside()
	end)

	fireproximityprompt(prompt, 1, true)

	SimpleSpy:GetRemoteFiredSignal(FinishedPhoneHack):Connect(function()
		waitFor = true
	end)
	
	SimpleSpy:GetRemoteFiredSignal(StartedPhoneHack):Connect(function(npc)
		FinishedPhoneHack:FireServer(0)
	end)
	
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
