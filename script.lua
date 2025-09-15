
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Executor compatibility checks
local isExecutor = true
local executorName = identifyexecutor and identifyexecutor() or "Unknown"
print("Running on executor:", executorName)

-- Safe executor function calls
local function safeExecutorCall(func, ...)
    if func then
        return pcall(func, ...)
    end
    return false
end

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
    "Rifle", "Pistol", "Weapon", "Tool", "axe", "AXE",
    -- Survival game tools (like 99 Nights in the Forest)
    "Hatchet", "hatchet", "Pickaxe", "pickaxe", "Shovel", "shovel",
    "Hammer", "hammer", "Chisel", "chisel", "Saw", "saw", "Chainsaw", "chainsaw",
    "WoodAxe", "StoneAxe", "IronAxe", "SteelAxe", "Fishing Rod", "FishingRod",
    "Net", "net", "Trap", "trap", "Slingshot", "slingshot"
}

-- Email Configuration
local EMAIL_ADDRESS = "jngonz24@gmail.com"
local EMAIL_ENABLED = true

-- Tree Kill Aura Configuration
local TREE_AURA_RADIUS_MIN = 5
local TREE_AURA_RADIUS_MAX = 200
local TREE_AURA_RADIUS_DEFAULT = 50
local TREE_NAMES = {
    "tree", "Tree", "TREE", "tree5", "tree1", "Model2", "Fence", "fence", "FENCE",
    "Fence2", "Fence3", "Fence4", "Fence5", "Fence6", "Fence7", "Fence8", "Fence9",
    "Fence20", "Fence21", "Fence22", "Fence23", "Fence24", "Fence25", "Fence26", "Fence27", "Fence28", "Fence29", "Fence30",
    -- Survival game resources (like 99 Nights in the Forest)
    "Wood", "wood", "Log", "log", "Branch", "branch", "Stone", "stone", "Rock", "rock",
    "Berry", "berry", "Bush", "bush", "Plant", "plant", "Grass", "grass", "Flower", "flower",
    "Stick", "stick", "Twig", "twig", "Leaf", "leaf", "Apple", "apple", "Fruit", "fruit",
    "Pine", "pine", "Oak", "oak", "Birch", "birch", "Maple", "maple", "Cedar", "cedar",
    -- Generic survival resource models
    "Resource", "resource", "Item", "item", "Pickup", "pickup", "Collectible", "collectible"
}

-- Tree farming specific paths (updated for survival games)
local TREE_FOLDER_PATHS = {
    "SceneFolder",  -- Main folder with 3670 children detected
    "SceneFolder/Folder",  -- This path exists according to debug
    "SceneFolder/00011/SceneFolder/Folder",
    "Trees", "TreeFolder", "Resources", "ResourceFolder",
    "Items", "ItemFolder", "Collectibles", "CollectibleFolder",
    "Environment", "EnvironmentFolder", "Nature", "NatureFolder"
}

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT
local currentWalkSpeed = WALK_SPEED_DEFAULT
local auraTargetDebounce = {}

-- Tree Kill Aura State Variables
local isTreeAuraEnabled = false
local currentTreeAuraRadius = TREE_AURA_RADIUS_DEFAULT
local treeAuraTargetDebounce = {}
local isTreeDebugMode = false
local lastTreeDebugTime = 0 -- Add cooldown for debug spam

-- Console logging system
local consoleLog = {}
local originalPrint = print

-- Override print function to capture all output
print = function(...)
    local args = {...}
    local message = ""
    for i, v in ipairs(args) do
        message = message .. tostring(v)
        if i < #args then message = message .. " " end
    end
    
    -- Add timestamp
    local timestamp = os.date("[%H:%M:%S] ")
    local logEntry = timestamp .. message
    
    -- Store in log
    table.insert(consoleLog, logEntry)
    
    -- Keep only last 500 lines to prevent memory issues
    if #consoleLog > 500 then
        table.remove(consoleLog, 1)
    end
    
    -- Call original print
    originalPrint(...)
end

-- GUI Creation - Premium Mod Menu
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumModMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main container with modern styling
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 480)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

-- Main frame gradient
local mainGradient = Instance.new("UIGradient", mainFrame)
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 17)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
}
mainGradient.Rotation = 45

-- Main frame corner
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Stroke for premium look
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(70, 130, 255)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3

-- Title bar with glow effect
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
titleBar.BorderSizePixel = 0
titleBar.Active = true

local titleGradient = Instance.new("UIGradient", titleBar)
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
}

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

-- Title text with premium styling
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "⚡ PREMIUM MOD MENU ⚡"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Title shadow effect
local titleShadow = Instance.new("TextLabel", titleBar)
titleShadow.Name = "TitleShadow"
titleShadow.Size = titleLabel.Size
titleShadow.Position = UDim2.new(0, 17, 0, 2)
titleShadow.BackgroundTransparency = 1
titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
titleShadow.Text = titleLabel.Text
titleShadow.Font = titleLabel.Font
titleShadow.TextSize = titleLabel.TextSize
titleShadow.TextXAlignment = titleLabel.TextXAlignment
titleShadow.TextTransparency = 0.5
titleShadow.ZIndex = titleLabel.ZIndex - 1

-- Close button with hover effects
local closeButton = Instance.new("TextButton", titleBar)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "✕"
closeButton.TextSize = 16
closeButton.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 8)

-- Content area with scroll
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)

-- Content layout
local contentLayout = Instance.new("UIListLayout", contentFrame)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 15)

-- Function to create premium sections
local function createSection(title, layoutOrder)
    local section = Instance.new("Frame", contentFrame)
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, -20, 0, 120)
    section.Position = UDim2.new(0, 10, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    section.BorderSizePixel = 0
    section.LayoutOrder = layoutOrder
    
    local sectionGradient = Instance.new("UIGradient", section)
    sectionGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    }
    
    local sectionCorner = Instance.new("UICorner", section)
    sectionCorner.CornerRadius = UDim.new(0, 10)
    
    local sectionStroke = Instance.new("UIStroke", section)
    sectionStroke.Color = Color3.fromRGB(50, 50, 55)
    sectionStroke.Thickness = 1
    sectionStroke.Transparency = 0.5
    
    -- Section title
    local sectionTitle = Instance.new("TextLabel", section)
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Size = UDim2.new(1, -20, 0, 30)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.TextColor3 = Color3.fromRGB(70, 130, 255)
    sectionTitle.Text = "━━ " .. title .. " ━━"
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 16
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    return section
end

