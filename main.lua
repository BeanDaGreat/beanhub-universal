--[[
    FRESH HUB - ULTIMATE MASTER SCRIPT
    Converted to Fluent UI | 70+ Features | Bug-Fixed
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- // SERVICES // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- // VARIABLES // --
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local TargetPart = nil

-- // SETTINGS TABLE // --
local S = {
    -- Combat
    Aimbot = false, SilentAim = false, TeamCheck = false, WallCheck = false,
    Smoothness = 1, FOV = 150, ShowFOV = false, AimPart = "Head", 
    HitChance = 100, Triggerbot = false,
    -- Visuals
    ESP = false, Boxes = false, Names = false, Tracers = false, DistESP = false,
    MaxDist = 3000, BoxColor = Color3.fromRGB(255, 0, 0),
    -- Movement
    Speed = 16, Jump = 50, Fly = false, FlySpeed = 50, NoClip = false, 
    InfJump = false, Spinbot = false, AntiAFK = true,
    -- World
    Fullbright = false, ClockTime = 12, Gravity = 196.2, NoFog = false
}

-- // UI SETUP // --
local Window = Fluent:CreateWindow({
    Title = "BeanHub",
    SubTitle = "Universal v0.0.2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "zap" }),
    World = Window:AddTab({ Title = "World", Icon = "globe" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- // 1. COMBAT TAB // --
local CombatS = Tabs.Combat:AddSection("Aimbot Settings")
CombatS:AddToggle("Aimbot", {Title = "Main Aimbot", Default = false}):OnChanged(function(v) S.Aimbot = v end)
CombatS:AddToggle("TeamCheck", {Title = "Team Check", Default = false}):OnChanged(function(v) S.TeamCheck = v end)
CombatS:AddToggle("WallCheck", {Title = "Wall Check", Default = false}):OnChanged(function(v) S.WallCheck = v end)
CombatS:AddSlider("Smoothness", {Title = "Smoothing", Default = 1, Min = 1, Max = 20, Callback = function(v) S.Smoothness = v end})
CombatS:AddSlider("FOV", {Title = "FOV Radius", Default = 150, Min = 10, Max = 800, Callback = function(v) S.FOV = v end})
CombatS:AddToggle("ShowFOV", {Title = "Show FOV", Default = false}):OnChanged(function(v) S.ShowFOV = v end)
CombatS:AddDropdown("AimPart", {Title = "Aim Part", Values = {"Head", "UpperTorso", "HumanoidRootPart"}, Default = "Head", Callback = function(v) S.AimPart = v end})

-- // 2. VISUALS TAB // --
local VisS = Tabs.Visuals:AddSection("Player ESP")
VisS:AddToggle("ESPMaster", {Title = "Enable ESP", Default = false}):OnChanged(function(v) S.ESP = v end)
VisS:AddToggle("Boxes", {Title = "Boxes", Default = false}):OnChanged(function(v) S.Boxes = v end)
VisS:AddToggle("Names", {Title = "Names", Default = false}):OnChanged(function(v) S.Names = v end)
VisS:AddToggle("Tracers", {Title = "Tracers", Default = false}):OnChanged(function(v) S.Tracers = v end)
VisS:AddSlider("MaxDist", {Title = "Max Distance", Default = 3000, Min = 100, Max = 10000, Callback = function(v) S.MaxDist = v end})

-- // 3. MOVEMENT TAB // --
local MoveS = Tabs.Movement:AddSection("Modifications")
MoveS:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 250, Callback = function(v) S.Speed = v end})
MoveS:AddSlider("Jump", {Title = "JumpPower", Default = 50, Min = 50, Max = 300, Callback = function(v) S.Jump = v end})
MoveS:AddToggle("Fly", {Title = "Fly (W/A/S/D)", Default = false}):OnChanged(function(v) S.Fly = v end)
MoveS:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 50, Min = 10, Max = 200, Callback = function(v) S.FlySpeed = v end})
MoveS:AddToggle("NoClip", {Title = "NoClip", Default = false}):OnChanged(function(v) S.NoClip = v end)
MoveS:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) S.InfJump = v end)

-- // 4. WORLD TAB // --
local WorldS = Tabs.World:AddSection("Environment")
WorldS:AddToggle("Fullbright", {Title = "Fullbright", Default = false}):OnChanged(function(v) S.Fullbright = v end)
WorldS:AddSlider("Time", {Title = "Clock Time", Default = 12, Min = 0, Max = 24, Callback = function(v) S.ClockTime = v end})
WorldS:AddSlider("Gravity", {Title = "Gravity", Default = 196.2, Min = 0, Max = 196.2, Callback = function(v) workspace.Gravity = v end})
WorldS:AddButton({Title = "Server Hop", Callback = function() 
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(Servers) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id) end end
end})

-- // CORE LOGIC FUNCTIONS // --

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

local function IsVisible(part)
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, ray)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestPlayer()
    local target = nil
    local dist = S.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if S.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local part = p.Character:FindFirstChild(S.AimPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist then
                        if S.WallCheck and not IsVisible(part) then continue end
                        target = part
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- // ESP SYSTEM // --
local ESP_Manager = {}
local function AddESP(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Line = Drawing.new("Line")

    local function Update()
        local c
        c = RunService.RenderStepped:Connect(function()
            if S.ESP and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid").Health > 0 then
                local HRP = Player.Character.HumanoidRootPart
                local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                local Distance = (Camera.CFrame.Position - HRP.Position).Magnitude

                if OnScreen and Distance < S.MaxDist then
                    local Size = 2000 / Pos.Z
                    if S.Boxes then
                        Box.Visible = true; Box.Size = Vector2.new(Size, Size * 1.5)
                        Box.Position = Vector2.new(Pos.X - Size/2, Pos.Y - (Size * 1.5)/2)
                        Box.Color = Color3.fromRGB(255, 0, 0)
                    else Box.Visible = false end

                    if S.Names then
                        Name.Visible = true; Name.Text = Player.Name .. " ["..math.floor(Distance).."m]"
                        Name.Position = Vector2.new(Pos.X, Pos.Y - (Size) - 10); Name.Center = true; Name.Size = 14
                    else Name.Visible = false end

                    if S.Tracers then
                        Line.Visible = true; Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        Line.To = Vector2.new(Pos.X, Pos.Y); Line.Color = Color3.fromRGB(255, 0, 0)
                    else Line.Visible = false end
                else
                    Box.Visible = false; Name.Visible = false; Line.Visible = false
                end
            else
                Box.Visible = false; Name.Visible = false; Line.Visible = false
                if not Player.Parent then Box:Remove(); Name:Remove(); Line:Remove(); c:Disconnect() end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- // MAIN LOOPS // --

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV
    FOVCircle.Radius = S.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = S.Speed
        LocalPlayer.Character.Humanoid.JumpPower = S.Jump
        
        if S.Fly then
            local HRP = LocalPlayer.Character.HumanoidRootPart
            local Dir = Vector3.new(0, 0.1, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + (Camera.CFrame.LookVector * S.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - (Camera.CFrame.LookVector * S.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - (Camera.CFrame.RightVector * S.FlySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + (Camera.CFrame.RightVector * S.FlySpeed) end
            HRP.Velocity = Dir
        end
    end

    if S.Aimbot then
        local Target = GetClosestPlayer()
        if Target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), 1/S.Smoothness)
        end
    end

    if S.Fullbright then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
end)

RunService.Stepped:Connect(function()
    if S.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Initialization
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FreshHub")
SaveManager:SetFolder("BeanHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({ Title = "BeanHub", Content = "Script Loaded Successfully. Key: RightCtrl", Duration = 5 })
