-- LocalScript (put in StarterPlayer > StarterPlayerScripts)
-- WORKING SURVIVAL GAME SCRIPT

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player & Character Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- This table will hold all active connections so we can disconnect them later
local connections = {}

-- Function to re-assign character and humanoid if player respawns
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentWalkSpeed
    
    if isInfJumpEnabled then
        humanoid.JumpHeight = 50
    end
end
table.insert(connections, player.CharacterAdded:Connect(onCharacterAdded))

-- Configuration
local AURA_RADIUS_MIN = 10
local AURA_RADIUS_MAX = 200
local AURA_RADIUS_DEFAULT = 50
local WALK_SPEED_MIN = 16
local WALK_SPEED_MAX = 100
local WALK_SPEED_DEFAULT = 16

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT
local currentWalkSpeed = WALK_SPEED_DEFAULT
local isResourceFarmEnabled = false
local currentResourceRadius = 50

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SurvivalModMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main container
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "🌲 SURVIVAL GAME MODS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton", titleBar)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextSize = 14
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 6)

-- Content area
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0

-- Layout
local layout = Instance.new("UIListLayout", contentFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)

-- Function to create toggles
local function createToggle(parent, name, layoutOrder)
    local toggle = Instance.new("Frame", parent)
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, 35)
    toggle.BackgroundTransparency = 1
    toggle.LayoutOrder = layoutOrder
    
    local label = Instance.new("TextLabel", toggle)
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton", toggle)
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(1, -70, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.Text = "OFF"
    button.TextSize = 12
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner", button)
    buttonCorner.CornerRadius = UDim.new(0, 6)
    
    return button
end

-- Function to create sliders
local function createSlider(parent, name, min, max, default, layoutOrder)
    local slider = Instance.new("Frame", parent)
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(1, 0, 0, 50)
    slider.BackgroundTransparency = 1
    slider.LayoutOrder = layoutOrder
    
    local label = Instance.new("TextLabel", slider)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", slider)
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0, 25)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    track.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local handle = Instance.new("ImageButton", track)
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Image = ""
    
    local handleCorner = Instance.new("UICorner", handle)
    handleCorner.CornerRadius = UDim.new(1, 0)
    
    return handle, track, fill, label
end

-- Create toggles
local infJumpButton = createToggle(contentFrame, "Infinite Jump", 1)
local killAuraButton = createToggle(contentFrame, "Kill Aura", 2)
local resourceFarmButton = createToggle(contentFrame, "Resource Farm", 3)

-- Create sliders
local speedHandle, speedTrack, speedFill, speedLabel = createSlider(contentFrame, "Walk Speed", WALK_SPEED_MIN, WALK_SPEED_MAX, WALK_SPEED_DEFAULT, 4)
local auraHandle, auraTrack, auraFill, auraLabel = createSlider(contentFrame, "Aura Radius", AURA_RADIUS_MIN, AURA_RADIUS_MAX, AURA_RADIUS_DEFAULT, 5)

-- Toggle update function
local function updateToggle(button, enabled)
    button.Text = enabled and "ON" or "OFF"
    button.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(180, 80, 80)
end

-- Slider logic function
local function createSliderLogic(handle, track, fill, label, minVal, maxVal, currentVal, updateCallback)
    local isDragging = false
    
    local function updateSlider(percentage)
        local value = math.floor(minVal + (percentage * (maxVal - minVal)) + 0.5)
        handle.Position = UDim2.new(percentage, -8, 0.5, -8)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        updateCallback(value)
    end
    
    table.insert(connections, handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end))
    
    table.insert(connections, handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSlider(percentage)
        end
    end))
    
    local initialPercentage = (currentVal - minVal) / (maxVal - minVal)
    updateSlider(initialPercentage)
end

-- Setup sliders
createSliderLogic(speedHandle, speedTrack, speedFill, speedLabel, WALK_SPEED_MIN, WALK_SPEED_MAX, currentWalkSpeed, function(v) 
    currentWalkSpeed = v
    speedLabel.Text = "Walk Speed: " .. v 
    if humanoid then humanoid.WalkSpeed = v end 
end)

createSliderLogic(auraHandle, auraTrack, auraFill, auraLabel, AURA_RADIUS_MIN, AURA_RADIUS_MAX, currentAuraRadius, function(v) 
    currentAuraRadius = v
    auraLabel.Text = "Aura Radius: " .. v 
end)

-- Toggle connections
table.insert(connections, infJumpButton.MouseButton1Click:Connect(function() 
    isInfJumpEnabled = not isInfJumpEnabled 
    updateToggle(infJumpButton, isInfJumpEnabled) 
end))

table.insert(connections, killAuraButton.MouseButton1Click:Connect(function() 
    isAuraEnabled = not isAuraEnabled 
    updateToggle(killAuraButton, isAuraEnabled) 
end))

table.insert(connections, resourceFarmButton.MouseButton1Click:Connect(function() 
    isResourceFarmEnabled = not isResourceFarmEnabled 
    updateToggle(resourceFarmButton, isResourceFarmEnabled) 
end))