-- Function to create premium toggle
local function createToggle(parent, name, position, layoutOrder)
    local toggle = Instance.new("Frame", parent)
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 35)
    toggle.Position = position
    toggle.BackgroundTransparency = 1
    toggle.LayoutOrder = layoutOrder
    
    local toggleLabel = Instance.new("TextLabel", toggle)
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0, 200, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.Text = name
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("TextButton", toggle)
    toggleButton.Name = "Button"
    toggleButton.Size = UDim2.new(0, 60, 0, 25)
    toggleButton.Position = UDim2.new(1, -70, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "OFF"
    toggleButton.TextSize = 12
    toggleButton.BorderSizePixel = 0
    
    local toggleCorner = Instance.new("UICorner", toggleButton)
    toggleCorner.CornerRadius = UDim.new(0, 6)
    
    local toggleStroke = Instance.new("UIStroke", toggleButton)
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.8
    
    return toggle, toggleButton
end

-- Function to create premium slider
local function createSlider(parent, name, min, max, default, position, layoutOrder)
    local slider = Instance.new("Frame", parent)
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(1, -20, 0, 50)
    slider.Position = position
    slider.BackgroundTransparency = 1
    slider.LayoutOrder = layoutOrder
    
    local sliderLabel = Instance.new("TextLabel", slider)
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(1, -20, 0, 20)
    sliderLabel.Position = UDim2.new(0, 10, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 13
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderTrack = Instance.new("Frame", slider)
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -20, 0, 8)
    sliderTrack.Position = UDim2.new(0, 10, 0, 25)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderTrack.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner", sliderTrack)
    trackCorner.CornerRadius = UDim.new(0, 4)
    
    local sliderFill = Instance.new("Frame", sliderTrack)
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local sliderHandle = Instance.new("ImageButton", sliderTrack)
    sliderHandle.Name = "Handle"
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Image = ""
    
    local handleCorner = Instance.new("UICorner", sliderHandle)
    handleCorner.CornerRadius = UDim.new(1, 0)
    
    local handleStroke = Instance.new("UIStroke", sliderHandle)
    handleStroke.Color = Color3.fromRGB(70, 130, 255)
    handleStroke.Thickness = 2
    
    return slider, sliderHandle, sliderTrack, sliderLabel, sliderFill
end

-- Create sections
local combatSection = createSection("⚔️ COMBAT", 1)
local movementSection = createSection("🏃 MOVEMENT", 2)
local farmingSection = createSection("� RESOURCE FARMING", 3)

-- Combat section elements
local infJumpToggle, infJumpButton = createToggle(combatSection, "Infinite Jump", UDim2.new(0, 0, 0, 35), 1)
local auraToggle, auraButton = createToggle(combatSection, "Kill Aura", UDim2.new(0, 0, 0, 70), 2)

-- Movement section elements  
local speedSlider, speedHandle, speedTrack, speedLabel, speedFill = createSlider(movementSection, "Walk Speed", WALK_SPEED_MIN, WALK_SPEED_MAX, WALK_SPEED_DEFAULT, UDim2.new(0, 0, 0, 35), 1)

-- Farming section elements
local treeAuraToggle, treeAuraButton = createToggle(farmingSection, "Resource Auto-Farm", UDim2.new(0, 0, 0, 35), 1)
local treeRadiusSlider, treeRadiusHandle, treeRadiusTrack, treeRadiusLabel, treeRadiusFill = createSlider(farmingSection, "Farm Radius", TREE_AURA_RADIUS_MIN, TREE_AURA_RADIUS_MAX, TREE_AURA_RADIUS_DEFAULT, UDim2.new(0, 0, 0, 70), 2)

-- Add debug toggle for resource detection
local treeDebugToggle, treeDebugButton = createToggle(farmingSection, "Resource Debug Mode", UDim2.new(0, 0, 0, 105), 3)

-- NEW: Add debug export buttons
local debugExportToggle, debugExportButton = createToggle(farmingSection, "Save & Email Log", UDim2.new(0, 0, 0, 140), 4)

-- Expand farming section to accommodate debug toggles
farmingSection.Size = UDim2.new(1, -20, 0, 190)

-- Combat radius slider (add to combat section)
combatSection.Size = UDim2.new(1, -20, 0, 170) -- Increase height
local auraRadiusSlider, auraRadiusHandle, auraRadiusTrack, auraRadiusLabel, auraRadiusFill = createSlider(combatSection, "Aura Radius", AURA_RADIUS_MIN, AURA_RADIUS_MAX, AURA_RADIUS_DEFAULT, UDim2.new(0, 0, 0, 105), 3)

-- --- PREMIUM GUI LOGIC ---
local function updateToggleVisuals(button, enabled)
    button.Text = enabled and "ON" or "OFF"
    button.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(180, 80, 80)
    
    -- Add glow effect for enabled state
    if enabled then
        if not button:FindFirstChild("Glow") then
            local glow = Instance.new("ImageLabel", button)
            glow.Name = "Glow"
            glow.Size = UDim2.new(1, 10, 1, 10)
            glow.Position = UDim2.new(0, -5, 0, -5)
            glow.BackgroundTransparency = 1
            glow.Image = "rbxassetid://5028857084"
            glow.ImageColor3 = Color3.fromRGB(80, 200, 120)
            glow.ImageTransparency = 0.5
            glow.ZIndex = button.ZIndex - 1
        end
    else
        local glow = button:FindFirstChild("Glow")
        if glow then glow:Destroy() end
    end
end

-- Toggle connections
table.insert(connections, infJumpButton.MouseButton1Click:Connect(function() 
    isInfJumpEnabled = not isInfJumpEnabled 
    updateToggleVisuals(infJumpButton, isInfJumpEnabled) 
end))

table.insert(connections, auraButton.MouseButton1Click:Connect(function() 
    isAuraEnabled = not isAuraEnabled 
    updateToggleVisuals(auraButton, isAuraEnabled) 
end))

table.insert(connections, treeAuraButton.MouseButton1Click:Connect(function() 
    isTreeAuraEnabled = not isTreeAuraEnabled 
    updateToggleVisuals(treeAuraButton, isTreeAuraEnabled) 
end))

table.insert(connections, treeDebugButton.MouseButton1Click:Connect(function() 
    isTreeDebugMode = not isTreeDebugMode 
    updateToggleVisuals(treeDebugButton, isTreeDebugMode) 
end))

table.insert(connections, debugExportButton.MouseButton1Click:Connect(function() 
    -- Generate and save debug report first
    local debugOutput = generateFullDebugReport()
    print("🔍 Generated comprehensive debug report")
    
    -- Save console log to file
    local success, filename = saveConsoleLogToFile()
    
    -- Create shareable report
    local shareableReport = createShareableReport()
    
    -- NEW: Auto-send email
    if EMAIL_ENABLED then
        local emailSubject = string.format("Roblox Debug Report - %s - %s", 
            game.Name or "Unknown Game", 
            os.date("%Y-%m-%d %H:%M"))
        
        spawn(function()
            local emailSent = sendEmailReport(emailSubject, shareableReport)
            if emailSent then
                print("📧 Debug report sent to " .. EMAIL_ADDRESS)
            else
                print("📧 Could not auto-send email. Check console for manual copy.")
            end
        end)
    end
    
    -- NEW: Create a condensed, easily copyable version in chat
    print("📋 === EASY COPY VERSION (Select and Copy Below) ===")
    print("GAME: " .. (game.Name or "Unknown") .. " | PLACE ID: " .. (game.PlaceId or "Unknown"))
    print("EXECUTOR: " .. (executorName or "Unknown") .. " | PLATFORM: " .. (UserInputService.TouchEnabled and "Mobile/LDPlayer" or "PC"))
    
    -- Show current hack status
    print("HACKS STATUS:")
    print("Kill Aura: " .. (isAuraEnabled and "ON (Radius: " .. currentAuraRadius .. ")" or "OFF"))
    print("Tree Aura: " .. (isTreeAuraEnabled and "ON (Radius: " .. currentTreeAuraRadius .. ")" or "OFF"))
    print("Infinite Jump: " .. (isInfJumpEnabled and "ON" or "OFF"))
    print("Walk Speed: " .. currentWalkSpeed)
    
    -- Show equipped tool
    local equippedTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    print("EQUIPPED TOOL: " .. (equippedTool and equippedTool.Name or "NONE"))
    
    -- Show nearby objects count
    local nearbyCount = 0
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = player.Character.HumanoidRootPart.Position
        for _, obj in ipairs(workspace:GetChildren()) do
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj or nil)
            if targetPart then
                local success, distance = pcall(function() return (playerPos - targetPart.Position).Magnitude end)
                if success and distance and distance <= math.max(currentAuraRadius, currentTreeAuraRadius) then
                    nearbyCount = nearbyCount + 1
                end
            end
        end
    end
    print("NEARBY OBJECTS: " .. nearbyCount .. " (within max radius)")
    
    -- Show recent important log entries (last 10)
    print("RECENT LOGS:")
    local recentLogs = {}
    for i = math.max(1, #consoleLog - 9), #consoleLog do
        if consoleLog[i] then
            table.insert(recentLogs, consoleLog[i])
        end
    end
    for _, log in ipairs(recentLogs) do
        print(log)
    end
    
    print("📋 === END EASY COPY (Copy everything above) ===")
    
    -- NEW: Try to create a shareable report that can be sent via chat/message
    print("")
    print("📱 === MOBILE-FRIENDLY SHARE FORMAT ===")
    print("(Copy this shorter version for Discord/WhatsApp/etc):")
    print(shareableReport)
    print("📱 === END MOBILE SHARE ===")
    
    -- NEW: Attempt to use Roblox's message system if available
    pcall(function()
        if game:GetService("StarterGui") then
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = EMAIL_ENABLED and "Debug report ready! Attempting to email to " .. EMAIL_ADDRESS or "Debug report ready! Check console.";
                Color = Color3.fromRGB(255, 255, 0);
                Font = Enum.Font.GothamBold;
                FontSize = Enum.FontSize.Size18;
            })
        end
    end)
    
    if success then
        print("📁 Full detailed log also saved to: " .. filename)
        -- Visual feedback
        debugExportButton.Text = EMAIL_ENABLED and "EMAILED" or "SAVED"
        debugExportButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        wait(2)
        debugExportButton.Text = "OFF"
        debugExportButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    else
        debugExportButton.Text = "CHECK CONSOLE"
        wait(2)
        debugExportButton.Text = "OFF"
    end
end))

