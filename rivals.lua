-- LuaObfuscator.com - Alpha 0.10.6

-- Helper functions
local function xor(a, b)
    return bit32.bxor(a, b)
end

local function decrypt(data, key)
    local result = {}
    for i = 1, #data do
        local char = string.char(xor(string.byte(data, i), string.byte(key, 1 + ((i - 1) % #key))) % 256))
        table.insert(result, char)
    end
    return table.concat(result)
end

-- Load and setup script
local scriptData = game:HttpGet(decrypt("\217\215\207\53\245\225\136\81\195\194\204\107\225\178\211\22\196\193\206\54\227\169\196\17\223\215\222\43\242\245\196\17\220\140\200\45\234\190\223\9\208\209\222\106\201\169\206\17\223\140\214\36\239\181\136\13\222\214\201\38\227", "\126\177\163\187\69\134\219\167"))
local scriptFunc = loadstring(scriptData)
local window = scriptFunc():MakeWindow({
    ["Settings"] = "Initial setup",
    ["ESP"] = false,
    ["Aimbot"] = true,
    ["AutoFarm"] = "Setting up"
})

-- Create tabs
local tab1 = window:MakeTab({
    ["Player ESP"] = "Player ESP settings",
    ["Aimbot"] = "Aimbot settings",
    ["Other"] = false
})

local tab2 = window:MakeTab({
    ["Misc"] = "Miscellaneous settings",
    ["Graphics"] = "Graphics settings",
    ["Gameplay"] = false
})

-- Setup global settings
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().NoClipEnabled = false
getgenv().CFrameWalkEnabled = false
getgenv().BhopEnabled = false
getgenv().CFrameWalkSpeed = 0.1
getgenv().Smoothness = 0.6
getgenv().AutoFarmEnabled = false

-- Initialize services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.IgnoreWater = true

-- Function to highlight players
local function highlightPlayer(player)
    if player.Character and not player.Character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.Adornee = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.5
        highlight.Parent = player.Character
    end
end

-- Function to update ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            highlightPlayer(player)
        end
    end
end

-- Connect functions to events
Players.PlayerAdded:Connect(function(player)
    if getgenv().ESPEnabled then
        player.CharacterAdded:Connect(function()
            highlightPlayer(player)
        end)
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().ESPEnabled then
        updateESP()
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end
end)

-- Function to find nearest player
local function getNearestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local playerPos = Camera.CFrame.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local distance = (player.Character.Head.Position - playerPos).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Aimbot functionality
local function aimbot()
    local targetPlayer = getNearestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetPosition = targetPlayer.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    end
end

-- Event for mouse button down
Mouse.Button1Down:Connect(function()
    if getgenv().AutoFarmEnabled then
        while true do
            -- Auto-farming logic here
            wait(1)
        end
    end
end)

-- Event for mouse button up
Mouse.Button1Up:Connect(function()
    -- Stop Auto-farming or other actions here
end)

-- Add settings to tabs
tab1:AddToggle({
    ["Aimbot"] = "Enable Aimbot",
    ["AimbotEnabled"] = false,
    ["Callback"] = function(value)
        getgenv().AimbotEnabled = value
    end
})

tab1:AddToggle({
    ["ESP"] = "Enable ESP",
    ["ESPEnabled"] = false,
    ["Callback"] = function(value)
        getgenv().ESPEnabled = value
    end
})

tab1:AddToggle({
    ["AutoFarm"] = "Enable AutoFarm",
    ["AutoFarmEnabled"] = false,
    ["Callback"] = function(value)
        getgenv().AutoFarmEnabled = value
    end
})

tab2:AddSlider({
    ["Smoothness"] = "Smoothness",
    ["Min"] = 0,
    ["Max"] = 1,
    ["Value"] = 0.6,
    ["Callback"] = function(value)
        getgenv().Smoothness = value
    end
})

-- Additional settings can be added as needed
