-- LocalScript (put in StarterPlayer > StarterPlayerScripts)
-- CORRECTED & IMPROVED VERSION 

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
    humanoid.WalkSpeed = currentWalkSpeed -- Reapply walk speed on respawn
end)

-- Configuration
local AURA_RADIUS_MIN = 10
local AURA_RADIUS_MAX = 200
local AURA_RADIUS_DEFAULT = 50
local WALK_SPEED_MIN = 16
local WALK_SPEED_MAX = 100
local WALK_SPEED_DEFAULT = 16
-- IMPORTANT: Add the EXACT name of your axe and any other weapons here!
local WEAPON_NAMES = { "ClassicSword", "Axe", "Iron Hammer" } -- Add your tool names to this list

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT
local currentWalkSpeed = WALK_SPEED_DEFAULT
local auraTargetDebounce = {} -- Table to prevent spamming damage events

-- GUI Creation (This part is mostly the same, so it's collapsed for brevity)
-- [[ GUI CODE IS UNCHANGED, no need to copy it again if you have it ]]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminToolGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
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
titleLabel.Active = true
local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 8)
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
local radiusLabel = Instance.new("TextLabel", mainFrame)
radiusLabel.Name = "RadiusLabel"
radiusLabel.Size = UDim2.new(1, -30, 0, 20)
radiusLabel.Position = UDim2.new(0, 15, 0, 115)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLabel.Text = "Aura Radius: " .. currentAuraRadius
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
radiusSliderHandle.Position = UDim2.new((AURA_RADIUS_DEFAULT - AURA_RADIUS_MIN) / (AURA_RADIUS_MAX - AURA_RADIUS_MIN), -9, 0.5, -9)
radiusSliderHandle.Image = "rbxassetid://392630590"
radiusSliderHandle.ImageColor3 = Color3.fromRGB(255, 80, 80)
radiusSliderHandle.ScaleType = Enum.ScaleType.Slice
radiusSliderHandle.SliceCenter = Rect.new(100, 100, 100, 100)
local handleCorner = Instance.new("UICorner", radiusSliderHandle)
handleCorner.CornerRadius = UDim.new(1, 0)
local speedLabel = Instance.new("TextLabel", mainFrame)
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -30, 0, 20)
speedLabel.Position = UDim2.new(0, 15, 0, 165)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Text = "Walk Speed: " .. currentWalkSpeed
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
local speedSliderTrack = Instance.new("Frame", mainFrame)
speedSliderTrack.Name = "SpeedSliderTrack"
speedSliderTrack.Size = UDim2.new(1, -30, 0, 8)
speedSliderTrack.Position = UDim2.new(0, 15, 0, 190)
speedSliderTrack.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
speedSliderTrack.BorderColor3 = Color3.fromRGB(15, 15, 15)
local speedTrackCorner = Instance.new("UICorner", speedSliderTrack)
speedTrackCorner.CornerRadius = UDim.new(0, 4)
local speedSliderHandle = Instance.new("ImageButton", speedSliderTrack)
speedSliderHandle.Name = "SpeedSliderHandle"
speedSliderHandle.Size = UDim2.new(0, 18, 0, 18)
speedSliderHandle.Position = UDim2.new((WALK_SPEED_DEFAULT - WALK_SPEED_MIN) / (WALK_SPEED_MAX - WALK_SPEED_MIN), -9, 0.5, -9)
speedSliderHandle.Image = "rbxassetid://392630590"
speedSliderHandle.ImageColor3 = Color3.fromRGB(80, 180, 255)
speedSliderHandle.ScaleType = Enum.ScaleType.Slice
speedSliderHandle.SliceCenter = Rect.new(100, 100, 100, 100)
local speedHandleCorner = Instance.new("UICorner", speedSliderHandle)
speedHandleCorner.CornerRadius = UDim.new(1, 0)

-- --- GUI LOGIC ---

local function updateToggleVisuals(button, enabled)
    local color = enabled and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(180, 80, 80)
    local text = enabled and "ON" or "OFF"
    button.Text = text
    button.BackgroundColor3 = color
end

infJumpToggle.MouseButton1Click:Connect(function()
    isInfJumpEnabled = not isInfJumpEnabled
    updateToggleVisuals(infJumpToggle, isInfJumpEnabled)
end)

auraToggle.MouseButton1Click:Connect(function()
    isAuraEnabled = not isAuraEnabled
    updateToggleVisuals(auraToggle, isAuraEnabled)
end)

local function createSliderLogic(handle, track, minVal, maxVal, label, updateCallback)
    local isDragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseLocation = UserInputService:GetMouseLocation()
            local relativeX = mouseLocation.X - track.AbsolutePosition.X
            local percentage = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.fromScale(percentage, 0.5)
            local value = math.floor(minVal + (percentage * (maxVal - minVal)) + 0.5)
            updateCallback(value)
        end
    end)
end

createSliderLogic(radiusSliderHandle, radiusSliderTrack, AURA_RADIUS_MIN, AURA_RADIUS_MAX, radiusLabel, function(value)
    currentAuraRadius = value
    radiusLabel.Text = "Aura Radius: " .. currentAuraRadius
end)

createSliderLogic(speedSliderHandle, speedSliderTrack, WALK_SPEED_MIN, WALK_SPEED_MAX, speedLabel, function(value)
    currentWalkSpeed = value
    speedLabel.Text = "Walk Speed: " .. currentWalkSpeed
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
    end
end)

local isDraggingWindow = false
local dragStart
local startPos
titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- --- CORE FUNCTIONALITY ---

UserInputService.JumpRequest:Connect(function()
    if isInfJumpEnabled and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Heartbeat:Connect(function()
    if not isAuraEnabled then return end
    
    local playerChar = player.Character
    if not playerChar or not playerChar.PrimaryPart then return end
    
    local tool = playerChar:FindFirstChildOfClass("Tool")
    -- Check if a valid weapon is equipped
    if not tool or not table.find(WEAPON_NAMES, tool.Name) then return end
    
    -- Find the remote event in the tool to fire for damage
    local damageEvent = tool:FindFirstChild("DamageEvent")
    if not damageEvent or not damageEvent:IsA("RemoteEvent") then 
        warn("Kill Aura failed: Held tool '"..tool.Name.."' does not contain a RemoteEvent named 'DamageEvent'.")
        return 
    end

    local playerPos = playerChar.PrimaryPart.Position

    -- Loop through all other players and NPCs
    for _, target in ipairs(workspace:GetDescendants()) do
        if target:IsA("Humanoid") and target.Health > 0 then
            local targetChar = target.Parent
            if targetChar ~= playerChar and targetChar:FindFirstChild("HumanoidRootPart") then
                
                local targetPos = targetChar.HumanoidRootPart.Position
                local distance = (playerPos - targetPos).Magnitude
                
                if distance <= currentAuraRadius then
                    -- Check debounce: has it been at least 0.2 seconds since we last hit this target?
                    if not auraTargetDebounce[target] or tick() - auraTargetDebounce[target] > 0.2 then
                        auraTargetDebounce[target] = tick() -- Update the last hit time
                        
                        -- Fire the remote event, telling the server to hit the target
                        damageEvent:FireServer(target)
                    end
                end
            end
        end
    end
end)

-- Initialize UI state
updateToggleVisuals(infJumpToggle, isInfJumpEnabled)
updateToggleVisuals(auraToggle, isAuraEnabled)
humanoid.WalkSpeed = currentWalkSpeed
