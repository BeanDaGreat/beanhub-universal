-- Script taken from https://xenoscripts.com website --

-- SCRIPT COMPLET RAYFIELD UI - ESP + SPINBOT + TP/KILL PLAYER + FREECAM + NOCLIP + PLUS

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Enabled = false
local ESP_Objects = {}
local spinbotEnabled = false
local spinbotSpeed = 10
local FreecamEnabled = false
local NoClipEnabled = false
local InfiniteJumpEnabled = false
local WalkspeedEnabled = false
local WalkspeedValue = 16

local ESP_Settings = {
    Box = false,
    BoxFilled = false,
    Skeleton = false,
    Snapline = false,
    Name = false,
    Distance = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    BoxFilledColor = Color3.fromRGB(255, 0, 0),
    SkeletonColor = Color3.fromRGB(0, 149, 255),
    SnaplineColor = Color3.fromRGB(134, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(255, 111, 0),
    SnaplineDistance = 100
}

function ClearESP()
    for _, obj in pairs(ESP_Objects) do
        if typeof(obj) == "table" then
            for _, part in pairs(obj) do if part.Destroy then part:Destroy() end end
        elseif obj.Destroy then obj:Destroy() end
    end
    ESP_Objects = {}
end

function CreateESP(player)
    local box = Drawing.new("Square") box.Visible = false
    local name = Drawing.new("Text") name.Visible = false name.Size = 14 name.Center = true name.Outline = true
    local dist = Drawing.new("Text") dist.Visible = false dist.Size = 13 dist.Center = true dist.Outline = true
    local snap = Drawing.new("Line") snap.Visible = false snap.Thickness = 1
    local skeletonParts = {}
    ESP_Objects[player.Name] = {box, name, dist, snap, skeletonParts}

    RunService.RenderStepped:Connect(function()
        if not ESP_Enabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false name.Visible = false dist.Visible = false snap.Visible = false
            return
        end

        local root = player.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            local distance = (Camera.CFrame.Position - root.Position).Magnitude
            local size = math.clamp(1000 / distance, 10, 100)
            local boxSize = Vector2.new(size * 1.5, size * 2)
            local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)

            box.Position = boxPos
            box.Size = boxSize
            box.Color = ESP_Settings.BoxColor
            box.Filled = ESP_Settings.BoxFilled
            box.Transparency = 1
            box.Visible = ESP_Settings.Box or ESP_Settings.BoxFilled

            name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 16)
            name.Text = player.Name
            name.Color = ESP_Settings.NameColor
            name.Visible = ESP_Settings.Name

            dist.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 2)
            dist.Text = math.floor(distance) .. " studs"
            dist.Color = ESP_Settings.DistanceColor
            dist.Visible = ESP_Settings.Distance

            snap.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            snap.To = Vector2.new(pos.X, pos.Y)
            snap.Color = ESP_Settings.SnaplineColor
            snap.Visible = ESP_Settings.Snapline and distance <= ESP_Settings.SnaplineDistance
        else
            box.Visible = false
            name.Visible = false
            dist.Visible = false
            snap.Visible = false
        end
    end)
end

function RefreshESPPlayers()
    ClearESP()
    if ESP_Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                CreateESP(plr)
            end
        end
    end
end

function ToggleESP(enabled)
    ESP_Enabled = enabled
    RefreshESPPlayers()
end

RunService.RenderStepped:Connect(function()
    if spinbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed), 0)
    end
end)

RunService.Stepped:Connect(function()
    if NoClipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "MatrixLab - Universal Script",
    Icon = 0,
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "By MatrixLab",
    ShowText = "MatrixLab",
    Theme = "Serenity",

    ToggleUIKeybind = "K",

    DisableRayfieldPrompts = false,
    DisabledBuildWarning = false,
})

