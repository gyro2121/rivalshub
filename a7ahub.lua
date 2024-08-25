-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "A7A hub",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "Welcome to A7A hub"
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

-- Global settings for toggles
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().NoClipEnabled = false
getgenv().CFrameWalkEnabled = false
getgenv().BhopEnabled = false
getgenv().CFrameWalkSpeed = 0.1
getgenv().Smoothness = 0.6
getgenv().AutoFarmEnabled = false
getgenv().AimbotYOffset = 1.3 -- Default Y-axis offset for aiming
getgenv().AimbotKeybind = Enum.KeyCode.F -- Default keybind for toggling aimbot

-- Services
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Function to highlight enemy characters
local function highlightEnemy(player)
    if player.Character and not player.Character:FindFirstChild("Totally_NOT_Esp") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Totally_NOT_Esp"
        highlight.Adornee = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.5
        highlight.Parent = player.Character
    end
end

-- Function to enable ESP for all players
local function enableESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            highlightEnemy(player)
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
        enableESP()
    else
        for _, player in pairs(players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Totally_NOT_Esp") then
                player.Character.Totally_NOT_Esp:Destroy()
            end
        end
    end
end)

-- Function to find the nearest enemy to aim at
local function findClosestEnemy()
    local closestDistance = math.huge
    local target = nil
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local distance = (localPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                target = player
            end
        end
    end
    
    return target
end

-- Function to move mouse to the enemy's head with adjustable Y-axis offset
local aimingConnection = nil
local function aimAtEnemy()
    local target = findClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
        -- Calculate screen position of the enemy's head
        local headPosition = target.Character.Head.Position
        local offsetPosition = headPosition + Vector3.new(0, getgenv().AimbotYOffset, 0)
        local targetPosition = camera:WorldToViewportPoint(offsetPosition)
        
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
    else
        -- If target is dead or not found, disconnect aiming and look for a new target
        if aimingConnection then
            aimingConnection:Disconnect()
            aimingConnection = runService.RenderStepped:Connect(aimAtEnemy)
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
mouse.Button1Down:Connect(function()
    if getgenv().AimbotEnabled then
        aimingConnection = runService.RenderStepped:Connect(aimAtEnemy)
    end
end)

-- Disable auto-aim when mouse button is released
mouse.Button1Up:Connect(function()
    if aimingConnection then
        aimingConnection:Disconnect()
    end
end)

-- Add toggles to the UI

-- Aimbot Tab
aimbotTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        getgenv().AimbotEnabled = value
        local status = value and "enabled" or "disabled"
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = "Aimbot " .. status,
            Time = 3
        })
    end
})

-- Add slider for Y-axis offset
aimbotTab:AddSlider({
    Name = "Y-Axis Offset",
    Min = -10,
    Max = 10,
    Default = 0,
    Increment = 0.1,
    Callback = function(value)
        getgenv().AimbotYOffset = value
    end
})

-- Add keybind setting for aimbot
aimbotTab:AddDropdown({
    Name = "Aimbot Keybind",
    Default = getgenv().AimbotKeybind,
    Options = {"F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "T", "U", "V", "W", "X", "Y", "Z"},
    Callback = function(selectedKey)
        getgenv().AimbotKeybind = Enum.KeyCode[selectedKey]
    end
})

-- ESP Tab
espTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        getgenv().ESPEnabled = value
    end
})

-- Infinite Jump Toggle
Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
}):AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        getgenv().InfiniteJumpEnabled = value
        if value then
            local function infiniteJump()
                while getgenv().InfiniteJumpEnabled do
                    localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    localPlayer.Character.Humanoid.Jump = true
                    wait(0.1)
                end
            end
            infiniteJump()
        end
    end
})

-- No Clip Toggle
Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
}):AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(value)
        getgenv().NoClipEnabled = value
        local function noClip()
            local character = localPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = not getgenv().NoClipEnabled
                    end
                end
            end
        end
        noClip()
    end
})

-- Bunny Hop Toggle
Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
}):AddToggle({
    Name = "Bunny Hop",
    Default = false,
    Callback = function(value)
        getgenv().BhopEnabled = value
        local userInputService = game:GetService("UserInputService")
        userInputService.InputBegan:Connect(function(input)
            if getgenv().BhopEnabled and input.KeyCode == Enum.KeyCode.Space then
                localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                localPlayer.Character.Humanoid.Jump = true
            end
        end)
    end
})

-- Walk Speed Slider
Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998", -- Replace with your icon ID
    PremiumOnly = false
}):AddSlider({
    Name = "Walk Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        getgenv().WalkSpeed = value
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- Keybind to reopen the menu
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)

-- Notification on GUI load
OrionLib:MakeNotification({
    Name = "My GUI",
    Content = "GUI loaded successfully!",
    Time = 5
})
