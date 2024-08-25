-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "A7A Hub",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "Welcome to A7A Hub"
})

-- Create tabs
local aimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
})

local espTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
})

local movementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
})

-- Global settings for toggles
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().NoClipEnabled = false
getgenv().BhopEnabled = false
getgenv().CFrameWalkSpeed = 0.1
getgenv().Smoothness = 0.6
getgenv().AutoFarmEnabled = false
getgenv().AimbotYOffset = 1.3 -- Default Y-axis offset for aiming
getgenv().AimbotKeybind = Enum.KeyCode.F -- Default keybind for toggling aimbot
getgenv().MaxESPDistance = 500 -- Initial range for ESP
getgenv().MaxAimbotDistance = 500 -- Initial range for Aimbot
getgenv().FOVRadius = 100 -- Default FOV radius for aimbot

-- Services
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Track active highlights and targets
local activeHighlights = {}
local activeTargets = {}

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.NumSides = 64
fovCircle.Radius = getgenv().FOVRadius
fovCircle.Visible = true
fovCircle.Filled = false
fovCircle.Transparency = 1

-- Function to update FOV Circle position
local function updateFOVCircle()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
end

-- Function to highlight enemy characters within a specified range
local function highlightEnemy(player)
    if player.Character and not player.Character:FindFirstChild("Totally_NOT_Esp") then
        local maxHighlightDistance = getgenv().MaxESPDistance

        -- Calculate distance from local player's character to enemy
        local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
        
        -- Check if enemy is within range
        if distance <= maxHighlightDistance then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Totally_NOT_Esp"
            highlight.Adornee = player.Character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.5
            highlight.Parent = player.Character
            activeHighlights[player.UserId] = highlight
        end
    end
end

-- Function to remove highlight from player
local function removeHighlight(player)
    local highlight = activeHighlights[player.UserId]
    if highlight then
        highlight:Destroy()
        activeHighlights[player.UserId] = nil
    end
end

-- Function to enable ESP for all players
local function updateESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            if getgenv().ESPEnabled then
                highlightEnemy(player)
            else
                removeHighlight(player)
            end
        end
    end
end

-- Connect to PlayerAdded to apply ESP to new players
players.PlayerAdded:Connect(function(player)
    if getgenv().ESPEnabled then
        player.CharacterAdded:Connect(function()
            highlightEnemy(player)
        end)
    end
end)

-- Update ESP every frame
runService.RenderStepped:Connect(function()
    if getgenv().ESPEnabled then
        updateESP()
    end
    updateFOVCircle() -- Update FOV circle position every frame
end)

-- Function to find the nearest enemy within a specified range
local function findClosestEnemy()
    local maxAimbotDistance = getgenv().MaxAimbotDistance
    local closestDistance = math.huge
    local target = nil
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Calculate distance from local player's character to enemy
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            
            -- Check if enemy is within range
            if distance <= maxAimbotDistance and distance < closestDistance then
                closestDistance = distance
                target = player
            end
        end
    end
    
    return target
end

-- Function to move mouse to the enemy's head with adjustable Y-axis offset
local function aimAtEnemy()
    local target = findClosestEnemy()
    
    if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
        -- Calculate screen position of the enemy's head
        local headPosition = target.Character.Head.Position
        local offsetPosition = headPosition + Vector3.new(0, getgenv().AimbotYOffset, 0)
        local targetPosition = camera:WorldToViewportPoint(offsetPosition)
        
        -- Check if the enemy is within the FOV circle
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distanceToFOV = (Vector2.new(targetPosition.X, targetPosition.Y) - screenCenter).Magnitude
        
        if distanceToFOV <= getgenv().FOVRadius then
            -- Calculate smooth movement
            local smoothFactor = getgenv().Smoothness
            local mouseX = mouse.X
            local mouseY = mouse.Y
            
            -- Calculate movement difference
            local deltaX = targetPosition.X - mouseX
            local deltaY = targetPosition.Y - mouseY
            
            -- Apply smoothing
            local moveX = deltaX / smoothFactor
            local moveY = deltaY / smoothFactor
            
            -- Limit mouse movement to avoid excessive displacement
            moveX = math.clamp(moveX, -50, 50)
            moveY = math.clamp(moveY, -50, 50)
            
            -- Move mouse
            mousemoverel(moveX, moveY)
        end
    else
        -- If target is dead or not found, disconnect aiming and look for a new target
        if activeTargets[localPlayer.UserId] then
            activeTargets[localPlayer.UserId] = nil
        end
    end