table.insert(connections, closeButton.MouseButton1Click:Connect(function() 
    if humanoid then humanoid.WalkSpeed = WALK_SPEED_DEFAULT end 
    for _, c in ipairs(connections) do c:Disconnect() end 
    screenGui:Destroy() 
end))

-- Dragging functionality
local isDragging, dragStart, startPos = false

table.insert(connections, titleBar.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isDragging, dragStart, startPos = true, input.Position, mainFrame.Position 
    end 
end))

table.insert(connections, titleBar.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isDragging = false 
    end 
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input) 
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + (input.Position - dragStart).X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + (input.Position - dragStart).Y
        )
    end 
end))

-- INFINITE JUMP
table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if isInfJumpEnabled and humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- KILL AURA
local lastAuraTime = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isAuraEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local currentTime = tick()
    if currentTime - lastAuraTime < 0.5 then return end -- Cooldown
    
    local playerPos = player.Character.HumanoidRootPart.Position
    local foundTarget = false
    
    -- Search for monsters in MonsterFolder
    local monsterFolder = workspace:FindFirstChild("MonsterFolder")
    if monsterFolder then
        for _, obj in ipairs(monsterFolder:GetChildren()) do
            if obj:IsA("Model") and obj ~= player.Character then
                local targetHumanoid = obj:FindFirstChild("Humanoid") or obj:FindFirstChildOfClass("Humanoid")
                local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                
                if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                    local distance = (playerPos - targetRoot.Position).Magnitude
                    if distance <= currentAuraRadius then
                        foundTarget = true
                        lastAuraTime = currentTime
                        
                        -- Try to damage the target
                        pcall(function()
                            targetHumanoid.Health = math.max(0, targetHumanoid.Health - math.random(20, 40))
                        end)
                        
                        print("Kill Aura: Attacking", obj.Name, "at distance", math.floor(distance))
                        break
                    end
                end
            end
        end
    end
    
    -- If no monsters found, search workspace for hostile creatures
    if not foundTarget then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= player.Character and obj.Name ~= "Camera" then
                local targetHumanoid = obj:FindFirstChild("Humanoid") or obj:FindFirstChildOfClass("Humanoid")
                local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                
                if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                    local distance = (playerPos - targetRoot.Position).Magnitude
                    if distance <= currentAuraRadius then
                        -- Check if it's a hostile creature
                        local objName = string.lower(obj.Name)
                        local isHostile = string.find(objName, "wolf") or string.find(objName, "bear") or 
                                         string.find(objName, "zombie") or string.find(objName, "monster") or
                                         string.find(objName, "enemy") or string.find(objName, "hostile")
                        
                        if isHostile then
                            foundTarget = true
                            lastAuraTime = currentTime
                            
                            pcall(function()
                                targetHumanoid.Health = math.max(0, targetHumanoid.Health - math.random(20, 40))
                            end)
                            
                            print("Kill Aura: Attacking", obj.Name, "at distance", math.floor(distance))
                            break
                        end
                    end
                end
            end
        end
    end
end))

-- RESOURCE FARMING
local lastFarmTime = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isResourceFarmEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local currentTime = tick()
    if currentTime - lastFarmTime < 1 then return end -- Cooldown
    
    local playerPos = player.Character.HumanoidRootPart.Position
    
    -- Search for resources in SceneFolder
    local sceneFolder = workspace:FindFirstChild("SceneFolder")
    if sceneFolder then
        for _, obj in ipairs(sceneFolder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                
                if targetPart then
                    local distance = (playerPos - targetPart.Position).Magnitude
                    if distance <= currentResourceRadius then
                        local objName = string.lower(obj.Name)
                        local isResource = string.find(objName, "tree") or string.find(objName, "wood") or 
                                          string.find(objName, "rock") or string.find(objName, "stone") or
                                          string.find(objName, "berry") or string.find(objName, "fruit") or
                                          string.find(objName, "resource")
                        
                        if isResource then
                            lastFarmTime = currentTime
                            
                            -- Try to click/interact with resource
                            local clickDetector = obj:FindFirstChild("ClickDetector")
                            local proximityPrompt = obj:FindFirstChild("ProximityPrompt")
                            
                            if clickDetector then
                                pcall(function()
                                    fireclickdetector(clickDetector)
                                end)
                                print("Resource Farm: Clicked", obj.Name)
                            elseif proximityPrompt then
                                pcall(function()
                                    fireproximityprompt(proximityPrompt)
                                end)
                                print("Resource Farm: Triggered", obj.Name)
                            else
                                -- Try to destroy/collect resource
                                pcall(function()
                                    obj:Destroy()
                                end)
                                print("Resource Farm: Collected", obj.Name)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end))

-- Initialize
updateToggle(infJumpButton, isInfJumpEnabled)
updateToggle(killAuraButton, isAuraEnabled)
updateToggle(resourceFarmButton, isResourceFarmEnabled)
humanoid.WalkSpeed = currentWalkSpeed

print("🌲 Survival Game Mod Menu Loaded Successfully!")
print("Features: Kill Aura, Resource Farm, Infinite Jump, Speed Hack")
print("Optimized for survival games like 99 Nights in Forest")
