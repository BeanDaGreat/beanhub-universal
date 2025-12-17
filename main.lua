-- BeanHub Universal • Rayfield Edition
-- Author: BeanDaGreat
-- Version: 1.0

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "BeanHub Universal • Rayfield",
    LoadingTitle = "BeanHub Universal",
    LoadingSubtitle = "by BeanDaGreat",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BeanHubUniversal",
        FileName = "UniversalConfig"
    }
})

-- State
local State = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    FlySpeed = 80,
    Noclip = false,
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(50,200,255),
    ESPDistance = 1500,
    ESPPlayers = true,
    ESPNPCs = true,
    ESPItems = true,
    AimbotEnabled = false,
    AimbotFOV = 140,
    AimbotSmoothness = 0.15,
    AimbotTargetPart = "UpperTorso",
    FOVCircle = true,
    AntiAFK = true,
    AutoRespawn = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helpers
local function getCharacter(plr)
    plr = plr or LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
end

local function setWalkSpeed(v)
    State.WalkSpeed = v
    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end

local function setJumpPower(v)
    State.JumpPower = v
    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Auto-respawn restore
LocalPlayer.CharacterAdded:Connect(function()
    if State.AutoRespawn then
        task.wait(0.5)
        setWalkSpeed(State.WalkSpeed)
        setJumpPower(State.JumpPower)
    end
end)

-- Fly
local FlyBV, FlyBG, flyConn
local function toggleFly(enabled)
    State.FlyEnabled = enabled
    local char = getCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if enabled then
        if hum then hum.PlatformStand = true end
        FlyBV = Instance.new("BodyVelocity"); FlyBV.MaxForce = Vector3.new(1e5,1e5,1e5); FlyBV.Parent = hrp
        FlyBG = Instance.new("BodyGyro"); FlyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); FlyBG.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            if not State.FlyEnabled then return end
            local cf = Camera.CFrame
            local mv = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.new(0,1,0) end
            FlyBV.Velocity = mv.Magnitude > 0 and mv.Unit * State.FlySpeed or Vector3.new()
            FlyBG.CFrame = cf
        end)
    else
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
        if FlyBG then FlyBG:Destroy() FlyBG = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- Tabs
local MovementTab = Window:CreateTab("Movement", 4483345998)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local CombatTab = Window:CreateTab("Combat", 4483345998)
local UtilitiesTab = Window:CreateTab("Utilities", 4483345998)
local InfoTab = Window:CreateTab("Info", 4483345998)

-- Movement controls
MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {10, 160},
    Increment = 1,
    CurrentValue = State.WalkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = setWalkSpeed
})
MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {30, 200},
    Increment = 1,
    CurrentValue = State.JumpPower,
    Flag = "JumpPowerSlider",
    Callback = setJumpPower
})
MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = State.FlyEnabled,
    Flag = "FlyToggle",
    Callback = toggleFly
})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 300},
    Increment = 5,
    CurrentValue = State.FlySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(v) State.FlySpeed = v end
})

-- Visuals controls (ESP simplified for Rayfield demo)
VisualsTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = State.ESPEnabled,
    Flag = "ESPToggle",
    Callback = function(v) State.ESPEnabled = v end
})
VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = State.ESPColor,
    Flag = "ESPColorPicker",
    Callback = function(v) State.ESPColor = v end
})

-- Combat controls
CombatTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = State.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(v) State.AimbotEnabled = v end
})
CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {40, 300},
    Increment = 10,
    CurrentValue = State.AimbotFOV,
    Flag = "AimbotFOVSlider",
    Callback = function(v) State.AimbotFOV = v end
})
CombatTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.05, 0.5},
    Increment = 0.01,
    CurrentValue = State.AimbotSmoothness,
    Flag = "AimbotSmoothSlider",
    Callback = function(v) State.AimbotSmoothness = v end
})

-- Utilities
UtilitiesTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
UtilitiesTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local servers = game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
        local data = game:GetService("HttpService"):JSONDecode(servers)
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end
})

-- Info
InfoTab:CreateParagraph({
    Title = "Session Info",
    Content = string.format("PlaceId: %s\nJobId: %s\nPlayers: %d", tostring(game.PlaceId), tostring(game.JobId), #Players:GetPlayers())
})
