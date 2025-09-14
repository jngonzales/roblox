-- LocalScript (put in StarterPlayer > StarterPlayerScripts)
-- FINAL COMBINED VERSION  dd

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player & Character Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- This table will hold all active connections so we can disconnect them later
local connections = {}

-- Function to re-assign character and humanoid if player respawns
table.insert(connections, player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentWalkSpeed -- Reapply walk speed on respawn
    
    -- Reapply infinite jump capability
    if isInfJumpEnabled then
        humanoid.JumpHeight = 50 -- Ensure jump height is set
    end
end))

-- Configuration
local AURA_RADIUS_MIN = 10
local AURA_RADIUS_MAX = 200
local AURA_RADIUS_DEFAULT = 50
local WALK_SPEED_MIN = 16
local WALK_SPEED_MAX = 100
local WALK_SPEED_DEFAULT = 16
local WEAPON_NAMES = { 
    "ClassicSword", "Axe", "Iron Hammer", "Sword", "Blade", "Knife", 
    "Dagger", "Spear", "Mace", "Club", "Staff", "Wand", "Bow", "Gun",
    "Rifle", "Pistol", "Weapon", "Tool" -- Add more weapon names as needed
}

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT
local currentWalkSpeed = WALK_SPEED_DEFAULT
local auraTargetDebounce = {}

-- GUI Creation
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

