local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
-- Get the LocalPlayer and their character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Create a ScreenGui for the GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create buttons for Start/Stop, Filter, and Auto Walk
local startStopButton = Instance.new("TextButton")
startStopButton.Size = UDim2.new(0, 100, 0, 30)
startStopButton.Position = UDim2.new(1, -120, 0, 20)  -- Top right corner
startStopButton.AnchorPoint = Vector2.new(1, 0)
startStopButton.Text = "Start"
startStopButton.Parent = screenGui

local filterButton = Instance.new("TextButton")
filterButton.Size = UDim2.new(0, 100, 0, 30)
filterButton.Position = UDim2.new(1, -120, 0, 70)  -- Below startStopButton
filterButton.AnchorPoint = Vector2.new(1, 0)
filterButton.Text = "Filter: Off"
filterButton.Parent = screenGui

local autoWalkButton = Instance.new("TextButton")
autoWalkButton.Size = UDim2.new(0, 100, 0, 30)
autoWalkButton.Position = UDim2.new(1, -120, 0, 120)  -- Below filterButton
autoWalkButton.AnchorPoint = Vector2.new(1, 0)
autoWalkButton.Text = "Auto Walk: Off"
autoWalkButton.Parent = screenGui

-- Variables to control script behavior
local running = false
local filterOn = false
local autoWalkOn = false
local mainLoopTask = nil

-- Function to find the nearest part with a proximity prompt
local function findNearestChest()
	local closestPart = nil
	local closestDistance = math.huge

	for _, part in pairs(workspace.chests:GetChildren()) do
		if part:IsA("BasePart") then
			local distance = (part.Position - character.HumanoidRootPart.Position).magnitude
			if distance < closestDistance then
				closestPart = part
				closestDistance = distance
			end
		end
	end

	return closestPart
end

-- Function to trigger the proximity prompt on a given part
local function triggerProximityPrompt(part)
	if part then
		local proximityPrompt = part:FindFirstChildOfClass("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.HoldDuration = 0
			proximityPrompt:InputHoldBegin()
			proximityPrompt:InputHoldEnd()
		end
	end
end

-- Function to automatically walk towards a specified part
local function autoWalkToPart(part)
	if part then
		local humanoid = character:WaitForChild("Humanoid")
		local partPosition = part.Position + Vector3.new(0, 3, 0)  -- Move to 3 studs above the part

		-- Tween the character to the part's position
		local fixedDuration = 0.1  -- Adjust this value for desired speed
		local tweenInfo = TweenInfo.new(fixedDuration, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(partPosition)})
		tween:Play()
		tween.Completed:Connect(function()
			if autoWalkOn then
				local newPart = findNearestChest()
				if newPart then
					autoWalkToPart(newPart)
				else
					autoWalkOn = false
					autoWalkButton.Text = "Auto Walk: Off"
				end
			end
		end)
	end
end

-- Main loop function to continuously trigger proximity prompts
local function mainLoop()
	while running do
		local nearestPart = findNearestChest()
		if nearestPart then
			if not filterOn or (filterOn and nearestPart.Name ~= "Chest_p") then
				triggerProximityPrompt(nearestPart)
			end
		end
		wait()  -- Adjust loop interval as needed
	end
end

-- Function to start or stop the main loop
local function toggleMainLoop()
	running = not running
	startStopButton.Text = running and "Stop" or "Start"
	if running then
		mainLoopTask = spawn(mainLoop)
	elseif mainLoopTask then
		mainLoopTask:Cancel()
		mainLoopTask = nil
	end
end

-- Function to toggle the filter on/off
local function toggleFilter()
	filterOn = not filterOn
	filterButton.Text = filterOn and "Filter: On" or "Filter: Off"
end

-- Function to toggle auto walk on/off
local function toggleAutoWalk()
	autoWalkOn = not autoWalkOn
	autoWalkButton.Text = autoWalkOn and "Auto Walk: On" or "Auto Walk: Off"
	if autoWalkOn then
		local randomPart = findNearestChest()
		autoWalkToPart(randomPart)
	end
end

-- Connect button click events after functions are defined
startStopButton.MouseButton1Click:Connect(toggleMainLoop)
filterButton.MouseButton1Click:Connect(toggleFilter)
autoWalkButton.MouseButton1Click:Connect(toggleAutoWalk)

-- Initial setup
toggleMainLoop()  -- Start the main loop initially