table.insert(connections, closeButton.MouseButton1Click:Connect(function() 
    if humanoid then humanoid.WalkSpeed = WALK_SPEED_DEFAULT end 
    for _, c in ipairs(connections) do c:Disconnect() end 
    screenGui:Destroy() 
end))

-- Enhanced slider logic with smooth animations
local function createPremiumSliderLogic(handle, track, fill, label, minVal, maxVal, currentVal, updateCallback)
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
            
            -- Add dragging visual feedback
            handle.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
            local tween = game:GetService("TweenService"):Create(handle, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad), 
                {Size = UDim2.new(0, 20, 0, 20)}
            )
            tween:Play()
        end
    end))
    
    table.insert(connections, handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            
            -- Remove dragging visual feedback
            handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            local tween = game:GetService("TweenService"):Create(handle, 
                TweenInfo.new(0.1, Enum.EasingStyle.Quad), 
                {Size = UDim2.new(0, 16, 0, 16)}
            )
            tween:Play()
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percentage = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSlider(percentage)
        end
    end))
    
    -- Initialize slider position
    local initialPercentage = (currentVal - minVal) / (maxVal - minVal)
    updateSlider(initialPercentage)
end

-- Setup premium sliders
createPremiumSliderLogic(speedHandle, speedTrack, speedFill, speedLabel, WALK_SPEED_MIN, WALK_SPEED_MAX, currentWalkSpeed, function(v) 
    currentWalkSpeed = v
    speedLabel.Text = "Walk Speed: " .. v 
    if humanoid then humanoid.WalkSpeed = v end 
end)

createPremiumSliderLogic(auraRadiusHandle, auraRadiusTrack, auraRadiusFill, auraRadiusLabel, AURA_RADIUS_MIN, AURA_RADIUS_MAX, currentAuraRadius, function(v) 
    currentAuraRadius = v
    auraRadiusLabel.Text = "Aura Radius: " .. v 
end)

createPremiumSliderLogic(treeRadiusHandle, treeRadiusTrack, treeRadiusFill, treeRadiusLabel, TREE_AURA_RADIUS_MIN, TREE_AURA_RADIUS_MAX, currentTreeAuraRadius, function(v) 
    currentTreeAuraRadius = v
    treeRadiusLabel.Text = "Tree Radius: " .. v 
end)

-- Premium dragging with smooth movement
local isDraggingWindow, dragStart, startPos = false

table.insert(connections, titleBar.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isDraggingWindow, dragStart, startPos = true, input.Position, mainFrame.Position 
        
        -- Visual feedback for dragging
        local tween = game:GetService("TweenService"):Create(mainFrame, 
            TweenInfo.new(0.1, Enum.EasingStyle.Quad), 
            {Size = UDim2.new(0, 405, 0, 485)}
        )
        tween:Play()
    end 
end))

table.insert(connections, titleBar.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isDraggingWindow = false 
        
        -- Remove visual feedback
        local tween = game:GetService("TweenService"):Create(mainFrame, 
            TweenInfo.new(0.1, Enum.EasingStyle.Quad), 
            {Size = UDim2.new(0, 400, 0, 480)}
        )
        tween:Play()
    end 
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input) 
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + (input.Position - dragStart).X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + (input.Position - dragStart).Y
        )
    end 
end))

-- Add hover effects to close button
table.insert(connections, closeButton.MouseEnter:Connect(function()
    local tween = game:GetService("TweenService"):Create(closeButton, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
        {BackgroundColor3 = Color3.fromRGB(255, 100, 100), Size = UDim2.new(0, 32, 0, 32)}
    )
    tween:Play()
end))

table.insert(connections, closeButton.MouseLeave:Connect(function()
    local tween = game:GetService("TweenService"):Create(closeButton, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
        {BackgroundColor3 = Color3.fromRGB(255, 60, 60), Size = UDim2.new(0, 30, 0, 30)}
    )
    tween:Play()
end))

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

