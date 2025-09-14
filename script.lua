-- LocalScript (put in StarterPlayer > StarterPlayerScripts)
-- FINAL COMBINED VERSION

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
    "Rifle", "Pistol", "Weapon", "Tool", "axe", "AXE" -- Add more weapon names as needed
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

-- Enhanced Kill Aura with Multiple Attack Methods
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isAuraEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    -- Get equipped tool
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if not tool then 
        return 
    end
    
    -- Debug: Print tool name when first equipped
    if not tool:GetAttribute("DebugPrinted") then
        print("Kill Aura: Tool equipped -", tool.Name)
        tool:SetAttribute("DebugPrinted", true)
        
        -- Debug: List all children in the tool
        print("Tool children:")
        for _, child in ipairs(tool:GetChildren()) do
            print("  -", child.Name, child.ClassName)
        end
        
        -- Debug: Check handle children
        local handle = tool:FindFirstChild("Handle")
        if handle then
            print("Handle children:")
            for _, child in ipairs(handle:GetChildren()) do
                print("  -", child.Name, child.ClassName)
            end
        end
    end
    
    -- Look for various types of events and functions in the tool
    local damageEvent = tool:FindFirstChild("DamageEvent") or 
                       tool:FindFirstChild("RemoteEvent") or
                       tool:FindFirstChild("Damage") or
                       tool:FindFirstChild("Hit") or
                       tool:FindFirstChild("OnHit") or
                       tool:FindFirstChild("Attack") or
                       tool:FindFirstChild("Strike")
    
    -- Also check tool handle for events
    local handle = tool:FindFirstChild("Handle")
    if not damageEvent and handle then
        damageEvent = handle:FindFirstChild("DamageEvent") or
                     handle:FindFirstChild("RemoteEvent") or
                     handle:FindFirstChild("Damage") or
                     handle:FindFirstChild("Hit")
    end
    
    -- Look for scripts that might handle damage
    local toolScript = tool:FindFirstChild("Script") or tool:FindFirstChild("LocalScript")
    
    local playerPos = player.Character.HumanoidRootPart.Position
    local foundTarget = false
    
    -- Find targets more efficiently - Check both players and NPCs
    local allTargets = {}
    
    -- Add players to targets
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local targetHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                local distance = (playerPos - targetRoot.Position).Magnitude
                if distance <= currentAuraRadius then
                    table.insert(allTargets, {
                        type = "Player",
                        name = otherPlayer.Name,
                        character = otherPlayer.Character,
                        humanoid = targetHumanoid,
                        root = targetRoot,
                        distance = distance
                    })
                end
            end
        end
    end
    
    -- Add NPCs to targets (like rabbits/zombies)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character and obj.Name ~= "Camera" then
            local targetHumanoid = obj:FindFirstChild("Humanoid")
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
            
            if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                local distance = (playerPos - targetRoot.Position).Magnitude
                if distance <= currentAuraRadius then
                    table.insert(allTargets, {
                        type = "NPC",
                        name = obj.Name,
                        character = obj,
                        humanoid = targetHumanoid,
                        root = targetRoot,
                        distance = distance
                    })
                end
            end
        end
    end
    
    -- Attack all targets found
    for _, target in ipairs(allTargets) do
        foundTarget = true
        print("Kill Aura: Targeting", target.type, target.name, "at distance", math.floor(target.distance))
        
        if not auraTargetDebounce[target.humanoid] or tick() - auraTargetDebounce[target.humanoid] > 0.1 then
            auraTargetDebounce[target.humanoid] = tick()
            
            -- Method 1: Try RemoteEvent if found
            if damageEvent and damageEvent:IsA("RemoteEvent") then
                pcall(function()
                    damageEvent:FireServer(target.humanoid)
                    print("Kill Aura: Fired RemoteEvent with humanoid")
                end)
                pcall(function()
                    damageEvent:FireServer(target.character)
                    print("Kill Aura: Fired RemoteEvent with character")
                end)
                pcall(function()
                    damageEvent:FireServer(target.root)
                    print("Kill Aura: Fired RemoteEvent with root")
                end)
            end
            
            -- Method 2: Tool Activation (most common for tools)
            pcall(function()
                tool:Activate()
                print("Kill Aura: Activated tool")
            end)
            
            -- Method 3: Simulate mouse click on target
            pcall(function()
                tool:FireServer("MouseClick", target.root.Position)
                print("Kill Aura: Fired MouseClick")
            end)
            
            -- Method 4: Try touching the target with the tool handle
            if handle then
                pcall(function()
                    -- Temporarily move handle to target position
                    local originalCFrame = handle.CFrame
                    handle.CFrame = target.root.CFrame
                    wait(0.01)
                    handle.CFrame = originalCFrame
                    print("Kill Aura: Moved handle to target")
                end)
            end
            
            -- Method 5: Direct damage to humanoid (if possible)
            pcall(function()
                target.humanoid:TakeDamage(10)
                print("Kill Aura: Applied direct damage")
            end)
            
            -- Method 6: Try common weapon event names
            local commonEvents = {"Hit", "Damage", "Attack", "Strike", "Swing"}
            for _, eventName in ipairs(commonEvents) do
                local event = tool:FindFirstChild(eventName)
                if event and event:IsA("RemoteEvent") then
                    pcall(function()
                        event:FireServer(target.humanoid)
                        print("Kill Aura: Fired", eventName, "event")
                    end)
                end
            end
            
            -- Method 7: Try BindableEvent for local tools
            for _, child in ipairs(tool:GetChildren()) do
                if child:IsA("BindableEvent") then
                    pcall(function()
                        child:Fire(target.humanoid)
                        print("Kill Aura: Fired BindableEvent", child.Name)
                    end)
                end
            end
        end
    end
    
    -- Debug: Print if no targets found
    if not foundTarget and tool:GetAttribute("DebugPrinted") then
        -- Only print occasionally to avoid spam
        if not tool:GetAttribute("LastNoTargetPrint") or tick() - tool:GetAttribute("LastNoTargetPrint") > 3 then
            print("Kill Aura: No targets found within radius", currentAuraRadius)
            tool:SetAttribute("LastNoTargetPrint", tick())
            
            -- Debug: List nearby objects to help understand what's around
            print("Nearby objects:")
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= player.Character then
                    local objRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                    if objRoot then
                        local distance = (playerPos - objRoot.Position).Magnitude
                        if distance <= 100 then -- Show objects within 100 studs
                            print("  -", obj.Name, "at distance", math.floor(distance), "Health:", obj:FindFirstChild("Humanoid") and obj.Humanoid.Health or "No Humanoid")
                        end
                    end
                end
            end
        end
    end
end))

-- Initialize UI state
updateToggleVisuals(infJumpToggle,isInfJumpEnabled) updateToggleVisuals(auraToggle,isAuraEnabled) humanoid.WalkSpeed=currentWalkSpeed