end

-- Monitor distance and disable aimbot or highlight if out of range
local function monitorTargets()
    for userId, _ in pairs(activeTargets) do
        local target = players:GetPlayerByUserId(userId)
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            
            if distance > getgenv().MaxAimbotDistance then
                -- Disable aimbot and remove highlight
                activeTargets[userId] = nil
                removeHighlight(target)
                
                if aimingConnection then
                    aimingConnection:Disconnect()
                    aimingConnection = nil
                end
            end
        end
    end
end

-- Toggle aimbot with keybind
local function toggleAimbot()
    getgenv().AimbotEnabled = not getgenv().AimbotEnabled
    local status = getgenv().AimbotEnabled and "enabled" or "disabled"
    OrionLib:MakeNotification({
        Name = "Aimbot",
        Content = "Aimbot " .. status,
        Time = 3
    })
end

-- Keybind for aimbot toggle
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == getgenv().AimbotKeybind then
        toggleAimbot()
    end
end)

-- Enable auto-aim when mouse button is held down
local aimingConnection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        if getgenv().AimbotEnabled then
            aimingConnection = runService.RenderStepped:Connect(aimAtEnemy)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimingConnection then
        aimingConnection:Disconnect()
        aimingConnection = nil
    end
end)

-- Movement Tab UI
movementTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        getgenv().InfiniteJumpEnabled = state
        localPlayer.Character:WaitForChild("Humanoid").JumpPower = state and math.huge or 50
    end
})

movementTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(state)
        getgenv().NoClipEnabled = state
        localPlayer.Character.Humanoid:ChangeState(state and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp)
    end
})

movementTab:AddToggle({
    Name = "Bhop",
    Default = false,
    Callback = function(state)
        getgenv().BhopEnabled = state
        if state then
            localPlayer.Character:WaitForChild("Humanoid").JumpPower = 50
        end
    end
})

-- ESP Tab UI
espTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(state)
        getgenv().ESPEnabled = state
    end
})

espTab:AddSlider({
    Name = "ESP Distance",
    Min = 100,
    Max = 1000,
    Default = getgenv().MaxESPDistance,
    Increment = 50,
    Callback = function(value)
        getgenv().MaxESPDistance = value
    end
})

-- Aimbot Tab UI
aimbotTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(state)
        getgenv().AimbotEnabled = state
        if not state and aimingConnection then
            aimingConnection:Disconnect()
            aimingConnection = nil
        end
    end
})

aimbotTab:AddSlider({
    Name = "Aimbot Smoothness",
    Min = 0.1,
    Max = 2,
    Default = getgenv().Smoothness,
    Increment = 0.1,
    Callback = function(value)
        getgenv().Smoothness = value
    end
})

aimbotTab:AddSlider({
    Name = "Aimbot Y-Axis Offset",
    Min = 0,
    Max = 10,
    Default = getgenv().AimbotYOffset,
    Increment = 0.1,
    Callback = function(value)
        getgenv().AimbotYOffset = value
    end
})

aimbotTab:AddSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 500,
    Default = getgenv().FOVRadius,
    Increment = 10,
    Callback = function(value)
        getgenv().FOVRadius = value
        fovCircle.Radius = value
    end
})

aimbotTab:AddDropdown({
    Name = "Aimbot Keybind",
    Default = getgenv().AimbotKeybind,
    Options = {"F", "G", "H", "J", "K"},
    Callback = function(option)
        getgenv().AimbotKeybind = Enum.KeyCode[option]
    end
})