--[[ ... Other GUI Elements ... ]]
local infJumpLabel=Instance.new("TextLabel",mainFrame);infJumpLabel.Name="InfJumpLabel";infJumpLabel.Size=UDim2.new(0,150,0,30);infJumpLabel.Position=UDim2.new(0,15,0,40);infJumpLabel.BackgroundTransparency=1;infJumpLabel.TextColor3=Color3.fromRGB(220,220,220);infJumpLabel.Text="Infinite Jump";infJumpLabel.Font=Enum.Font.SourceSans;infJumpLabel.TextSize=16;infJumpLabel.TextXAlignment=Enum.TextXAlignment.Left;local infJumpToggle=Instance.new("TextButton",mainFrame);infJumpToggle.Name="InfJumpToggle";infJumpToggle.Size=UDim2.new(0,80,0,25);infJumpToggle.Position=UDim2.new(1,-95,0,42.5);infJumpToggle.Font=Enum.Font.SourceSansBold;infJumpToggle.Text="OFF";infJumpToggle.TextColor3=Color3.fromRGB(255,255,255);infJumpToggle.TextSize=14;local infJumpCorner=Instance.new("UICorner",infJumpToggle);infJumpCorner.CornerRadius=UDim.new(0,6);local auraLabel=Instance.new("TextLabel",mainFrame);auraLabel.Name="AuraLabel";auraLabel.Size=UDim2.new(0,150,0,30);auraLabel.Position=UDim2.new(0,15,0,80);auraLabel.BackgroundTransparency=1;auraLabel.TextColor3=Color3.fromRGB(220,220,220);auraLabel.Text="Kill Aura";auraLabel.Font=Enum.Font.SourceSans;auraLabel.TextSize=16;auraLabel.TextXAlignment=Enum.TextXAlignment.Left;local auraToggle=Instance.new("TextButton",mainFrame);auraToggle.Name="AuraToggle";auraToggle.Size=UDim2.new(0,80,0,25);auraToggle.Position=UDim2.new(1,-95,0,82.5);auraToggle.Font=Enum.Font.SourceSansBold;auraToggle.Text="OFF";auraToggle.TextColor3=Color3.fromRGB(255,255,255);auraToggle.TextSize=14;local auraCorner=Instance.new("UICorner",auraToggle);auraCorner.CornerRadius=UDim.new(0,6);local radiusLabel=Instance.new("TextLabel",mainFrame);radiusLabel.Name="RadiusLabel";radiusLabel.Size=UDim2.new(1,-30,0,20);radiusLabel.Position=UDim2.new(0,15,0,115);radiusLabel.BackgroundTransparency=1;radiusLabel.TextColor3=Color3.fromRGB(200,200,200);radiusLabel.Text="Aura Radius: "..currentAuraRadius;radiusLabel.Font=Enum.Font.SourceSans;radiusLabel.TextSize=14;radiusLabel.TextXAlignment=Enum.TextXAlignment.Left;local radiusSliderTrack=Instance.new("Frame",mainFrame);radiusSliderTrack.Name="RadiusSliderTrack";radiusSliderTrack.Size=UDim2.new(1,-30,0,8);radiusSliderTrack.Position=UDim2.new(0,15,0,140);radiusSliderTrack.BackgroundColor3=Color3.fromRGB(25,27,30);radiusSliderTrack.BorderColor3=Color3.fromRGB(15,15,15);local trackCorner=Instance.new("UICorner",radiusSliderTrack);trackCorner.CornerRadius=UDim.new(0,4);local radiusSliderHandle=Instance.new("ImageButton",radiusSliderTrack);radiusSliderHandle.Name="RadiusSliderHandle";radiusSliderHandle.Size=UDim2.new(0,18,0,18);radiusSliderHandle.Position=UDim2.new((AURA_RADIUS_DEFAULT-AURA_RADIUS_MIN)/(AURA_RADIUS_MAX-AURA_RADIUS_MIN),-9,0.5,-9);radiusSliderHandle.Image="rbxassetid://392630590";radiusSliderHandle.ImageColor3=Color3.fromRGB(255,80,80);radiusSliderHandle.ScaleType=Enum.ScaleType.Slice;radiusSliderHandle.SliceCenter=Rect.new(100,100,100,100);local handleCorner=Instance.new("UICorner",radiusSliderHandle);handleCorner.CornerRadius=UDim.new(1,0);local speedLabel=Instance.new("TextLabel",mainFrame);speedLabel.Name="SpeedLabel";speedLabel.Size=UDim2.new(1,-30,0,20);speedLabel.Position=UDim2.new(0,15,0,165);speedLabel.BackgroundTransparency=1;speedLabel.TextColor3=Color3.fromRGB(200,200,200);speedLabel.Text="Walk Speed: "..currentWalkSpeed;speedLabel.Font=Enum.Font.SourceSans;speedLabel.TextSize=14;speedLabel.TextXAlignment=Enum.TextXAlignment.Left;local speedSliderTrack=Instance.new("Frame",mainFrame);speedSliderTrack.Name="SpeedSliderTrack";speedSliderTrack.Size=UDim2.new(1,-30,0,8);speedSliderTrack.Position=UDim2.new(0,15,0,190);speedSliderTrack.BackgroundColor3=Color3.fromRGB(25,27,30);speedSliderTrack.BorderColor3=Color3.fromRGB(15,15,15);local speedTrackCorner=Instance.new("UICorner",speedSliderTrack);speedTrackCorner.CornerRadius=UDim.new(0,4);local speedSliderHandle=Instance.new("ImageButton",speedSliderTrack);speedSliderHandle.Name="SpeedSliderHandle";speedSliderHandle.Size=UDim2.new(0,18,0,18);speedSliderHandle.Position=UDim2.new((WALK_SPEED_DEFAULT-WALK_SPEED_MIN)/(WALK_SPEED_MAX-WALK_SPEED_MIN),-9,0.5,-9);speedSliderHandle.Image="rbxassetid://392630590";speedSliderHandle.ImageColor3=Color3.fromRGB(80,180,255);speedSliderHandle.ScaleType=Enum.ScaleType.Slice;speedSliderHandle.SliceCenter=Rect.new(100,100,100,100);local speedHandleCorner=Instance.new("UICorner",speedSliderHandle);speedHandleCorner.CornerRadius=UDim.new(1,0);

-- --- Close Button ---
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "X"
closeButton.TextSize = 14
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 4)

-- --- GUI LOGIC ---
local function updateToggleVisuals(button,enabled) button.Text=enabled and "ON" or "OFF" button.BackgroundColor3=enabled and Color3.fromRGB(80,180,80) or Color3.fromRGB(180,80,80) end
table.insert(connections,infJumpToggle.MouseButton1Click:Connect(function() isInfJumpEnabled=not isInfJumpEnabled updateToggleVisuals(infJumpToggle,isInfJumpEnabled) end))
table.insert(connections,auraToggle.MouseButton1Click:Connect(function() isAuraEnabled=not isAuraEnabled updateToggleVisuals(auraToggle,isAuraEnabled) end))
table.insert(connections,closeButton.MouseButton1Click:Connect(function() if humanoid then humanoid.WalkSpeed=WALK_SPEED_DEFAULT end for _,c in ipairs(connections) do c:Disconnect() end screenGui:Destroy() end))

