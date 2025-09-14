--[[
    Admin/Developer Tool GUI
    Features:
    - Infinite Jump Toggle: Allows jumping in mid-air.
    - Kill Aura Toggle: Automatically damages nearby entities if a specified weapon is equipped.
    - Radius Slider: Adjusts the range of the Kill Aura.

    Instructions:
    1. Create a "LocalScript" inside StarterPlayer > StarterPlayerScripts.
    2. Paste this entire code into that LocalScript.
    3. IMPORTANT: For Kill Aura to work, make sure your tool (e.g., a "ClassicSword") has a RemoteEvent
       that the server uses to process damage. This script looks for that event.
    4. Play the game!
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Player & Character Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Function to re-assign character and humanoid if player respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
end)

-- Configuration
local AURA_RADIUS_MIN = 10
local AURA_RADIUS_MAX = 200
local AURA_RADIUS_DEFAULT = 50
local TOOL_NAME_TO_CHECK = "ClassicSword" -- The name of the tool that enables the aura

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminToolGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Admin Tool"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 8)

-- Infinite Jump UI
local infJumpLabel = Instance.new("TextLabel", mainFrame)
infJumpLabel.Name = "InfJumpLabel"
infJumpLabel.Size = UDim2.new(0, 150, 0, 30)
infJumpLabel.Position = UDim2.new(0, 15, 0, 40)
infJumpLabel.BackgroundTransparency = 1
infJumpLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
infJumpLabel.Text = "Infinite Jump"
infJumpLabel.Font = Enum.Font.SourceSans
infJumpLabel.TextSize = 16
infJumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local infJumpToggle = Instance.new("TextButton", mainFrame)
infJumpToggle.Name = "InfJumpToggle"
infJumpToggle.Size = UDim2.new(0, 80, 0, 25)
infJumpToggle.Position = UDim2.new(1, -95, 0, 42.5)
infJumpToggle.Font = Enum.Font.SourceSansBold
infJumpToggle.Text = "OFF"
infJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpToggle.TextSize = 14
local infJumpCorner = Instance.new("UICorner", infJumpToggle)
infJumpCorner.CornerRadius = UDim.new(0, 6)

-- Kill Aura UI
local auraLabel = Instance.new("TextLabel", mainFrame)
auraLabel.Name = "AuraLabel"
auraLabel.Size = UDim2.new(0, 150, 0, 30)
auraLabel.Position = UDim2.new(0, 15, 0, 80)
auraLabel.BackgroundTransparency = 1
auraLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
auraLabel.Text = "Kill Aura"
auraLabel.Font = Enum.Font.SourceSans
auraLabel.TextSize = 16
auraLabel.TextXAlignment = Enum.TextXAlignment.Left

local auraToggle = Instance.new("TextButton", mainFrame)
auraToggle.Name = "AuraToggle"
auraToggle.Size = UDim2.new(0, 80, 0, 25)
auraToggle.Position = UDim2.new(1, -95, 0, 82.5)
auraToggle.Font = Enum.Font.SourceSansBold
auraToggle.Text = "OFF"
auraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
auraToggle.TextSize = 14
local auraCorner = Instance.new("UICorner", auraToggle)
auraCorner.CornerRadius = UDim.new(0, 6)

-- Radius Slider UI
local radiusLabel = Instance.new("TextLabel", mainFrame)
radiusLabel.Name = "RadiusLabel"
radiusLabel.Size = UDim2.new(1, -30, 0, 20)
radiusLabel.Position = UDim2.new(0, 15, 0, 115)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLabel.Text = "Radius: " .. currentAuraRadius
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.TextSize = 14
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left

local radiusSliderTrack = Instance.new("Frame", mainFrame)
radiusSliderTrack.Name = "RadiusSliderTrack"
radiusSliderTrack.Size = UDim2.new(1, -30, 0, 8)
radiusSliderTrack.Position = UDim2.new(0, 15, 0, 140)
radiusSliderTrack.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
radiusSliderTrack.BorderColor3 = Color3.fromRGB(15, 15, 15)
local trackCorner = Instance.new("UICorner", radiusSliderTrack)
trackCorner.CornerRadius = UDim.new(0, 4)

local radiusSliderHandle = Instance.new("ImageButton", radiusSliderTrack)
radiusSliderHandle.Name = "RadiusSliderHandle"
radiusSliderHandle.Size = UDim2.new(0, 18, 0, 18)
radiusSliderHandle.Position = UDim2.new( (AURA_RADIUS_DEFAULT - AURA_RADIUS_MIN) / (AURA_RADIUS_MAX - AURA_RADIUS_MIN), -9, 0.5, -9)
radiusSliderHandle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
radiusSliderHandle.Image = "rbxassetid://392630590"
radiusSliderHandle.ImageColor3 = Color3.fromRGB(255, 80, 80)
radiusSliderHandle.ScaleType = Enum.ScaleType.Slice
radiusSliderHandle.SliceCenter = Rect.new(100, 100, 100, 100)
local handleCorner = Instance.new("UICorner", radiusSliderHandle)
handleCorner.CornerRadius = UDim.new(1, 0)

-- --- GUI LOGIC ---

-- Helper to update toggle button visuals
local function updateToggleVisuals(button, enabled)
    if enabled then
        button.Text = "ON"
        button.BackgroundColor3 = Color3.fromRGB(80, 180, 80) -- Green
    else
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(180, 80, 80) -- Red
    end
end

-- Toggle Infinite Jump
infJumpToggle.MouseButton1Click:Connect(function()
    isInfJumpEnabled = not isInfJumpEnabled
    updateToggleVisuals(infJumpToggle, isInfJumpEnabled)
end)

-- Toggle Kill Aura
auraToggle.MouseButton1Click:Connect(function()
    isAuraEnabled = not isAuraEnabled
    updateToggleVisuals(auraToggle, isAuraEnabled)
end)

-- Radius Slider Logic
local isDraggingRadius = false

local function updateRadiusFromPosition()
    local trackWidth = radiusSliderTrack.AbsoluteSize.X
    local handlePos = radiusSliderHandle.Position.X.Offset + (radiusSliderHandle.Size.X.Offset / 2)
    local percentage = math.clamp(handlePos / trackWidth, 0, 1)
    
    currentAuraRadius = AURA_RADIUS_MIN + (percentage * (AURA_RADIUS_MAX - AURA_RADIUS_MIN))
    radiusLabel.Text = "Radius: " .. math.floor(currentAuraRadius)
end

radiusSliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingRadius = true
    end
end)

radiusSliderHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingRadius = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingRadius and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseLocation = UserInputService:GetMouseLocation()
        local relativeX = mouseLocation.X - radiusSliderTrack.AbsolutePosition.X
        local clampedX = math.clamp(relativeX, 0, radiusSliderTrack.AbsoluteSize.X)
        
        radiusSliderHandle.Position = UDim2.new(0, clampedX - (radiusSliderHandle.Size.X.Offset / 2), 0.5, -radiusSliderHandle.Size.Y.Offset / 2)
        updateRadiusFromPosition()
    end
end)

-- --- CORE FUNCTIONALITY ---

-- Infinite Jump Functionality
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- Don't jump if typing in chat
    
    if isInfJumpEnabled and input.KeyCode == Enum.KeyCode.Space then
        humanoid.Jump = true
    end
end)

-- Kill Aura Functionality (runs every frame)
RunService.Heartbeat:Connect(function()
    if not isAuraEnabled then return end
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return end
    
    local tool = playerChar:FindFirstChildOfClass("Tool")
    -- Check if a tool is equipped and if it's the correct one
    if not tool or tool.Name ~= TOOL_NAME_TO_CHECK then return end
    
    -- Find the remote event in the tool to fire for damage
    local damageEvent = tool:FindFirstChild("DamageEvent") -- YOU MUST CREATE THIS IN YOUR TOOL
    if not damageEvent then return end

    local playerPos = playerChar.HumanoidRootPart.Position

    -- Loop through all other players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local targetChar = otherPlayer.Character
            if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 and targetChar:FindFirstChild("HumanoidRootPart") then
                
                local targetPos = targetChar.HumanoidRootPart.Position
                local distance = (playerPos - targetPos).Magnitude
                
                if distance <= currentAuraRadius then
                    -- Fire the remote event, simulating a hit on the target.
                    -- The server will handle the actual damage logic.
                    damageEvent:FireServer(targetChar.Humanoid)
                end
            end
        end
    end
end)

-- Initialize UI state
updateToggleVisuals(infJumpToggle, isInfJumpEnabled)
updateToggleVisuals(auraToggle, isAuraEnabled)
