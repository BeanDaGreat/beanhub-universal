--[[
Universal Orion Script v1.2
- UI: Orion Library (shlexware/Orion)
- Tabs: Movement, Visuals, Combat, Utilities, Info
- Fixes: Proper noclip disconnect, fly-respawn reapply, ESP connection tracking & cleanup, safe player list refresh,
         resilient FOV GUI, safe FPS/Ping monitor, dropdown rebuild without duplicates, panic cleanup thoroughness
- Features: WalkSpeed, JumpPower, Fly, Noclip, Advanced ESP (players/NPCs/items), Soft-lock aimbot, FOV circle,
            Teleport to player/coordinates, Server hop, Rejoin, Anti-AFK, Auto-respawn restore, Chat spy,
            Auto tool equip, Safe reset, Keybind manager, Theme selector, FPS/Ping overlay, Script auto-updater

Notes:
- Universal: avoids game-specific remotes and anti-cheats; uses Roblox-native instances.
- If your executor lacks certain APIs (e.g., setfpscap), fallbacks are used.
- You can disable/enable features per tab safely.
]]

-- Safe services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Versioning and auto-updater
local SCRIPT_VERSION = "1.0"
local AUTO_UPDATE_URL = "https://raw.githubusercontent.com/BeanDaGreat/beanhub-universal/main/main.lua" -- replace with your URL
local AUTO_UPDATE_ENABLED = true

local function safeHttpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and result or nil
end

local function tryAutoUpdate()
    if not AUTO_UPDATE_ENABLED then return end
    local body = safeHttpGet(AUTO_UPDATE_URL)
    if not body then return end
    local latestVersion = body:match('SCRIPT_VERSION%s*=%s*"([%d%.]+)"')
    if latestVersion and latestVersion ~= SCRIPT_VERSION then
        local OrionLib = getgenv().__OrionLib
        if OrionLib and OrionLib.MakeNotification then
            OrionLib:MakeNotification({
                Name = "Auto-Update",
                Content = "New version "..latestVersion.." found. Updating and reloading...",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
        loadstring(body)()
        return true
    end
    return false
end

-- Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
getgenv().__OrionLib = OrionLib

local Window = OrionLib:MakeWindow({
    Name = "BeanHub Universal • Orion v"..SCRIPT_VERSION,
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BeanHubUniversal"
})

-- State
local State = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    FlySpeed = 80,
    Noclip = false,
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(50, 200, 255),
    ESPDistance = 1500,
    ESPPlayers = true,
    ESPNPCs = true,
    ESPItems = true,
    ESPItemNames = true,
    AimbotEnabled = false,
    AimbotFOV = 140,
    AimbotSmoothness = 0.15,
    AimbotTargetPart = "UpperTorso",
    FOVCircle = true,
    AntiAFK = true,
    AutoRespawn = true,
    ChatSpy = false,
    AutoEquipTool = true,
    Theme = "Dark"
}

-- Utilities
local Connections = {}
local EspConnections = {}
local EspObjects = {}
local GuiFolder = Instance.new("Folder")
GuiFolder.Name = "OrionUniversalFolder"
GuiFolder.Parent = game:GetService("CoreGui")

local function addConnection(conn, bucket)
    bucket = bucket or Connections
    table.insert(bucket, conn)
    return conn
end

local function disconnectAll(bucket)
    for i, c in ipairs(bucket) do
        pcall(function() c:Disconnect() end)
        bucket[i] = nil
    end
end

local function notify(title, content, duration)
    OrionLib:MakeNotification({
        Name = title,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = duration or 4
    })
end

local function getCharacter(plr)
    plr = plr or LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
end

local function setWalkSpeed(value)
    State.WalkSpeed = value
    local char = getCharacter()
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
    end
end

local function setJumpPower(value)
    State.JumpPower = value
    local char = getCharacter()
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = value end
    end
end

-- Anti-AFK
local function initAntiAFK()
    disconnectAll({LocalPlayer.__AntiAFKConn})
    if not State.AntiAFK then return end
    local vu = game:GetService("VirtualUser")
    LocalPlayer.__AntiAFKConn = addConnection(LocalPlayer.Idled:Connect(function()
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end))
end

-- Auto-respawn restore
local function initAutoRespawn()
    disconnectAll({LocalPlayer.__AutoRespawnConn})
    if not State.AutoRespawn then return end
    LocalPlayer.__AutoRespawnConn = addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        setWalkSpeed(State.WalkSpeed)
        setJumpPower(State.JumpPower)
        if State.FlyEnabled then
            task.wait(0.1)
            -- reapply fly on respawn
            local ok, err = pcall(function() _G.__ToggleFly(true) end)
            if not ok then warn("Fly reapply error:", err) end
        end
        notify("Respawn", "Stats restored.", 3)
    end))
