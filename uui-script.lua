-- Create the GUI elements
local screenGui = Instance.new("ScreenGui")
local startStopButton = Instance.new("TextButton")
local filterButton = Instance.new("TextButton")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Setup the ScreenGui
screenGui.Parent = playerGui

-- Setup the Start/Stop Button
startStopButton.Size = UDim2.new(0, 100, 0, 50)
startStopButton.Position = UDim2.new(0, 10, 0, 10)
startStopButton.Text = "Start"
startStopButton.Parent = screenGui

-- Setup the Filter Button
filterButton.Size = UDim2.new(0, 100, 0, 50)
filterButton.Position = UDim2.new(0, 120, 0, 10)
filterButton.Text = "Filter: Off"
filterButton.Parent = screenGui

local running = false
local filterOn = false

-- Function to toggle the running state
local function toggleRunning()
    running = not running
    if running then
        startStopButton.Text = "Stop"
        spawn(mainLoop)  -- Start the loop
    else
        startStopButton.Text = "Start"
    end
end

-- Function to toggle the filter state
local function toggleFilter()
    filterOn = not filterOn
    if filterOn then
        filterButton.Text = "Filter: On"
    else
        filterButton.Text = "Filter: Off"
    end
end

-- Function to create highlight effect
local function createHighlight(part)
    local highlight = Instance.new("Highlight")
    highlight.Parent = part
    return highlight
end

-- Function to handle proximity prompt firing
local function fireProximityPrompt(proximityPrompt)
    proximityPrompt:InputHoldBegin()
    wait(0.1)
    proximityPrompt:InputHoldEnd()
end

-- Main loop to check for parts and fire proximity prompts
local function mainLoop()
    while running do
        for _, part in ipairs(workspace.Chests:GetChildren()) do
            if part:FindFirstChild("ProximityPrompt") then
                if not filterOn or (filterOn and part.Name == "Chest_p") then
                    createHighlight(part)
                    fireProximityPrompt(part.ProximityPrompt)
                end
            end
        end
        wait(0.5)  -- Adjust the wait time as needed to avoid performance issues
    end
end

-- Connect button clicks to their respective functions
startStopButton.MouseButton1Click:Connect(toggleRunning)
filterButton.MouseButton1Click:Connect(toggleFilter)
