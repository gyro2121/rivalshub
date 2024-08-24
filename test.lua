-- Function to decrypt a string using XOR encryption

-- Initialization of various features
getgenv().features = {
    ESP = true,
    Aimbot = true,
    InfiniteJump = true,
    NoClip = true,
    AutoFarm = true,
    BunnyHop = true
}

-- Function to enable ESP (Extra Sensory Perception)
function enableESP()
    if not getgenv().features.ESP then return end

    local players = game:GetService("Players")
    for _, player in pairs(players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
        end
    end
end

-- Function to enable Aimbot
function enableAimbot()
    if not getgenv().features.Aimbot then return end

    local players = game:GetService("Players")
    local localPlayer = game.Players.LocalPlayer

    while getgenv().features.Aimbot do
        local target = nil
        local closestDistance = math.huge

        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                local distance = (localPlayer.Character.Head.Position - player.Character.Head.Position).magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    target = player
                end
            end
        end

        if target then
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position)
        end
        wait(0.1)
    end
end

-- Function to enable Infinite Jump
function enableInfiniteJump()
    if not getgenv().features.InfiniteJump then return end

    local player = game.Players.LocalPlayer
    local userInputService = game:GetService("UserInputService")

    userInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            player.Character:FindFirstChildOfClass("Humanoid").Jump = true
        end
    end)
end

-- Function to enable No Clip
function enableNoClip()
    if not getgenv().features.NoClip then return end

    local player = game.Players.LocalPlayer
    local character = player.Character

    if character then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end

-- Function to enable AutoFarm
function enableAutoFarm()
    if not getgenv().features.AutoFarm then return end

    -- Example logic for AutoFarm (farming resources)
    while getgenv().features.AutoFarm do
        -- Example: Move to a resource and collect it
        -- Replace with actual resource coordinates and collection logic
        local resourcePosition = Vector3.new(0, 0, 0)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(resourcePosition)
        wait(1)
    end
end

-- Function to enable Bunny Hop
function enableBunnyHop()
    if not getgenv().features.BunnyHop then return end

    local player = game.Players.LocalPlayer
    local userInputService = game:GetService("UserInputService")

    userInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            player.Character:FindFirstChildOfClass("Humanoid").Jump = true
        end
    end)
end

-- Function to enable CFrame Walk
function enableCFrameWalk()
    if not getgenv().features.CFrameWalk then return end

    local player = game.Players.LocalPlayer

    -- Example logic for CFrame Walk
    while getgenv().features.CFrameWalk do
        -- Replace with actual movement logic
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 1)
        wait(0.1)
    end
end

-- Call functions to activate features
enableESP()
enableAimbot()
enableInfiniteJump()
enableNoClip()
enableAutoFarm()
enableBunnyHop()
enableCFrameWalk()