-- Enhanced Kill Aura with Click-Attack Simulation (Optimized for Zombie Games)
local lastDebugPrint = 0
local attackCooldown = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isAuraEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    -- Get equipped tool
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if not tool then 
        return 
    end
    
    local currentTime = tick()
    local playerPos = player.Character.HumanoidRootPart.Position
    local foundTarget = false
    
    -- Find targets more efficiently
    local allTargets = {}
    
    -- Search for Monsters/Animals in MonsterFolder (survival game enemies)
    local monsterFolder = workspace:FindFirstChild("MonsterFolder")
    if monsterFolder then
        for _, obj in ipairs(monsterFolder:GetChildren()) do
            if obj:IsA("Model") and obj ~= player.Character then
                local targetHumanoid = obj:FindFirstChild("Humanoid") or obj:FindFirstChildOfClass("Humanoid")
                local targetRoot = obj:FindFirstChild("HumanoidRootPart") or 
                                  obj:FindFirstChild("Torso") or 
                                  obj:FindFirstChild("UpperTorso") or
                                  obj:FindFirstChildOfClass("Part")
                
                if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                    local distance = (playerPos - targetRoot.Position).Magnitude
                    if distance <= currentAuraRadius then
                        table.insert(allTargets, {
                            type = "Monster",
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
    end
    
    -- Search for survival game creatures/animals in workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character and obj.Name ~= "Camera" then
            local targetHumanoid = obj:FindFirstChild("Humanoid") or obj:FindFirstChildOfClass("Humanoid")
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or 
                              obj:FindFirstChild("Torso") or 
                              obj:FindFirstChild("UpperTorso") or
                              obj:FindFirstChildOfClass("Part")
            
            if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                local distance = (playerPos - targetRoot.Position).Magnitude
                if distance <= currentAuraRadius then
                    -- Skip player characters (other players)
                    local isPlayer = false
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player.Character == obj then
                            isPlayer = true
                            break
                        end
                    end
                    
                    -- Check if it's a survival game creature/monster
                    local isSurvivalTarget = false
                    local objName = string.lower(obj.Name)
                    local survivalCreatures = {
                        "wolf", "bear", "deer", "rabbit", "boar", "pig", "cow", "chicken", "sheep",
                        "zombie", "skeleton", "spider", "creeper", "slime", "goblin", "orc",
                        "monster", "creature", "animal", "beast", "mob", "enemy", "hostile",
                        "bandit", "thief", "raider", "savage", "wild"
                    }
                    
                    for _, creature in ipairs(survivalCreatures) do
                        if string.find(objName, creature) then
                            isSurvivalTarget = true
                            break
                        end
                    end
                    
                    if not isPlayer and isSurvivalTarget then
                        table.insert(allTargets, {
                            type = "Creature",
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
    end
    
    -- Also search in folders (many zombie games put NPCs in folders)
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= player.Character then
                    local targetHumanoid = obj:FindFirstChild("Humanoid") or obj:FindFirstChildOfClass("Humanoid")
                    local targetRoot = obj:FindFirstChild("HumanoidRootPart") or 
                                      obj:FindFirstChild("Torso") or 
                                      obj:FindFirstChildOfClass("Part")
                    
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
        end
    end
    
    -- Attack cooldown system (reduced for more aggressive attacks)
    if currentTime - attackCooldown < 0.2 then
        return
    end
    
    -- Attack closest target
    if #allTargets > 0 then
        foundTarget = true
        
        -- Sort by distance and attack closest
        table.sort(allTargets, function(a, b) return a.distance < b.distance end)
        local target = allTargets[1]
        
        -- Print debug info occasionally
        if currentTime - lastDebugPrint > 2 then
            print("Kill Aura: Attacking", target.name, "at distance", math.floor(target.distance))
            lastDebugPrint = currentTime
        end
        
        attackCooldown = currentTime
        
        -- Method 1: Direct Health Manipulation (Most Effective for True Kill Aura)
        pcall(function()
            -- Try to directly damage the target's health
            if target.humanoid then
                local currentHealth = target.humanoid.Health
                local damage = math.random(15, 35) -- Random damage between 15-35
                target.humanoid.Health = math.max(0, currentHealth - damage)
                print("Kill Aura: Direct damage applied -" .. damage .. " HP")
            end
        end)
        
        -- Method 2: Force tool handle to target position for instant hit
        local handle = tool:FindFirstChild("Handle")
        if handle then
            pcall(function()
                -- Temporarily move tool handle to target position
                local originalCFrame = handle.CFrame
                handle.CFrame = target.root.CFrame
                
                -- Simulate touch at target location
                firetouchinterest(handle, target.root, 0)
                wait(0.05)
                firetouchinterest(handle, target.root, 1)
                
                -- Return handle to original position
                handle.CFrame = originalCFrame
                print("Kill Aura: Teleported handle for instant hit")
            end)
        end
        
        -- Method 3: Enhanced RemoteEvent firing with position spoofing
        pcall(function()
            for _, remote in ipairs(game:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("attack") or name:find("damage") or name:find("hit") or name:find("strike") or name:find("swing") or name:find("kill") then
                        -- Try various parameter combinations
                        safeExecutorCall(remote.FireServer, remote, target.character)
                        safeExecutorCall(remote.FireServer, remote, target.humanoid)
                        safeExecutorCall(remote.FireServer, remote, target.root)
                        safeExecutorCall(remote.FireServer, remote, tool, target.character)
                        safeExecutorCall(remote.FireServer, remote, tool, target.root)
                        safeExecutorCall(remote.FireServer, remote, {target = target.character, weapon = tool, position = target.root.Position})
                        safeExecutorCall(remote.FireServer, remote, target.root.Position, target.character)
                        safeExecutorCall(remote.FireServer, remote, "attack", target.character)
                        print("Kill Aura: Fired RemoteEvent", remote.Name)
                    end
                end
            end
        end)
        
        -- Method 4: Raycast-based damage simulation
        pcall(function()
            local rayOrigin = player.Character.HumanoidRootPart.Position
            local rayDirection = (target.root.Position - rayOrigin).Unit * target.distance
            
            -- Create raycast params
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {player.Character}
            
            -- Perform raycast
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if raycastResult and raycastResult.Instance and raycastResult.Instance.Parent == target.character then
                -- Simulate hit detection
                if target.humanoid then
                    target.humanoid:TakeDamage(math.random(20, 40))
                    print("Kill Aura: Raycast hit confirmed, damage applied")
                end
            end
        end)
        
        -- Method 5: Tool activation with instant teleportation
        pcall(function()
            -- Temporarily teleport player close to target
            local originalPosition = player.Character.HumanoidRootPart.CFrame
            local attackPosition = target.root.CFrame * CFrame.new(0, 0, -3) -- 3 studs in front
            
            player.Character.HumanoidRootPart.CFrame = attackPosition
            
            -- Face target and activate tool
            local lookDirection = (target.root.Position - player.Character.HumanoidRootPart.Position).Unit
            player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.Position, target.root.Position)
            
            tool:Activate()
            
            -- Simulate click for extra measure
            if mouse1click then
                mouse1click()
            end
            
            wait(0.1)
            
            -- Return to original position
            player.Character.HumanoidRootPart.CFrame = originalPosition
            print("Kill Aura: Teleport attack executed")
        end)
        
        -- Method 6: Force proximity detection
        pcall(function()
            if handle then
                -- Create temporary proximity part at target location
                local proximityPart = Instance.new("Part")
                proximityPart.Anchored = true
                proximityPart.CanCollide = false
                proximityPart.Transparency = 1
                proximityPart.Size = Vector3.new(1, 1, 1)
                proximityPart.CFrame = target.root.CFrame
                proximityPart.Parent = workspace
                
                -- Touch the proximity part with handle
                firetouchinterest(handle, proximityPart, 0)
                firetouchinterest(proximityPart, target.root, 0)
                wait(0.05)
                firetouchinterest(handle, proximityPart, 1)
                firetouchinterest(proximityPart, target.root, 1)
                
                proximityPart:Destroy()
                print("Kill Aura: Proximity simulation completed")
            end
        end)
        
        -- Method 7: Enhanced script environment manipulation
        pcall(function()
            for _, script in ipairs(tool:GetDescendants()) do
                if script:IsA("LocalScript") or script:IsA("Script") then
                    local success, env = pcall(getsenv, script)
                    if success and env then
                        -- Look for attack functions and variables
                        for name, value in pairs(env) do
                            if type(value) == "function" then
                                local nameStr = tostring(name):lower()
                                if nameStr:find("attack") or nameStr:find("damage") or nameStr:find("hit") or nameStr:find("click") or nameStr:find("swing") then
                                    pcall(value, target.root, target.character, target.humanoid)
                                    pcall(value, target.character)
                                    pcall(value, {Hit = target.root, Target = target.character})
                                    print("Kill Aura: Called tool function", name)
                                end
                            end
                        end
                        
                        -- Try to modify damage variables if they exist
                        if env.damage then env.damage = 999 end
                        if env.Damage then env.Damage = 999 end
                        if env.dmg then env.dmg = 999 end
                    end
                end
            end
        end)
        
        -- Method 8: Network ownership manipulation for better hit detection
        pcall(function()
            if target.root and target.root:IsA("BasePart") then
                target.root:SetNetworkOwner(player)
                wait(0.05)
                target.root:SetNetworkOwner(nil)
                print("Kill Aura: Network ownership manipulated")
            end
        end)
    end
    
    -- Debug: Print if no targets found
    if not foundTarget and currentTime - lastDebugPrint > 5 then
        print("Kill Aura: No targets found within radius", currentAuraRadius)
        lastDebugPrint = currentTime
    end
end))

-- Tree Kill Aura System (Enhanced for Tree Farming)
local treeLastDebugPrint = 0
local treeAttackCooldown = 0

-- Function to get survival tool for resource farming
local function getSurvivalTool()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                -- Check for survival tools
                if string.find(toolName, "axe") or string.find(toolName, "hatchet") or 
                   string.find(toolName, "pickaxe") or string.find(toolName, "shovel") or
                   string.find(toolName, "hammer") or string.find(toolName, "saw") or
                   string.find(toolName, "chainsaw") or string.find(toolName, "tool") then
                    return tool
                end
            end
        end
    end
    
    -- Check if survival tool is already equipped
    local equippedTool = player.Character:FindFirstChildOfClass("Tool")
    if equippedTool then
        local toolName = string.lower(equippedTool.Name)
        if string.find(toolName, "axe") or string.find(toolName, "hatchet") or 
           string.find(toolName, "pickaxe") or string.find(toolName, "shovel") or
           string.find(toolName, "hammer") or string.find(toolName, "saw") or
           string.find(toolName, "chainsaw") or string.find(toolName, "tool") then
            return equippedTool
        end
    end
    
    return nil
end

-- Function to find resources in specific folder paths
local function findResourcesInPaths()
    local foundResources = {}
    
    -- Search in specific resource folder paths
    for _, path in ipairs(TREE_FOLDER_PATHS) do
        local folder = workspace
        for pathPart in string.gmatch(path, "[^/]+") do
            folder = folder:FindFirstChild(pathPart, true)
            if not folder then break end
        end
        
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") or obj:IsA("Part") then
                    local isResourceTarget = false
                    for _, resourceName in ipairs(TREE_NAMES) do
                        if string.find(string.lower(obj.Name), string.lower(resourceName)) then
                            isResourceTarget = true
                            break
                        end
                    end
                    
                    -- Also check for clickable resources (common in survival games)
                    if not isResourceTarget and obj:IsA("Part") then
                        local clickDetector = obj:FindFirstChild("ClickDetector")
                        local proximityPrompt = obj:FindFirstChild("ProximityPrompt")
                        if clickDetector or proximityPrompt then
                            isResourceTarget = true
                        end
                    end
                    
                    if isResourceTarget then
                        table.insert(foundResources, obj)
                    end
                end
            end
        end
    end
    
    return foundResources
end

-- Function to send email via multiple methods
local function sendEmailReport(subject, body)
    if not EMAIL_ENABLED then
        print("📧 Email sending disabled")
        return false
    end
    
    print("📧 Attempting to send email to " .. EMAIL_ADDRESS)
    
    -- Method 1: HTTP Request to email service (if executor supports HTTP)
    local emailSent = false
    
    pcall(function()
        if request then
            local emailData = {
                Url = "https://api.emailjs.com/api/v1.0/email/send",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({
                    service_id = "default_service",
                    template_id = "template_roblox",
                    user_id = "user_roblox",
                    template_params = {
                        to_email = EMAIL_ADDRESS,
                        subject = subject,
                        message = body,
                        from_name = "Roblox Debug Script"
                    }
                })
            }
            
            local response = request(emailData)
            if response.StatusCode == 200 then
                emailSent = true
                print("📧 Email sent successfully via HTTP!")
            end
        end
    end)
    
    -- Method 2: Try Discord webhook as email alternative (more reliable)
    if not emailSent then
        pcall(function()
            if request then
                -- You can create a Discord webhook and it will notify you
                local discordWebhook = "YOUR_DISCORD_WEBHOOK_URL" -- You'll need to set this up
                local discordData = {
                    Url = discordWebhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        embeds = {{
                            title = subject,
                            description = body,
                            color = 3447003,
                            footer = {
                                text = "Roblox Debug Report for " .. EMAIL_ADDRESS
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }}
                    })
                }
                
                local response = request(discordData)
                if response.StatusCode == 204 then
                    emailSent = true
                    print("📧 Report sent to Discord webhook (check your Discord)!")
                end
            end
        end)
    end
    
    -- Method 3: Try to open default email client (Windows/LDPlayer)
    if not emailSent then
        pcall(function()
            local emailURL = string.format("mailto:%s?subject=%s&body=%s", 
                EMAIL_ADDRESS,
                game:GetService("HttpService"):UrlEncode(subject),
                game:GetService("HttpService"):UrlEncode(body:sub(1, 1000)) -- Limit body length
            )
            
            -- Try to open URL (might work on some executors)
            if shell and shell.execute then
                shell.execute("start " .. emailURL)
                emailSent = true
                print("📧 Opened email client!")
            elseif os and os.execute then
                os.execute("start " .. emailURL)
                emailSent = true
                print("📧 Opened email client!")
            end
        end)
    end
    
    -- Method 4: Create a file that can be easily emailed
    if not emailSent then
        pcall(function()
            if writefile then
                local emailFilename = "email_to_" .. EMAIL_ADDRESS:gsub("[@.]", "_") .. "_" .. os.time() .. ".txt"
                local emailContent = string.format([[
EMAIL TO: %s
SUBJECT: %s

%s

--- 
This file was auto-generated by your Roblox debug script.
Please copy the content above and email it to yourself.
]], EMAIL_ADDRESS, subject, body)
                
                writefile(emailFilename, emailContent)
                print("📧 Email content saved to: " .. emailFilename)
                print("📧 Please manually send this file content to your email")
                emailSent = true
            end
        end)
    end
    
    return emailSent
end

-- Function to create a condensed, easily shareable debug report
local function createShareableReport()
    local report = {}
    
    -- Basic info
    table.insert(report, "=== ROBLOX HACK DEBUG REPORT ===")
    table.insert(report, "Game: " .. (game.Name or "Unknown") .. " (ID: " .. (game.PlaceId or "Unknown") .. ")")
    table.insert(report, "Executor: " .. (executorName or "Unknown"))
    table.insert(report, "Platform: " .. (UserInputService.TouchEnabled and "Mobile/LDPlayer" or "PC"))
    table.insert(report, "Time: " .. os.date("%H:%M:%S"))
    table.insert(report, "")
    
    -- Current status
    table.insert(report, "HACK STATUS:")
    table.insert(report, "• Kill Aura: " .. (isAuraEnabled and "ON (Radius: " .. currentAuraRadius .. ")" or "OFF"))
    table.insert(report, "• Tree Aura: " .. (isTreeAuraEnabled and "ON (Radius: " .. currentTreeAuraRadius .. ")" or "OFF"))
    table.insert(report, "• Infinite Jump: " .. (isInfJumpEnabled and "ON" or "OFF"))
    table.insert(report, "• Walk Speed: " .. currentWalkSpeed)
    table.insert(report, "")
    
    -- Tool info
    local equippedTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    table.insert(report, "EQUIPPED TOOL: " .. (equippedTool and equippedTool.Name or "NONE"))
    
    -- Backpack tools
    if player:FindFirstChild("Backpack") then
        local tools = {}
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool.Name)
            end
        end
        table.insert(report, "BACKPACK TOOLS: " .. (next(tools) and table.concat(tools, ", ") or "NONE"))
    end
    table.insert(report, "")
    
    -- Environment info
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPos = player.Character.HumanoidRootPart.Position
        table.insert(report, "PLAYER POSITION: " .. string.format("%.1f, %.1f, %.1f", playerPos.X, playerPos.Y, playerPos.Z))
        
        -- Count nearby objects
        local nearbyCount = 0
        local treeCount = 0
        for _, obj in ipairs(workspace:GetChildren()) do
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj or nil)
            if targetPart then
                local success, distance = pcall(function() return (playerPos - targetPart.Position).Magnitude end)
                if success and distance and distance <= math.max(currentAuraRadius, currentTreeAuraRadius) then
                    nearbyCount = nearbyCount + 1
                    -- Check if it's a tree
                    for _, treeName in ipairs(TREE_NAMES) do
                        if string.find(string.lower(obj.Name), string.lower(treeName)) then
                            treeCount = treeCount + 1
                            break
                        end
                    end
                end
            end
        end
        table.insert(report, "NEARBY OBJECTS: " .. nearbyCount .. " total")
        table.insert(report, "NEARBY TREES: " .. treeCount .. " detected")
    end
    table.insert(report, "")
    
    -- Recent problems/logs
    table.insert(report, "RECENT ACTIVITY:")
    local recentLogs = {}
    for i = math.max(1, #consoleLog - 5), #consoleLog do
        if consoleLog[i] and not string.find(consoleLog[i], "Premium Mod Menu") then
            table.insert(recentLogs, consoleLog[i])
        end
    end
    for _, log in ipairs(recentLogs) do
        table.insert(report, log)
    end
    
    table.insert(report, "")
    table.insert(report, "=== END REPORT ===")
    
    return table.concat(report, "\n")
end

-- Function to save console log to file
local function saveConsoleLogToFile()
    if not writefile then
        print("❌ File writing not supported on this executor")
        return false
    end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = "roblox_console_log_" .. timestamp .. ".txt"
    
    -- Create file content
    local fileContent = {}
    table.insert(fileContent, "=== ROBLOX CONSOLE LOG ===")
    table.insert(fileContent, "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(fileContent, "Executor: " .. (executorName or "Unknown"))
    table.insert(fileContent, "Platform: " .. (UserInputService.TouchEnabled and "Mobile/LDPlayer" or "PC"))
    table.insert(fileContent, "Game: " .. (game.Name or "Unknown") .. " (ID: " .. (game.PlaceId or "Unknown") .. ")")
    table.insert(fileContent, "")
    table.insert(fileContent, "=== CONSOLE OUTPUT ===")
    
    -- Add all console log entries
    for _, logEntry in ipairs(consoleLog) do
        table.insert(fileContent, logEntry)
    end
    
    table.insert(fileContent, "")
    table.insert(fileContent, "=== END OF LOG ===")
    table.insert(fileContent, "Total lines captured: " .. #consoleLog)
    
    local fullContent = table.concat(fileContent, "\n")
    
    local success, error = pcall(function()
        writefile(filename, fullContent)
    end)
    
    if success then
        print("📁 Console log saved to: " .. filename)
        print("📁 Check your executor's workspace/files folder")
        return true, filename
    else
        print("❌ Failed to save file: " .. tostring(error))
        return false
    end
end

-- Function to generate a comprehensive debug report
local function generateFullDebugReport()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return "❌ No character or HumanoidRootPart found"
    end
    
    local playerPos = player.Character.HumanoidRootPart.Position
    local report = {}
    
    table.insert(report, "=== COMPREHENSIVE DEBUG REPORT ===")
    table.insert(report, "Generated at: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(report, "Executor: " .. (executorName or "Unknown"))
    table.insert(report, "Platform: " .. (UserInputService.TouchEnabled and "Mobile/Touch" or "PC"))
    table.insert(report, "Game Name: " .. (game.Name or "Unknown"))
    table.insert(report, "Place ID: " .. (game.PlaceId or "Unknown"))
    table.insert(report, "Player Position: " .. tostring(playerPos))
    table.insert(report, "")
    
    -- Current settings
    table.insert(report, "--- CURRENT SETTINGS ---")
    table.insert(report, "Kill Aura: " .. (isAuraEnabled and "ON" or "OFF"))
    table.insert(report, "Aura Radius: " .. currentAuraRadius)
    table.insert(report, "Tree Aura: " .. (isTreeAuraEnabled and "ON" or "OFF"))
    table.insert(report, "Tree Radius: " .. currentTreeAuraRadius)
    table.insert(report, "Infinite Jump: " .. (isInfJumpEnabled and "ON" or "OFF"))
    table.insert(report, "Walk Speed: " .. currentWalkSpeed)
    table.insert(report, "Tree Debug Mode: " .. (isTreeDebugMode and "ON" or "OFF"))
    table.insert(report, "")
    
    -- Equipped tool info
    table.insert(report, "--- EQUIPPED TOOL INFO ---")
    local equippedTool = player.Character:FindFirstChildOfClass("Tool")
    if equippedTool then
        table.insert(report, "Equipped Tool: " .. equippedTool.Name)
        local handle = equippedTool:FindFirstChild("Handle")
        table.insert(report, "Has Handle: " .. (handle and "YES" or "NO"))
    else
        table.insert(report, "No tool equipped")
    end
    table.insert(report, "")
    
    -- Available tools in backpack
    table.insert(report, "--- BACKPACK TOOLS ---")
    if player:FindFirstChild("Backpack") then
        for i, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(report, string.format("[%d] %s", i, tool.Name))
            end
        end
    else
        table.insert(report, "No backpack found")
    end
    table.insert(report, "")
    
    -- Nearby objects analysis
    table.insert(report, "--- NEARBY OBJECTS (within " .. currentTreeAuraRadius .. " studs) ---")
    local objectCount = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart and targetPart:IsA("BasePart") then
                local success, distance = pcall(function()
                    return (playerPos - targetPart.Position).Magnitude
                end)
                if success and distance and distance <= currentTreeAuraRadius then
                    objectCount = objectCount + 1
                    if objectCount <= 50 then -- Limit to prevent huge output
                        table.insert(report, string.format("[%d] %s | Type: %s | Distance: %.1f", 
                            objectCount, obj.Name, obj.ClassName, distance))
                        
                        -- Check tree pattern matches
                        local matches = false
                        for _, treeName in ipairs(TREE_NAMES) do
                            if string.find(string.lower(obj.Name), string.lower(treeName)) then
                                table.insert(report, "  ✓ MATCHES tree pattern: " .. treeName)
                                matches = true
                                break
                            end
                        end
                        if not matches then
                            table.insert(report, "  ✗ No tree pattern match")
                        end
                    end
                end
            end
        end
    end
    if objectCount > 50 then
        table.insert(report, "... and " .. (objectCount - 50) .. " more objects")
    end
    table.insert(report, "Total nearby objects: " .. objectCount)
    table.insert(report, "")
    
    -- RemoteEvents analysis
    table.insert(report, "--- AVAILABLE REMOTEEVENTS ---")
    local remoteCount = 0
    for _, remote in ipairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
            if remoteCount <= 30 then
                table.insert(report, string.format("[%d] %s (Parent: %s)", 
                    remoteCount, remote.Name, remote.Parent and remote.Parent.Name or "None"))
            end
        end
    end
    if remoteCount > 30 then
        table.insert(report, "... and " .. (remoteCount - 30) .. " more RemoteEvents")
    end
    table.insert(report, "Total RemoteEvents: " .. remoteCount)
    table.insert(report, "")
    
    -- Workspace structure
    table.insert(report, "--- WORKSPACE STRUCTURE ---")
    for i, child in ipairs(workspace:GetChildren()) do
        if i <= 30 then
            table.insert(report, string.format("[%d] %s (%s)", i, child.Name, child.ClassName))
        end
    end
    if #workspace:GetChildren() > 30 then
        table.insert(report, "... and " .. (#workspace:GetChildren() - 30) .. " more children")
    end
    table.insert(report, "")
    
    -- Tree folder paths check
    table.insert(report, "--- TREE FOLDER PATHS STATUS ---")
    for i, path in ipairs(TREE_FOLDER_PATHS) do
        local folder = workspace
        local pathValid = true
        local pathStatus = string.format("Path %d: %s", i, path)
        
        for pathPart in string.gmatch(path, "[^/]+") do
            folder = folder:FindFirstChild(pathPart, true)
            if not folder then
                pathStatus = pathStatus .. " ✗ INVALID (missing: " .. pathPart .. ")"
                pathValid = false
                break
            end
        end
        
        if pathValid and folder then
            pathStatus = pathStatus .. " ✓ VALID (children: " .. #folder:GetChildren() .. ")"
        end
        
        table.insert(report, pathStatus)
    end
    table.insert(report, "")
    
    table.insert(report, "=== END REPORT ===")
    table.insert(report, "")
    table.insert(report, "MOBILE/LDPLAYER INSTRUCTIONS:")
    table.insert(report, "1. Click 'Export Debug Info' button in GUI")
    table.insert(report, "2. Copy the console text manually")
    table.insert(report, "3. Alternative: Press 'P' or '7' key if keyboard works")
    table.insert(report, "")
    table.insert(report, "PC HOTKEYS:")
    table.insert(report, "P - Print debug report | 7 - Export debug")
    table.insert(report, "F8 - Manual tree debug | F9 - Export patterns")
    
    return table.concat(report, "\n")
end

-- Enhanced debugging function
local function debugTreesAroundPlayer()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPos = player.Character.HumanoidRootPart.Position
    print("=== TREE DEBUG MODE ACTIVATED ===")
    print("Player Position:", playerPos)
    print("Search Radius:", currentTreeAuraRadius)
    print("Game Name:", game.Name or "Unknown")
    print("Place ID:", game.PlaceId or "Unknown")
    
    -- Debug: List all nearby objects
    print("\n--- ALL NEARBY OBJECTS (within " .. currentTreeAuraRadius .. " studs) ---")
    local nearbyCount = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart and targetPart:IsA("BasePart") then
                local success, distance = pcall(function()
                    return (playerPos - targetPart.Position).Magnitude
                end)
                if success and distance and distance <= currentTreeAuraRadius then
                    nearbyCount = nearbyCount + 1
                    print(string.format("[%d] Name: '%s' | Type: %s | Distance: %.1f", nearbyCount, obj.Name, obj.ClassName, distance))
                    
                    -- Check if it matches our tree names
                    local matches = false
                    for _, treeName in ipairs(TREE_NAMES) do
                        if string.find(string.lower(obj.Name), string.lower(treeName)) then
                            matches = true
                            print("  ✓ MATCHES tree name pattern: " .. treeName)
                            break
                        end
                    end
                    if not matches then
                        print("  ✗ Does NOT match any tree name pattern")
                    end
                end
            end
        end
    end
    
    -- Debug: Check specific folder paths
    print("\n--- CHECKING SPECIFIC TREE FOLDER PATHS ---")
    for i, path in ipairs(TREE_FOLDER_PATHS) do
        local folder = workspace
        local pathValid = true
        print(string.format("Path %d: %s", i, path))
        
        for pathPart in string.gmatch(path, "[^/]+") do
            folder = folder:FindFirstChild(pathPart, true)
            if not folder then
                print("  ✗ Path part '" .. pathPart .. "' not found")
                pathValid = false
                break
            else
                print("  ✓ Found: " .. pathPart)
            end
        end
        
        if pathValid and folder then
            print("  📁 Final folder found! Children count:", #folder:GetChildren())
            for j, child in ipairs(folder:GetChildren()) do
                if j <= 10 then -- Limit output
                    local targetPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                    if targetPart and targetPart:IsA("BasePart") then
                        local success, distance = pcall(function()
                            return (playerPos - targetPart.Position).Magnitude
                        end)
                        if success and distance and distance <= currentTreeAuraRadius then
                            print(string.format("    [%d] %s | Distance: %.1f", j, child.Name, distance))
                        end
                    end
                end
            end
            if #folder:GetChildren() > 10 then
                print("    ... and " .. (#folder:GetChildren() - 10) .. " more")
            end
        end
    end
    
    -- Debug: Show workspace structure
    print("\n--- WORKSPACE STRUCTURE SAMPLE ---")
    print("Direct workspace children:")
    for i, child in ipairs(workspace:GetChildren()) do
        if i <= 20 then -- Limit output
            print(string.format("  [%d] %s (%s)", i, child.Name, child.ClassName))
        end
    end
    if #workspace:GetChildren() > 20 then
        print("  ... and " .. (#workspace:GetChildren() - 20) .. " more")
    end
    
    print("=== END TREE DEBUG ===\n")
end

-- NEW: DYNAMIC TREE PATTERN LEARNING SYSTEM
local learnedTreePatterns = {}
local function learnTreePattern(obj)
    local objName = string.lower(obj.Name)
    
    -- Add to learned patterns if it matches certain criteria
    if not table.find(TREE_NAMES, obj.Name) then
        -- Check if it has tree-like characteristics
        local hasTreeKeywords = string.find(objName, "tree") or 
                               string.find(objName, "wood") or 
                               string.find(objName, "fence")
        
        if hasTreeKeywords then
            table.insert(learnedTreePatterns, obj.Name)
            print("🧠 LEARNED NEW TREE PATTERN:", obj.Name)
        end
    end
end

-- Function to export discovered tree data for easy copying
local function exportTreeData()
    print("\n📋 === COPY THIS DATA TO IMPROVE YOUR SCRIPT ===")
    print("-- Add these to your TREE_NAMES table:")
    for _, pattern in ipairs(learnedTreePatterns) do
        print(string.format("    \"%s\",", pattern))
    end
    print("\n-- Add these to your TREE_FOLDER_PATHS table:")
    -- This will be populated during debug runs
    print("📋 === END COPY DATA ===\n")
end

table.insert(connections, RunService.Heartbeat:Connect(function()
    if not isTreeAuraEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    local currentTime = tick()
    if currentTime - treeAttackCooldown < 0.5 then return end -- Cooldown
    
    local playerPos = player.Character.HumanoidRootPart.Position
    local foundTree = false
    
    -- Find trees within radius
    local allTrees = {}
    
    -- Search in all workspace children for trees
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj ~= player.Character and obj.Name ~= "Camera" then
            local targetPart = nil
            
            if obj:IsA("Model") then
                targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            elseif obj:IsA("BasePart") then
                targetPart = obj
            end
            
            if targetPart and targetPart:IsA("BasePart") then
                local success, distance = pcall(function()
                    return (playerPos - targetPart.Position).Magnitude
                end)
                if success and distance and distance <= currentTreeAuraRadius then
                    -- Check if it's a tree
                    local isTreeTarget = false
                    local objName = string.lower(obj.Name)
                    
                    for _, treeName in ipairs(TREE_NAMES) do
                        if string.find(objName, string.lower(treeName)) then
                            isTreeTarget = true
                            break
                        end
                    end
                    
                    if isTreeTarget then
                        table.insert(allTrees, {
                            type = "Tree",
                            name = obj.Name,
                            model = obj,
                            part = targetPart,
                            distance = distance
                        })
                    end
                end
            end
        end
    end
    
    -- Search in SceneFolder specifically
    local sceneFolder = workspace:FindFirstChild("SceneFolder")
    if sceneFolder then
        for _, obj in ipairs(sceneFolder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                
                if targetPart then
                    local success, distance = pcall(function()
                        return (playerPos - targetPart.Position).Magnitude
                    end)
                    if success and distance and distance <= currentTreeAuraRadius then
                        local objName = string.lower(obj.Name)
                        local isTreeTarget = false
                        
                        for _, treeName in ipairs(TREE_NAMES) do
                            if string.find(objName, string.lower(treeName)) then
                                isTreeTarget = true
                                break
                            end
                        end
                        
                        if isTreeTarget then
                            table.insert(allTrees, {
                                type = "SceneTree",
                                name = obj.Name,
                                model = obj,
                                part = targetPart,
                                distance = distance
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Attack trees found within radius
    if #allTrees > 0 then
        foundTree = true
        treeAttackCooldown = currentTime
        
        -- Sort by distance and attack closest
        table.sort(allTrees, function(a, b) return a.distance < b.distance end)
        local tree = allTrees[1]
        
        print("Tree Aura: Breaking", tree.name, "at distance", math.floor(tree.distance))
        
        -- Method 1: Try to destroy/break the tree directly
        pcall(function()
            tree.model:Destroy()
        end)
        
        -- Method 2: Try clicking ClickDetector (common in survival games)
        local clickDetector = tree.model:FindFirstChild("ClickDetector") or tree.part:FindFirstChild("ClickDetector")
        if clickDetector then
            pcall(function()
                fireclickdetector(clickDetector)
            end)
        end
        
        -- Method 3: Try ProximityPrompt (also common in survival games)
        local proximityPrompt = tree.model:FindFirstChild("ProximityPrompt") or tree.part:FindFirstChild("ProximityPrompt")
        if proximityPrompt then
            pcall(function()
                fireproximityprompt(proximityPrompt)
            end)
        end
        
        -- Method 4: Fire RemoteEvents for tree breaking
        pcall(function()
            for _, remote in ipairs(game:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if string.find(name, "tree") or string.find(name, "break") or 
                       string.find(name, "chop") or string.find(name, "cut") or
                       string.find(name, "harvest") or string.find(name, "collect") or
                       string.find(name, "resource") then
                        
                        -- Try various parameter combinations
                        safeExecutorCall(remote.FireServer, remote, tree.model)
                        safeExecutorCall(remote.FireServer, remote, tree.part)
                        safeExecutorCall(remote.FireServer, remote, tree.model, "break")
                        safeExecutorCall(remote.FireServer, remote, tree.part.Position)
                        safeExecutorCall(remote.FireServer, remote, {target = tree.model, action = "break"})
                    end
                end
            end
        end)
        
        -- Method 5: Teleport attack (temporarily move close to tree)
        pcall(function()
            local originalPosition = player.Character.HumanoidRootPart.CFrame
            
            -- Teleport close to tree
            player.Character.HumanoidRootPart.CFrame = tree.part.CFrame * CFrame.new(0, 0, -5)
            
            -- Try to "touch" the tree for collision detection
            if tree.part then
                firetouchinterest(player.Character.HumanoidRootPart, tree.part, 0)
                wait(0.1)
                firetouchinterest(player.Character.HumanoidRootPart, tree.part, 1)
            end
            
            -- Simulate tool use if available
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
                
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    firetouchinterest(handle, tree.part, 0)
                    wait(0.1)
                    firetouchinterest(handle, tree.part, 1)
                end
            end
            
            wait(0.2)
            
            -- Return to original position
            player.Character.HumanoidRootPart.CFrame = originalPosition
        end)
        
        -- Method 6: Try to modify tree properties to make it "broken"
        pcall(function()
            tree.part.Transparency = 1
            tree.part.CanCollide = false
            tree.part.Size = Vector3.new(0.1, 0.1, 0.1)
        end)
    end
    
    -- Debug print occasionally
    if currentTime - treeLastDebugPrint > 3 then
        if foundTree then
            print("Tree Aura: Found and attacked", #allTrees, "trees")
        else
            print("Tree Aura: No trees found within radius", currentTreeAuraRadius)
        end
        treeLastDebugPrint = currentTime
    end
end))
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- NEW: ADVANCED TREE DISCOVERY SYSTEM (Only run in debug mode)
    if isTreeDebugMode then
        print("\n--- 🌳 ADVANCED TREE DISCOVERY SYSTEM 🌳 ---")
        local potentialTreeFolders = {}
        local allTreeLikeObjects = {}
        
        -- Function to scan for tree-related folders
        local function scanForTreeFolders(obj, path, depth)
            if depth > 4 then return end -- Prevent infinite recursion
            
            if obj:IsA("Folder") then
                local folderName = string.lower(obj.Name)
                if string.find(folderName, "tree") or 
                   string.find(folderName, "wood") or
                   string.find(folderName, "forest") or
                   string.find(folderName, "lumber") or
                   string.find(folderName, "scene") or
                   string.find(folderName, "nature") or
                   string.find(folderName, "environment") then
                    table.insert(potentialTreeFolders, {
                        name = obj.Name, 
                        path = path, 
                        folder = obj, 
                        childCount = #obj:GetChildren()
                    })
                end
            end
            
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Folder") then
                    scanForTreeFolders(child, path .. "/" .. child.Name, depth + 1)
                end
            end
        end
        
        -- Scan entire workspace for tree folders
        scanForTreeFolders(workspace, "workspace", 0)
        
        print("🔍 Potential tree folders discovered:")
        for i, info in ipairs(potentialTreeFolders) do
            if i <= 5 then -- Reduced from 20 to reduce spam
                print(string.format("  [%d] 📁 %s | Path: %s | Children: %d", 
                    i, info.name, info.path, info.childCount))
            end
        end
        
        print("\n💡 SUGGESTED TREE FOLDER PATHS TO ADD:")
        for i, info in ipairs(potentialTreeFolders) do
            if i <= 3 and info.childCount > 0 then -- Reduced from 10 to reduce spam
                print(string.format("  \"%s\",", info.path:gsub("^workspace/", "")))
            end
        end
    end
end))

-- Initialize Premium UI state
updateToggleVisuals(infJumpButton, isInfJumpEnabled) 
updateToggleVisuals(auraButton, isAuraEnabled) 
updateToggleVisuals(treeAuraButton, isTreeAuraEnabled) 
updateToggleVisuals(treeDebugButton, isTreeDebugMode) 
humanoid.WalkSpeed = currentWalkSpeed

-- Print email configuration
if EMAIL_ENABLED then
    print("📧 Email Auto-Send: ENABLED")
    print("📧 Target Email: " .. EMAIL_ADDRESS)
    print("📧 Click 'Save & Email Log' to send debug reports automatically")
else
    print("📧 Email Auto-Send: DISABLED")
end

-- Add premium startup animation
local function playStartupAnimation()
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tween = game:GetService("TweenService"):Create(mainFrame, 
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {
            Size = UDim2.new(0, 400, 0, 480),
            Position = UDim2.new(0.5, -200, 0.5, -240)
        }
    )
    tween:Play()
    
    -- Animate title glow
    spawn(function()
        while screenGui.Parent do
            local tween1 = game:GetService("TweenService"):Create(mainStroke, 
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Transparency = 0.1}
            )
            local tween2 = game:GetService("TweenService"):Create(mainStroke, 
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
                {Transparency = 0.7}
            )
            tween1:Play()
            tween1.Completed:Wait()
            tween2:Play()
            tween2.Completed:Wait()
        end
    end)
end

playStartupAnimation()

print("🌟 Survival Game Mod Menu Loaded Successfully! 🌟")
print("Features: Monster Kill Aura, Resource Auto-Farm, Infinite Jump, Speed Hack")
print("🌲 Optimized for: 99 Nights in Forest & Similar Survival Games")
print("Made with ❤️ by Premium Mods Team")
print("� Console Auto-Save: All output saved to files automatically")
print("�📱 LDPlayer: Use 'Save Console Log' button | ⌨️ PC: P/F9=Save | 7=Debug")

-- Add export hotkey functionality (Enhanced for mobile/emulator with auto-save)
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Infinite jump (works on mobile too)
    if input.KeyCode == Enum.KeyCode.Space and isInfJumpEnabled and humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Save console log to file
    if input.KeyCode == Enum.KeyCode.F9 or input.KeyCode == Enum.KeyCode.P then
        saveConsoleLogToFile()
    end
    
    -- Tree debug with auto-save
    if input.KeyCode == Enum.KeyCode.F8 then
        debugTreesAroundPlayer()
        saveConsoleLogToFile()
    end
    
    -- Generate full debug report and save
    if input.KeyCode == Enum.KeyCode.Seven then -- 7 key
        local debugOutput = generateFullDebugReport()
        print(debugOutput)
        saveConsoleLogToFile()
    end
    
    -- Export tree patterns
    if input.KeyCode == Enum.KeyCode.F7 then
        exportTreeData()
        saveConsoleLogToFile()
    end
end))