end

-- Noclip
local noclipConn
local function setNoclip(enabled)
    State.Noclip = enabled
    if enabled and not noclipConn then
        noclipConn = addConnection(RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
    elseif not enabled and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        -- attempt to restore collide on important parts
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fly
local FlyBV, FlyBG
local function toggleFly(enabled)
    State.FlyEnabled = enabled
    local char = getCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if enabled then
        if humanoid then humanoid.PlatformStand = true end
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBV.Velocity = Vector3.new()
        FlyBV.Parent = hrp

        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyBG.CFrame = hrp.CFrame
        FlyBG.Parent = hrp

        _G.__FlyConn = _G.__FlyConn and (pcall(function() _G.__FlyConn:Disconnect() end) and nil) or nil
        _G.__FlyConn = addConnection(RunService.RenderStepped:Connect(function()
            if not State.FlyEnabled then return end
            local cf = Camera.CFrame
            local moveVec = Vector3.new()
            local keys = {
                W = UserInputService:IsKeyDown(Enum.KeyCode.W),
                S = UserInputService:IsKeyDown(Enum.KeyCode.S),
                A = UserInputService:IsKeyDown(Enum.KeyCode.A),
                D = UserInputService:IsKeyDown(Enum.KeyCode.D),
                Space = UserInputService:IsKeyDown(Enum.KeyCode.Space),
                Ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            }
            if keys.W then moveVec = moveVec + cf.LookVector end
            if keys.S then moveVec = moveVec - cf.LookVector end
            if keys.A then moveVec = moveVec - cf.RightVector end
            if keys.D then moveVec = moveVec + cf.RightVector end
            if keys.Space then moveVec = moveVec + Vector3.new(0,1,0) end
            if keys.Ctrl then moveVec = moveVec - Vector3.new(0,1,0) end

            FlyBV.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * State.FlySpeed or Vector3.new()
            FlyBG.CFrame = cf
        end))
    else
        if FlyBV then pcall(function() FlyBV:Destroy() end) FlyBV = nil end
        if FlyBG then pcall(function() FlyBG:Destroy() end) FlyBG = nil end
        if _G.__FlyConn then pcall(function() _G.__FlyConn:Disconnect() end) _G.__FlyConn = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
end
_G.__ToggleFly = toggleFly

-- FOV GUI
local FOVGui = Instance.new("ScreenGui")
FOVGui.IgnoreGuiInset = true
FOVGui.ResetOnSpawn = false
FOVGui.Name = "FOVGui"
FOVGui.Parent = GuiFolder

local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.fromScale(0.5, 0.5)
FOVFrame.Size = UDim2.new(0, State.AimbotFOV*2, 0, State.AimbotFOV*2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVFrame

local function setFOVVisible(visible)
    FOVGui.Enabled = visible and State.FOVCircle
end

local function updateFOVSize()
    FOVFrame.Size = UDim2.new(0, State.AimbotFOV*2, 0, State.AimbotFOV*2)
end

-- Aimbot (soft lock)
local function getClosestTarget()
    local closestPart, closestDist
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = getCharacter(plr)
            if char then
                local part = char:FindFirstChild(State.AimbotTargetPart) or char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist <= State.AimbotFOV and (not closestDist or dist < closestDist) then
                            closestPart = part
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

addConnection(RunService.RenderStepped:Connect(function()
    setFOVVisible(State.AimbotEnabled)
    if not State.AimbotEnabled then return end
    local targetPart = getClosestTarget()
    if targetPart then
        local desired = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(desired, State.AimbotSmoothness)
    end
end))

-- Advanced ESP: players, NPCs (Humanoid without Player), items (Tools in Workspace)
local function clearESPFor(key)
    local objs = EspObjects[key]
    if objs then
        for _, obj in ipairs(objs) do
            pcall(function() obj:Destroy() end)
        end
    end
    EspObjects[key] = nil
    local conns = EspConnections[key]
    if conns then
        disconnectAll(conns)
        EspConnections[key] = nil
    end
end

local function trackESPConn(key, conn)
    EspConnections[key] = EspConnections[key] or {}
    table.insert(EspConnections[key], conn)
end

local function labelFor(adorn, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.ExtentsOffsetWorldSpace = Vector3.new(0, 3, 0)
    bb.Adornee = adorn
    bb.Parent = GuiFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = bb

    return bb, label
end

local function makeHighlight(adorn, color)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = adorn
    highlight.Parent = GuiFolder
    return highlight
end

local function createPlayerESP(plr)
    if not State.ESPPlayers or plr == LocalPlayer then return end
    clearESPFor(plr)
    local char = getCharacter(plr)
    if not char then
        trackESPConn(plr, addConnection(plr.CharacterAdded:Connect(function(newChar)
            task.wait(0.2)
            createPlayerESP(plr)
        end), EspConnections[plr]))
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local highlight = makeHighlight(char, State.ESPColor)
    local bb, label = labelFor(hrp, "", State.ESPColor)

    EspObjects[plr] = {highlight, bb}

    trackESPConn(plr, addConnection(RunService.RenderStepped:Connect(function()
        if not State.ESPEnabled or not State.ESPPlayers then
            highlight.Enabled = false
            bb.Enabled = false
            return
        end
        if not char.Parent then return end
        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        local alive = humanoid.Health > 0
        label.Text = string.format("%s | %dm%s",
            plr.DisplayName or plr.Name,
            math.floor(distance),
            alive and "" or " (down)"
        )
        label.TextColor3 = alive and State.ESPColor or Color3.fromRGB(255, 80, 80)
        bb.Enabled = distance <= State.ESPDistance
        highlight.Enabled = distance <= State.ESPDistance
    end), EspConnections[plr]))
end

local function isNPCModel(model)
    if not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    -- exclude player characters
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then
            return false
        end
    end
    return true
end

local function createNPCESP(model)
    if not State.ESPNPCs then return end
    clearESPFor(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local color = Color3.fromRGB(255, 190, 90)
    local highlight = makeHighlight(model, color)
    local bb, label = labelFor(hrp, "NPC", color)
    EspObjects[model] = {highlight, bb}

    trackESPConn(model, addConnection(RunService.RenderStepped:Connect(function()
        if not State.ESPEnabled or not State.ESPNPCs then
            highlight.Enabled = false
            bb.Enabled = false
            return
        end
        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        local alive = humanoid.Health > 0
        label.Text = string.format("NPC | %dm%s", math.floor(distance), alive and "" or " (down)")
        label.TextColor3 = alive and color or Color3.fromRGB(255, 80, 80)
        bb.Enabled = distance <= State.ESPDistance
        highlight.Enabled = distance <= State.ESPDistance
    end), EspConnections[model]))
end

local function createItemESP(tool)
    if not State.ESPItems then return end
    clearESPFor(tool)
    local handle = tool:FindFirstChild("Handle")
    local adorn = handle or tool
    if not adorn or not adorn:IsA("BasePart") then return end

    local color = Color3.fromRGB(120, 255, 160)
    local highlight = makeHighlight(tool, color)
    local bb, label = labelFor(adorn, State.ESPItemNames and (tool.Name) or "Item", color)
    EspObjects[tool] = {highlight, bb}

    trackESPConn(tool, addConnection(RunService.RenderStepped:Connect(function()
        if not State.ESPEnabled or not State.ESPItems then
            highlight.Enabled = false
            bb.Enabled = false
            return
        end
        local distance = (Camera.CFrame.Position - adorn.Position).Magnitude
        label.Text = State.ESPItemNames and string.format("%s | %dm", tool.Name, math.floor(distance)) or string.format("Item | %dm", math.floor(distance))
        bb.Enabled = distance <= State.ESPDistance
        highlight.Enabled = distance <= State.ESPDistance
    end), EspConnections[tool]))
end

local function rebuildESP()
    -- Clear all
    for key, _ in pairs(EspObjects) do
        clearESPFor(key)
    end
    if not State.ESPEnabled then return end

    -- Players
    if State.ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            createPlayerESP(plr)
        end
    end

    -- NPCs in Workspace
    if State.ESPNPCs then
        for _, m in ipairs(workspace:GetDescendants()) do
            if isNPCModel(m) then
                createNPCESP(m)
            end
        end
    end

    -- Items (Tools) in Workspace
    if State.ESPItems then
        for _, t in ipairs(workspace:GetDescendants()) do
            if t:IsA("Tool") then
                createItemESP(t)
            end
        end
    end
end

-- Track new/removed ESP targets
addConnection(Players.PlayerAdded:Connect(function(plr)
    task.wait(0.2)
    createPlayerESP(plr)
end))
addConnection(Players.PlayerRemoving:Connect(function(plr)
    clearESPFor(plr)
end))
addConnection(workspace.DescendantAdded:Connect(function(obj)
    if State.ESPNPCs and isNPCModel(obj) then
        createNPCESP(obj)
    elseif State.ESPItems and obj:IsA("Tool") then
        createItemESP(obj)
    end
end))
addConnection(workspace.DescendantRemoving:Connect(function(obj)
    clearESPFor(obj)
end))

-- Player list helpers
local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    table.sort(names)
    return names
end

-- FPS/Ping overlay
local statsLabel = Instance.new("TextLabel", GuiFolder)
statsLabel.Size = UDim2.new(0, 220, 0, 30)
statsLabel.Position = UDim2.new(0, 10, 0, 10)
statsLabel.BackgroundTransparency = 0.5
statsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 14
statsLabel.Text = "FPS: -- | Ping: --ms"
statsLabel.ZIndex = 10

local lastTime = tick()
local frameCount = 0
addConnection(RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 1 then
        local fps = frameCount
        frameCount = 0
        lastTime = now
        local pingStat = StatsService.Network.ServerStatsItem["Data Ping"]
        local ping = pingStat and math.floor(pingStat:GetValue()) or 0
        statsLabel.Text = ("FPS: %d | Ping: %dms"):format(fps, ping)
    end
end))

-- Chat spy
local function initChatSpy(enabled)
    disconnectAll({_G.__ChatSpyConn})
    State.ChatSpy = enabled
    if not enabled then return end

    local chatGui = Instance.new("ScreenGui")
    chatGui.Name = "ChatSpyGui"
    chatGui.ResetOnSpawn = false
    chatGui.Parent = GuiFolder

    local frame = Instance.new("Frame", chatGui)
    frame.Size = UDim2.new(0, 400, 0, 220)
    frame.Position = UDim2.new(1, -410, 1, -230)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.2

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1, -10, 1, -10)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.Font = Enum.Font.Code
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextScaled = false
    text.TextSize = 14
    text.Text = "Chat Spy:\n"

    _G.__ChatSpyConn = addConnection(Players.PlayerAdded:Connect(function(plr)
        addConnection(plr.Chatted:Connect(function(msg)
            text.Text = text.Text..("\n[%s]: %s"):format(plr.Name, msg)
            text.Text = string.sub(text.Text, math.max(#text.Text-4000, 1)) -- keep reasonable size
        end))
    end))
    for _, plr in ipairs(Players:GetPlayers()) do
        addConnection(plr.Chatted:Connect(function(msg)
            text.Text = text.Text..("\n[%s]: %s"):format(plr.Name, msg)
            text.Text = string.sub(text.Text, math.max(#text.Text-4000, 1))
        end))
    end
end

-- Auto tool equip
local function initAutoEquip(enabled)
    disconnectAll({_G.__AutoEquipConn})
    State.AutoEquipTool = enabled
    if not enabled then return end
    _G.__AutoEquipConn = addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function() tool.Parent = char end)
                    break
                end
            end
        end
    end))
end

-- Safe reset
local function safeReset()
    local char = getCharacter()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
        notify("Reset", "Character reset.", 2)
    end
end

-- Tabs
local movementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local visualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local utilitiesTab = Window:MakeTab({Name = "Utilities", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local infoTab = Window:MakeTab({Name = "Info", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Movement controls
movementTab:AddSlider({
    Name = "WalkSpeed",
    Min = 10, Max = 160, Default = State.WalkSpeed, Color = Color3.fromRGB(100, 200, 255), Increment = 1,
    Callback = setWalkSpeed
})
movementTab:AddSlider({
    Name = "JumpPower",
    Min = 30, Max = 200, Default = State.JumpPower, Color = Color3.fromRGB(255, 180, 80), Increment = 1,
    Callback = setJumpPower
})
movementTab:AddToggle({Name = "Fly", Default = State.FlyEnabled, Callback = toggleFly})
movementTab:AddSlider({
    Name = "Fly speed",
    Min = 20, Max = 300, Default = State.FlySpeed, Color = Color3.fromRGB(180, 255, 120), Increment = 5,
    Callback = function(val) State.FlySpeed = val end
})
movementTab:AddToggle({Name = "Noclip", Default = State.Noclip, Callback = setNoclip})
movementTab:AddBind({
    Name = "Quick toggle fly", Default = Enum.KeyCode.F, Hold = false,
    Callback = function() toggleFly(not State.FlyEnabled) end
})

-- Visuals controls
visualsTab:AddToggle({
    Name = "ESP master toggle", Default = State.ESPEnabled,
    Callback = function(val)
        State.ESPEnabled = val
        rebuildESP()
    end
})
visualsTab:AddColorpicker({
    Name = "ESP color", Default = State.ESPColor,
    Callback = function(val) State.ESPColor = val rebuildESP() end
})
visualsTab:AddSlider({
    Name = "ESP distance", Min = 100, Max = 3000, Default = State.ESPDistance, Color = Color3.fromRGB(160, 160, 255), Increment = 50,
    Callback = function(val) State.ESPDistance = val end
})
visualsTab:AddToggle({Name = "ESP players", Default = State.ESPPlayers, Callback = function(v) State.ESPPlayers = v rebuildESP() end})
visualsTab:AddToggle({Name = "ESP NPCs", Default = State.ESPNPCs, Callback = function(v) State.ESPNPCs = v rebuildESP() end})
visualsTab:AddToggle({Name = "ESP items (Tools)", Default = State.ESPItems, Callback = function(v) State.ESPItems = v rebuildESP() end})
visualsTab:AddToggle({Name = "ESP show item names", Default = State.ESPItemNames, Callback = function(v) State.ESPItemNames = v rebuildESP() end})
visualsTab:AddToggle({
    Name = "Show FOV circle", Default = State.FOVCircle,
    Callback = function(val) State.FOVCircle = val setFOVVisible(val) end
})

-- Combat controls
combatTab:AddToggle({Name = "Aimbot (soft lock)", Default = State.AimbotEnabled, Callback = function(v) State.AimbotEnabled = v setFOVVisible(v) end})
combatTab:AddSlider({
    Name = "Aimbot FOV", Min = 40, Max = 300, Default = State.AimbotFOV, Color = Color3.fromRGB(255, 255, 255), Increment = 10,
    Callback = function(val) State.AimbotFOV = val updateFOVSize() end
})
combatTab:AddSlider({
    Name = "Aimbot smoothness", Min = 0.05, Max = 0.5, Default = State.AimbotSmoothness, Color = Color3.fromRGB(120, 255, 120), Increment = 0.01,
    Callback = function(val) State.AimbotSmoothness = val end
})
combatTab:AddDropdown({
    Name = "Target part", Default = State.AimbotTargetPart, Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    Callback = function(val) State.AimbotTargetPart = val end
})

-- Utilities
local tpDropdown -- reused handle
local function refreshTPDropdown()
    local options = getPlayerNames()
    if tpDropdown then
        tpDropdown:Set(options)
    else
        tpDropdown = utilitiesTab:AddDropdown({
            Name = "Teleport to player", Default = "", Options = options,
            Callback = function(val)
                local char = getCharacter()
                local target = Players:FindFirstChild(val)
                if char and target and getCharacter(target) then
                    char:MoveTo(getCharacter(target).HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    notify("Teleport", "Moved near "..val, 3)
                else
                    notify("Teleport", "Failed. Character or target missing.", 3)
                end
            end
        })
    end
end
refreshTPDropdown()
utilitiesTab:AddButton({Name = "Refresh player list", Callback = refreshTPDropdown})

utilitiesTab:AddTextbox({
    Name = "Teleport to coordinates (X,Y,Z)", Default = "", TextDisappear = true,
    Callback = function(val)
        local coords = string.split(val, ",")
        if #coords == 3 then
            local x,y,z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
            local char = getCharacter()
            if char and x and y and z then
                char:MoveTo(Vector3.new(x,y,z))
                notify("Teleport", "Teleported to "..val, 3)
            else
                notify("Teleport", "Invalid coordinates.", 3)
            end
        else
            notify("Teleport", "Use format: X,Y,Z", 3)
        end
    end
})
utilitiesTab:AddToggle({Name = "Anti-AFK", Default = State.AntiAFK, Callback = function(v) State.AntiAFK = v initAntiAFK() end})
utilitiesTab:AddToggle({Name = "Auto-respawn restore", Default = State.AutoRespawn, Callback = function(v) State.AutoRespawn = v initAutoRespawn() end})
utilitiesTab:AddToggle({Name = "Chat spy", Default = State.ChatSpy, Callback = initChatSpy})
utilitiesTab:AddToggle({Name = "Auto-equip tool on spawn", Default = State.AutoEquipTool, Callback = initAutoEquip})
utilitiesTab:AddButton({Name = "Safe reset", Callback = safeReset})
utilitiesTab:AddButton({
    Name = "Rejoin server",
    Callback = function()
        notify("Rejoining", "Teleporting back to place...", 3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
utilitiesTab:AddButton({
    Name = "Server hop (random)",
    Callback = function()
        local serversJson = safeHttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
        if not serversJson then return notify("Server hop", "Failed to fetch server list.", 4) end
        local decoded = nil
        pcall(function() decoded = HttpService:JSONDecode(serversJson) end)
        if not decoded or not decoded.data then return notify("Server hop", "No servers found.", 4) end
        local candidates = {}
        for _, s in ipairs(decoded.data) do
            if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(candidates, s.id)
            end
        end
        if #candidates == 0 then return notify("Server hop", "No suitable servers.", 4) end
        local target = candidates[math.random(1, #candidates)]
        notify("Server hop", "Joining a new server...", 3)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
    end
})

-- Keybind manager (quick actions)
local bindsTab = Window:MakeTab({Name = "Keybinds", Icon = "rbxassetid://4483345998", PremiumOnly = false})
bindsTab:AddBind({
    Name = "Toggle ESP", Default = Enum.KeyCode.KeypadOne, Hold = false,
    Callback = function() State.ESPEnabled = not State.ESPEnabled rebuildESP() notify("ESP", State.ESPEnabled and "Enabled" or "Disabled", 2) end
})
bindsTab:AddBind({
    Name = "Toggle Fly", Default = Enum.KeyCode.KeypadTwo, Hold = false,
    Callback = function() toggleFly(not State.FlyEnabled) notify("Fly", State.FlyEnabled and "Enabled" or "Disabled", 2) end
})
bindsTab:AddBind({
    Name = "Panic cleanup", Default = Enum.KeyCode.P, Hold = false,
    Callback = function()
        -- Thorough cleanup
        disconnectAll(Connections)
        for key, _ in pairs(EspObjects) do
            clearESPFor(key)
        end
        pcall(function() GuiFolder:ClearAllChildren() end)
        notify("Cleanup", "Cleared ESP, GUI, and connections.", 3)
    end
})

-- Theme selector
local themes = {
    ["Dark"] = Color3.fromRGB(20,20,20),
    ["Ocean"] = Color3.fromRGB(10,60,90),
    ["Crimson"] = Color3.fromRGB(90,10,20),
    ["Lime"] = Color3.fromRGB(40,90,40)
}
visualsTab:AddDropdown({
    Name = "Theme", Default = State.Theme, Options = {"Dark","Ocean","Crimson","Lime"},
    Callback = function(val)
        State.Theme = val
        local c = themes[val] or themes["Dark"]
        statsLabel.BackgroundColor3 = c
        FOVStroke.Color = c
    end
})

-- Info
infoTab:AddParagraph("Session info", string.format("PlaceId: %s\nJobId: %s\nPlayers: %d\nVersion: %s", tostring(game.PlaceId), tostring(game.JobId), #Players:GetPlayers(), SCRIPT_VERSION))
infoTab:AddButton({
    Name = "Force rebuild ESP",
    Callback = function() rebuildESP() notify("ESP", "Rebuilt.", 2) end
})
infoTab:AddButton({
    Name = "Check for updates",
    Callback = function()
        local updated = tryAutoUpdate()
        if not updated then notify("Auto-Update", "No updates found.", 3) end
    end
})

-- Initialize defaults and hooks
initAntiAFK()
initAutoRespawn()
rebuildESP()
setWalkSpeed(State.WalkSpeed)
setJumpPower(State.JumpPower)
setFOVVisible(State.FOVCircle)
initChatSpy(State.ChatSpy)
initAutoEquip(State.AutoEquipTool)

notify("Orion Universal", "Loaded successfully. Explore the tabs and customize.", 6)
OrionLib:Init()

-- Optional FPS cap
pcall(function()
    setfpscap and setfpscap(240)
end)

-- Try auto-update silently after init
task.defer(function()
    tryAutoUpdate()
end)
