--[[
    Admin Tool for Delta Executor
    Fixed infinite jump and kill aura functionality
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Reassign on respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentWalkSpeed
end)

-- Configuration
local AURA_RADIUS_MIN = 10
local AURA_RADIUS_MAX = 200
local AURA_RADIUS_DEFAULT = 50
local WALK_SPEED_MIN = 16
local WALK_SPEED_MAX = 100
local WALK_SPEED_DEFAULT = 16
local TOOL_NAME_TO_CHECK = "ClassicSword"

-- State Variables
local isInfJumpEnabled = false
local isAuraEnabled = false
local currentAuraRadius = AURA_RADIUS_DEFAULT
local currentWalkSpeed = WALK_SPEED_DEFAULT

-- GUI Creation (same as before)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminToolGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ... [GUI creation code remains the same] ...

-- FIXED INFINITE JUMP
local function handleInfiniteJump()
    if isInfJumpEnabled then
        -- More reliable method for executors
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- FIXED KILL AURA
local function handleKillAura()
    if not isAuraEnabled then return end
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return end
    
    -- More flexible tool checking
    local tool = playerChar:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Try to find damage event with various possible names
    local damageEvent = tool:FindFirstChild("DamageEvent") or 
                       tool:FindFirstChild("HitEvent") or 
                       tool:FindFirstChild("AttackEvent")
    
    if not damageEvent then 
        warn("No damage event found in tool: " .. tool.Name)
        return 
    end

    local playerPos = playerChar.HumanoidRootPart.Position
    local hitCount = 0

    -- Check both players and NPCs
    for _, target in pairs(workspace:GetChildren()) do
        if target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
            if target:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.HumanoidRootPart.Position
                local distance = (playerPos - targetPos).Magnitude
                
                if distance <= currentAuraRadius then
                    -- Try different parameter formats
                    pcall(function()
                        damageEvent:FireServer(target.Humanoid)
                    end)
                    pcall(function()
                        damageEvent:FireServer(target)
                    end)
                    pcall(function()
                        damageEvent:FireServer(target.Humanoid, playerPos)
                    end)
                    hitCount += 1
                end
            end
        end
    end
end

-- Connect to heartbeat for both functions
RunService.Heartbeat:Connect(function()
    handleInfiniteJump()
    handleKillAura()
end)

-- Initialize
humanoid.WalkSpeed = currentWalkSpeed