local mainTab = Window:CreateTab("Main", 4483362458)
local espTab = Window:CreateTab("ESP", 4483362458)
local espColorTab = Window:CreateTab("ESP Color", 4483362458)
local miscTab = Window:CreateTab("Misc", 4483362458)
local playerTab = Window:CreateTab("Player", 4483362458)
local onlineTab = Window:CreateTab("Online", 4483362458)
local supporterTab = Window:CreateTab("Supporter", 4483362458)

mainTab:CreateParagraph({Title = "Coming Soon", Content = "..."})
supporterTab:CreateParagraph({Title = "Developers", Content = "Dev: @spacyxx, @RC_Pain"})

espTab:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = ToggleESP})
espTab:CreateToggle({Name = "Box", CurrentValue = false, Callback = function(v) ESP_Settings.Box = v end})
espTab:CreateToggle({Name = "Box Filled", CurrentValue = false, Callback = function(v) ESP_Settings.BoxFilled = v end})
espTab:CreateToggle({Name = "Name", CurrentValue = false, Callback = function(v) ESP_Settings.Name = v end})
espTab:CreateToggle({Name = "Distance", CurrentValue = false, Callback = function(v) ESP_Settings.Distance = v end})
espTab:CreateToggle({Name = "Snapline", CurrentValue = false, Callback = function(v) ESP_Settings.Snapline = v end})
espTab:CreateSlider({Name = "Snapline Distance", Range = {50, 1000}, Increment = 10, CurrentValue = 100, Callback = function(v) ESP_Settings.SnaplineDistance = v end})
espTab:CreateButton({Name = "🔁 Refresh ESP Players", Callback = RefreshESPPlayers})

for name, _ in pairs(ESP_Settings) do
    if tostring(name):find("Color") then
        espColorTab:CreateColorPicker({Name = name, Color = ESP_Settings[name], Callback = function(v) ESP_Settings[name] = v end})
    end
end

miscTab:CreateToggle({Name = "Spinbot", CurrentValue = false, Callback = function(v) spinbotEnabled = v end})
miscTab:CreateSlider({Name = "Spinbot Speed", Range = {1, 50}, Increment = 1, Suffix = "°/frame", CurrentValue = 10, Callback = function(v) spinbotSpeed = v end})

playerTab:CreateToggle({Name = "NoClip", CurrentValue = false, Callback = function(v) NoClipEnabled = v end})
playerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfiniteJumpEnabled = v end})

local playerList = {}

function RefreshPlayerList()
    table.clear(playerList)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
end

RefreshPlayerList()

local TPDropdown = onlineTab:CreateDropdown({
    Name = "TP to Player",
    Options = playerList,
    CurrentOption = "",
    Callback = function(v)
        local target = Players:FindFirstChild(v)
        if target and target.Character and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(target.Character:GetPivot())
        end
    end
})

local KillDropdown = onlineTab:CreateDropdown({
    Name = "Kill Player",
    Options = playerList,
    CurrentOption = "",
    Callback = function(v)
        local target = Players:FindFirstChild(v)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
})

onlineTab:CreateButton({
    Name = "🔁 Refresh Player List",
    Callback = function()
        RefreshPlayerList()
        TPDropdown:SetOptions(playerList)
        KillDropdown:SetOptions(playerList)
    end
})

onlineTab:CreateButton({
    Name = "🚀 TP All Players To Me",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and localRoot then
                    root.CFrame = localRoot.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                end
            end
        end
    end
})

onlineTab:CreateButton({
    Name = "💀 Kill All Players",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    end
})

local WalkspeedEnabled = false
local WalkspeedValue = 16

playerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 150},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        WalkspeedValue = Value
        if WalkspeedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = WalkspeedValue
            end
        end
    end,
})

playerTab:CreateToggle({
    Name = "Active WalkSpeed",
    CurrentValue = false,
    Flag = "ActiveWalkSpeed",
    Callback = function(Value)
        WalkspeedEnabled = Value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value and WalkspeedValue or 16
        end
    end,
})