local function createSliderLogic(handle,track,minVal,maxVal,label,updateCallback) local isDragging=false table.insert(connections,handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then isDragging=true end end)) table.insert(connections,handle.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then isDragging=false end end)) table.insert(connections,UserInputService.InputChanged:Connect(function(i) if isDragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local p=math.clamp((UserInputService:GetMouseLocation().X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1) handle.Position=UDim2.fromScale(p,0.5) local v=math.floor(minVal+(p*(maxVal-minVal))+.5) updateCallback(v) end end)) end
createSliderLogic(radiusSliderHandle,radiusSliderTrack,AURA_RADIUS_MIN,AURA_RADIUS_MAX,radiusLabel,function(v) currentAuraRadius=v;radiusLabel.Text="Aura Radius: "..v end)
createSliderLogic(speedSliderHandle,speedSliderTrack,WALK_SPEED_MIN,WALK_SPEED_MAX,speedLabel,function(v) currentWalkSpeed=v;speedLabel.Text="Walk Speed: "..v if humanoid then humanoid.WalkSpeed=v end end)

local isDraggingWindow,dragStart,startPos=false table.insert(connections,titleLabel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then isDraggingWindow,dragStart,startPos=true,i.Position,mainFrame.Position end end)) table.insert(connections,titleLabel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then isDraggingWindow=false end end)) table.insert(connections,UserInputService.InputChanged:Connect(function(i) if isDraggingWindow and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then mainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+(i.Position-dragStart).X,startPos.Y.Scale,startPos.Y.Offset+(i.Position-dragStart).Y)end end))

-- --- CORE FUNCTIONALITY ---
-- Improved Infinite Jump
table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if isInfJumpEnabled and humanoid and humanoid.Health > 0 then
        -- Allow jumping regardless of current state
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Additional jump input handling for better reliability
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Space and isInfJumpEnabled and humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Enhanced Kill Aura
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isAuraEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    -- Get equipped tool
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if not tool then 
        return 
    end
    
    -- Check if tool is a weapon (more flexible weapon detection)
    local isWeapon = false
    for _, weaponName in ipairs(WEAPON_NAMES) do
        if string.find(tool.Name:lower(), weaponName:lower()) then
            isWeapon = true
            break
        end
    end
    
    if not isWeapon then
        return
    end
    
    -- Look for damage-related events in the tool
    local damageEvent = tool:FindFirstChild("DamageEvent") or 
                       tool:FindFirstChild("RemoteEvent") or
                       tool:FindFirstChild("Damage") or
                       tool:FindFirstChild("Hit")
    
    if not damageEvent or not damageEvent:IsA("RemoteEvent") then
        return
    end
    
    local playerPos = player.Character.HumanoidRootPart.Position
    
    -- Find targets more efficiently
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local targetHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                local distance = (playerPos - targetRoot.Position).Magnitude
                
                if distance <= currentAuraRadius then
                    -- Use debounce to prevent spam
                    if not auraTargetDebounce[targetHumanoid] or tick() - auraTargetDebounce[targetHumanoid] > 0.1 then
                        auraTargetDebounce[targetHumanoid] = tick()
                        
                        -- Try different ways to fire the damage event
                        pcall(function()
                            damageEvent:FireServer(targetHumanoid)
                        end)
                        pcall(function()
                            damageEvent:FireServer(otherPlayer.Character)
                        end)
                        pcall(function()
                            damageEvent:FireServer(targetRoot)
                        end)
                    end
                end
            end
        end
    end
    
    -- Also check NPCs/Monsters in workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local targetHumanoid = obj:FindFirstChild("Humanoid")
            local targetRoot = obj:FindFirstChild("HumanoidRootPart")
            
            if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                local distance = (playerPos - targetRoot.Position).Magnitude
                
                if distance <= currentAuraRadius then
                    if not auraTargetDebounce[targetHumanoid] or tick() - auraTargetDebounce[targetHumanoid] > 0.1 then
                        auraTargetDebounce[targetHumanoid] = tick()
                        
                        pcall(function()
                            damageEvent:FireServer(targetHumanoid)
                        end)
                        pcall(function()
                            damageEvent:FireServer(obj)
                        end)
                        pcall(function()
                            damageEvent:FireServer(targetRoot)
                        end)
                    end
                end
            end
        end
    end
end))

-- Initialize UI state
updateToggleVisuals(infJumpToggle,isInfJumpEnabled) updateToggleVisuals(auraToggle,isAuraEnabled) humanoid.WalkSpeed=currentWalkSpeed
