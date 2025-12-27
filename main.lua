-- XENO HUB RAYFIELD-STYLE UI (FULL REDESIGN)
-- Includes: Player, World, Misc, Combat Tab (ESP/Aimbot/Auto‑Attack)
-- With animations and bug fixes
-- Includes: Player, World, Misc, Combat, Settings, Checks (ESP/Aimbot/Auto‑Attack, Hitbox Expander)
-- With animations, QoL features, aimbot customization, scrolling, mouse-wheel support, and notifications

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
if not lp then return end
local playerGui = lp:WaitForChild("PlayerGui")

-- SAFE HUMANOID
local function getHumanoid()
if lp.Character and lp.Character:FindFirstChild("Humanoid") then
return lp.Character.Humanoid
end
return nil
end

-- =========================
-- NOTIFICATIONS
-- =========================
local function notify(text, duration)
    duration = duration or 2.5
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 40)
    notifFrame.Position = UDim2.new(1, -320, 0, 12)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    notifFrame.BorderSizePixel = 0
    notifFrame.AnchorPoint = Vector2.new(0, 0)
    notifFrame.Parent = playerGui

    local corner = Instance.new("UICorner", notifFrame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", notifFrame)
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    notifFrame.BackgroundTransparency = 1
    label.TextTransparency = 1
    -- fade in
    notifFrame:TweenPosition(notifFrame.Position, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.001, true)
    notifFrame:TweenSize(notifFrame.Size, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.001, true)
    for i = 1, 0, -0.1 do
        notifFrame.BackgroundTransparency = i
        label.TextTransparency = i
        task.wait(0.02)
    end
    notifFrame.BackgroundTransparency = 0
    label.TextTransparency = 0

    task.delay(duration, function()
        for i = 0, 1, 0.1 do
            notifFrame.BackgroundTransparency = i
            label.TextTransparency = i
            task.wait(0.02)
        end
        pcall(function() notifFrame:Destroy() end)
    end)
end

-- =========================
-- UI CREATION
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "BeanHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 420)
main.Position = UDim2.new(0.5, -250, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Visible = true
main.Parent = gui

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 16)

-- UI Fade In
main.BackgroundTransparency = 1
task.spawn(function()
for i = 1, 0, -0.1 do
main.BackgroundTransparency = i
task.wait(0.03)
end
main.BackgroundTransparency = 0
end)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "BEAN HUB - UNIVERSAL"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 16)

-- DRAGGING
-- DRAGGING (respects lockUI)
local lockUI = false
do
local dragging, startPos, dragStart = false, nil, nil
title.InputBegan:Connect(function(input)
        if lockUI then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
dragStart = input.Position
startPos = main.Position
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local delta = input.Position - dragStart
main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
end

-- =========================
-- TABS
-- =========================
local tabsFrame = Instance.new("Frame", main)
tabsFrame.Size = UDim2.new(0, 150, 1, -50)
tabsFrame.Position = UDim2.new(0,0,0,50)
tabsFrame.BackgroundTransparency = 1

local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0,8)

local pagesFrame = Instance.new("Frame", main)
pagesFrame.Size = UDim2.new(1, -160, 1, -50)
pagesFrame.Position = UDim2.new(0,160,0,50)
pagesFrame.BackgroundTransparency = 1

local tabButtons, pages = {}, {}
local currentTab = nil

-- createTab with proper scrolling support
local function createTab(name)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
btn.Text = name
btn.TextColor3 = Color3.fromRGB(230,230,230)
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 17
btn.BorderSizePixel = 0
btn.Parent = tabsFrame

local corner = Instance.new("UICorner", btn)
corner.CornerRadius = UDim.new(0,10)

local page = Instance.new("ScrollingFrame", pagesFrame)
page.Size = UDim2.new(1,0,1,0)
page.Position = UDim2.new(0,0,0,0)
    page.CanvasSize = UDim2.new()
    page.CanvasSize = UDim2.new(0,0,0,0)
page.ScrollBarThickness = 6
page.BackgroundTransparency = 1
page.Visible = false
    page.ScrollingEnabled = true

    pcall(function() page.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

local layout = Instance.new("UIListLayout", page)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,12)

    local function updateCanvas()
        local contentSize = layout.AbsoluteContentSize
        page.CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y + 12)
    end

    updateCanvas()
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

tabButtons[name] = btn
pages[name] = page

btn.MouseButton1Click:Connect(function()
for _,p in pairs(pages) do p.Visible = false end
page.Visible = true
currentTab = page
-- Highlight
for _,b in pairs(tabButtons) do
b.BackgroundColor3 = Color3.fromRGB(50,50,50)
b.TextColor3 = Color3.fromRGB(230,230,230)
end
btn.BackgroundColor3 = Color3.fromRGB(0,153,255)
btn.TextColor3 = Color3.fromRGB(255,255,255)
end)

return page
end

-- =========================
-- UI ELEMENT HELPERS
-- =========================
local function makeDivider(parent)
local div = Instance.new("Frame")
div.Size = UDim2.new(1, -20, 0, 2)
div.Position = UDim2.new(0, 10, 0, 0)
div.BackgroundColor3 = Color3.fromRGB(70,70,70)
div.BorderSizePixel = 0
div.Parent = parent
return div
end

-- Toggle with rayfield-like animation
local function makeButton(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-20,0,36)
    frame.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0)
    btn.Position = UDim2.new(0,0,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    makeDivider(parent)
    return frame
end

local function makeToggle(parent, text, default, callback)
local frame = Instance.new("Frame", parent)
frame.Size = UDim2.new(1,-20,0,40)
frame.BackgroundTransparency = 1

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1,-70,1,0)
label.Position = UDim2.new(0,10,0,0)
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = Color3.fromRGB(235,235,235)
label.Font = Enum.Font.Gotham
label.TextSize = 17
label.TextXAlignment = Enum.TextXAlignment.Left

local toggleBg = Instance.new("Frame", frame)
toggleBg.Size = UDim2.new(0,50,0,24)
toggleBg.Position = UDim2.new(1,-60,0,8)
toggleBg.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleBg.BorderSizePixel = 0

local bgCorner = Instance.new("UICorner", toggleBg)
bgCorner.CornerRadius = UDim.new(0,12)

local circle = Instance.new("Frame", toggleBg)
circle.Size = UDim2.new(0,20,0,20)
circle.Position = UDim2.new(default and 1 or 0, default and -22 or 2, 0, 2)
circle.BackgroundColor3 = Color3.fromRGB(235,235,235)
circle.BorderSizePixel = 0

local circCorner = Instance.new("UICorner", circle)
circCorner.CornerRadius = UDim.new(0,10)

local toggled = default
local function animate()
if toggled then
toggleBg.BackgroundColor3 = Color3.fromRGB(0,153,255)
circle:TweenPosition(UDim2.new(1,-22,0,2),
Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
else
toggleBg.BackgroundColor3 = Color3.fromRGB(70,70,70)
circle:TweenPosition(UDim2.new(0,2,0,2),
Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
end
end

local inputFunc = function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
toggled = not toggled
animate()
callback(toggled)
end
end
toggleBg.InputBegan:Connect(inputFunc)
circle.InputBegan:Connect(inputFunc)

animate()
makeDivider(parent)
return frame
end

-- Slider with animation
local function makeSlider(parent, text, min, max, default, callback)
local frame = Instance.new("Frame", parent)
frame.Size = UDim2.new(1,-20,0,60)
frame.BackgroundTransparency = 1

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1,-20,0,20)
label.Position = UDim2.new(0,10,0,0)
label.BackgroundTransparency = 1
label.Text = text .. ": " .. tostring(default)
label.TextColor3 = Color3.fromRGB(235,235,235)
label.Font = Enum.Font.Gotham
label.TextSize = 17
label.TextXAlignment = Enum.TextXAlignment.Left

local bar = Instance.new("Frame", frame)
bar.Size = UDim2.new(1,-40,0,14)
bar.Position = UDim2.new(0,20,0,38)
bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
bar.BorderSizePixel = 0

local barCorner = Instance.new("UICorner", bar)
barCorner.CornerRadius = UDim.new(0,7)

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(0,153,255)
fill.BorderSizePixel = 0

local fillCorner = Instance.new("UICorner", fill)
fillCorner.CornerRadius = UDim.new(0,7)

local down=false
bar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
down = true
end
end)
bar.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
down = false
end
end)
bar.InputChanged:Connect(function(input)
if down and input.UserInputType == Enum.UserInputType.MouseMovement then
local pos = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
local percent = pos / bar.AbsoluteSize.X
fill:TweenSize(UDim2.new(percent,0,1,0),
Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.15, true)
local value = math.floor(min + (max-min)*percent)
label.Text = text..": "..tostring(value)
callback(value)
end
end)

makeDivider(parent)
return frame
end

-- =========================
-- SETUP TABS
-- =========================
local playerTab = createTab("Player")
local worldTab = createTab("World")
local miscTab = createTab("Misc")
local combatTab = createTab("Combat")
local checksTab = createTab("Checks")
local settingsTab = createTab("Settings")

-- Activate Player Tab initially
tabButtons["Player"].BackgroundColor3 = Color3.fromRGB(0,153,255)
tabButtons["Player"].TextColor3 = Color3.fromRGB(255,255,255)
playerTab.Visible = true
currentTab = playerTab

-- =========================
-- PLAYER TAB CONTENT
-- PLAYER TAB CONTENT (QoL)
-- =========================
local infJump=false
local humanoid = getHumanoid()

makeSlider(playerTab,"WalkSpeed",8,200,humanoid and humanoid.WalkSpeed or 16,function(v)
local h=getHumanoid()
if h then h.WalkSpeed=v end
    notify("WalkSpeed set to "..tostring(v), 1.6)
end)

makeSlider(playerTab,"JumpPower",50,250,humanoid and humanoid.JumpPower or 50,function(v)
local h=getHumanoid()
if h then h.JumpPower=v end
    notify("JumpPower set to "..tostring(v), 1.6)
end)

makeToggle(playerTab,"Infinite Jump",false,function(state)
infJump=state
    notify("Infinite Jump "..(state and "enabled" or "disabled"), 1.6)
end)

UIS.JumpRequest:Connect(function()
if infJump then
local h=getHumanoid()
if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end
end)

-- QoL buttons for Player tab
makeButton(playerTab, "Reset Walk/Jump", function()
    local h = getHumanoid()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
        notify("WalkSpeed and JumpPower reset", 1.6)
    end
end)

makeButton(playerTab, "Teleport to Spawn", function()
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
        if spawn and spawn:IsA("BasePart") then
            if char.PrimaryPart then
                char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0,3,0))
            else
                char:MoveTo(spawn.Position + Vector3.new(0,3,0))
            end
        else
            if char.PrimaryPart then
                char:SetPrimaryPartCFrame(CFrame.new(0,5,0))
            else
                char:MoveTo(Vector3.new(0,5,0))
            end
        end
        notify("Teleported to spawn", 1.6)
    end
end)

-- =========================
-- WORLD TAB CONTENT
-- WORLD TAB CONTENT (QoL)
-- =========================
local fullBright=false
makeToggle(worldTab,"FullBright",false,function(state)
fullBright=state
if fullBright then
Lighting.Brightness=3
Lighting.ClockTime=14
Lighting.FogEnd=100000
else
Lighting.Brightness=1
Lighting.FogEnd=1000
end
    notify("FullBright "..(state and "enabled" or "disabled"), 1.6)
end)

-- Add brightness slider and day/night toggle
makeSlider(worldTab, "Brightness", 0, 5, Lighting.Brightness or 1, function(v)
    Lighting.Brightness = v
    notify("Brightness set to "..tostring(v), 1.2)
end)

makeToggle(worldTab, "Daytime (ClockTime 14)", false, function(state)
    if state then
        Lighting.ClockTime = 14
    else
        Lighting.ClockTime = 0
    end
    notify("Daytime "..(state and "enabled" or "disabled"), 1.2)
end)

-- =========================
-- MISC TAB CONTENT
-- MISC TAB CONTENT (QoL)
-- =========================
local afkConn
makeToggle(miscTab,"Anti-AFK",false,function(state)
if state then
afkConn = lp.Idled:Connect(function()
VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
task.wait(1)
VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
else
if afkConn then afkConn:Disconnect() afkConn=nil end
end
    notify("Anti-AFK "..(state and "enabled" or "disabled"), 1.6)
end)

makeToggle(miscTab,"ESP Placeholder",false,function() end)
makeToggle(miscTab,"Auto Farm Placeholder",false,function() end)
-- QoL: Respawn button
makeButton(miscTab, "Respawn", function()
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        notify("Respawn triggered", 1.2)
    end
end)

-- QoL: Toggle camera lock to character (example)
local camLocked = false
makeToggle(miscTab, "Lock Camera to Character", false, function(state)
    camLocked = state
    if camLocked then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    else
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
    notify("Camera lock "..(state and "enabled" or "disabled"), 1.2)
end)

-- =========================
-- COMBAT TAB CONTENT
-- =========================
local espBoxes={}
local espEnabled=false
local aimbotEnabled=false
local autoAttack=false
local espBoxes = {}        -- maps player -> {gui = BillboardGui, nameLabel = TextLabel, distLabel = TextLabel, healthBar = Frame}
local espEnabled = false
local aimbotEnabled = false
local autoAttack = false

-- Hitbox expander state and storage
local hitboxEnabled = false
local hitboxes = {}        -- maps player -> hitboxPart

-- Aimbot settings (customizable)
local aimbotFOV = 60            -- degrees
local aimbotSmooth = 0.35       -- lerp factor (0-1)
local aimbotAimHead = true      -- aim head if available, else HRP

-- Checks (new tab)
local wallCheck = false
local teamCheck = false
local downedCheck = false

-- Helper: safe get character humanoidrootpart
local function getHRP(p)
    if p and p.Character then
        return p.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- ESP Create
-- Create a detailed ESP for a player
local function drawESP(player)
    if player==lp then return end
    if player == lp then return end
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
if espBoxes[player] then return end

    local box=Instance.new("BillboardGui")
    box.Name="ESPBOX"
    box.Adornee=player.Character.HumanoidRootPart
    box.Size=UDim2.new(0,100,0,50)
    box.AlwaysOnTop=true
    box.Parent=workspace.CurrentCamera

    local f=Instance.new("Frame",box)
    f.Size=UDim2.new(1,0,1,0)
    f.BackgroundColor3=Color3.fromRGB(0,153,255)
    f.BackgroundTransparency=0.7
    f.BorderSizePixel=0

    local lbl=Instance.new("TextLabel",box)
    lbl.Size=UDim2.new(1,0,0,20)
    lbl.Position=UDim2.new(0,0,0,-20)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(255,255,255)
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=16
    lbl.Text=player.Name

    espBoxes[player]=box
    local adornee = player.Character.HumanoidRootPart

    local box = Instance.new("BillboardGui")
    box.Name = "ESPBOX"
    box.Adornee = adornee
    box.Size = UDim2.new(0, 140, 0, 70)
    box.AlwaysOnTop = true
    box.StudsOffset = Vector3.new(0, 2.5, 0)
    box.Parent = workspace.CurrentCamera

    -- Background frame
    local bg = Instance.new("Frame", box)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundTransparency = 0.35
    bg.BackgroundColor3 = Color3.fromRGB(10,10,10)
    bg.BorderSizePixel = 0

    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0, 6)

    -- Name label
    local nameLabel = Instance.new("TextLabel", box)
    nameLabel.Size = UDim2.new(1, -8, 0, 18)
    nameLabel.Position = UDim2.new(0, 4, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Distance & HP label
    local distLabel = Instance.new("TextLabel", box)
    distLabel.Size = UDim2.new(1, -8, 0, 14)
    distLabel.Position = UDim2.new(0, 4, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200,200,200)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Text = ""

    -- Health bar background
    local healthBg = Instance.new("Frame", box)
    healthBg.Size = UDim2.new(0.9, 0, 0, 8)
    healthBg.Position = UDim2.new(0.05, 0, 1, -14)
    healthBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
    healthBg.BorderSizePixel = 0

    local healthCorner = Instance.new("UICorner", healthBg)
    healthCorner.CornerRadius = UDim.new(0, 4)

    -- Health fill
    local healthFill = Instance.new("Frame", healthBg)
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    healthFill.BorderSizePixel = 0

    local healthFillCorner = Instance.new("UICorner", healthFill)
    healthFillCorner.CornerRadius = UDim.new(0, 4)

    espBoxes[player] = {
        gui = box,
        nameLabel = nameLabel,
        distLabel = distLabel,
        healthBar = healthFill
    }
end

-- Remove ESP for a player
local function removeESP(player)
    local data = espBoxes[player]
    if data and data.gui then
        data.gui:Destroy()
    end
    espBoxes[player] = nil
end

-- Refresh and update ESP elements (health & distance) — called on a configurable interval
local function refreshESP()
    for p,box in pairs(espBoxes) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee=p.Character.HumanoidRootPart
    for p, data in pairs(espBoxes) do
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            data.gui.Adornee = hrp

            -- Distance
            local camPos = workspace.CurrentCamera.CFrame.Position
            local dist = (hrp.Position - camPos).Magnitude
            if dist >= 10 then
                data.distLabel.Text = string.format("%.1f m", dist)
            else
                data.distLabel.Text = string.format("%.0f m", dist)
            end

            -- Health
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local healthPercent = math.clamp(hum.Health / maxH, 0, 1)
                data.healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                if healthPercent > 0.6 then
                    data.healthBar.BackgroundColor3 = Color3.fromRGB(0,200,0)
                elseif healthPercent > 0.3 then
                    data.healthBar.BackgroundColor3 = Color3.fromRGB(255,200,0)
                else
                    data.healthBar.BackgroundColor3 = Color3.fromRGB(220,50,50)
                end
                data.distLabel.Text = data.distLabel.Text .. "  |  " .. tostring(math.floor(hum.Health)) .. " HP"
            else
                data.healthBar.Size = UDim2.new(0,0,1,0)
            end
else
            box:Destroy()
            espBoxes[p]=nil
            removeESP(p)
end
end
end

-- =========================
-- HITBOX EXPANDER
-- =========================
local function createHitboxForPlayer(player, sizeMultiplier)
    if not player or player == lp then return end
    if hitboxes[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character.HumanoidRootPart
    if not hrp then return end

    local hb = Instance.new("Part")
    hb.Name = "XenoHitbox"
    hb.Transparency = 1
    hb.CanCollide = false
    hb.Anchored = false
    hb.Massless = true
    hb.Size = Vector3.new(math.max(1, hrp.Size.X * (sizeMultiplier or 2)), math.max(1, hrp.Size.Y * (sizeMultiplier or 2)), math.max(1, hrp.Size.Z * (sizeMultiplier or 2)))
    hb.CFrame = hrp.CFrame
    hb.Parent = player.Character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hb
    weld.Part1 = hrp
    weld.Parent = hb

    hitboxes[player] = hb
end

local function removeHitboxForPlayer(player)
    local hb = hitboxes[player]
    if hb and hb.Parent then
        hb:Destroy()
    end
    hitboxes[player] = nil
end

local function updateHitboxForPlayer(player, sizeMultiplier)
    local hb = hitboxes[player]
    if hb and hb.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hb.Size = Vector3.new(math.max(1, hrp.Size.X * (sizeMultiplier or 2)), math.max(1, hrp.Size.Y * (sizeMultiplier or 2)), math.max(1, hrp.Size.Z * (sizeMultiplier or 2)))
        hb.CFrame = hrp.CFrame
    end
end

-- Toggle ESP
makeToggle(combatTab,"ESP",false,function(s)
    espEnabled=s
    espEnabled = s
if not espEnabled then
        for _,b in pairs(espBoxes) do b:Destroy() end
        espBoxes={}
        for p,_ in pairs(espBoxes) do removeESP(p) end
        espBoxes = {}
    else
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp then drawESP(p) end
        end
        refreshESP()
    end
    notify("ESP "..(s and "enabled" or "disabled"), 1.6)
end)

-- Toggle Aimbot and Auto Attack
makeToggle(combatTab,"Aimbot (Hold Right Mouse)",false,function(s)
    aimbotEnabled=s
    notify("Aimbot "..(s and "enabled" or "disabled"), 1.6)
end)
makeToggle(combatTab,"Auto Attack (Hold E)",false,function(s)
    autoAttack=s
    notify("Auto Attack "..(s and "enabled" or "disabled"), 1.6)
end)

-- Hitbox expander toggle and size slider
local hitboxSize = 2
makeToggle(combatTab,"Hitbox Expander",false,function(s)
    hitboxEnabled = s
    if not hitboxEnabled then
        for p,_ in pairs(hitboxes) do removeHitboxForPlayer(p) end
        hitboxes = {}
else
        for _,p in pairs(Players:GetPlayers()) do drawESP(p) end
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp then createHitboxForPlayer(p, hitboxSize) end
        end
end
    notify("Hitbox Expander "..(s and "enabled" or "disabled"), 1.6)
end)

makeSlider(combatTab,"Hitbox Size Multiplier",1,5,2,function(v)
    hitboxSize = v
    if hitboxEnabled then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp then
                if hitboxes[p] then
                    updateHitboxForPlayer(p, hitboxSize)
                else
                    createHitboxForPlayer(p, hitboxSize)
                end
            end
        end
    end
    notify("Hitbox size set to "..tostring(v).."x", 1.2)
end)

-- Aimbot customization controls in Combat tab
makeSlider(combatTab, "Aimbot FOV (deg)", 5, 180, aimbotFOV, function(v)
    aimbotFOV = v
    notify("Aimbot FOV set to "..tostring(v).."°", 1.2)
end)

-- Smoothness slider: map 1..100 to 0.01..1.0
makeSlider(combatTab, "Aimbot Smoothness (1-100)", 1, 100, math.floor(aimbotSmooth*100), function(v)
    aimbotSmooth = math.clamp(v / 100, 0.01, 1)
    notify("Aimbot smoothness set to "..tostring(v), 1.2)
end)

makeToggle(combatTab, "Aim Head (else Torso)", true, function(s)
    aimbotAimHead = s
    notify("Aimbot aim target: "..(s and "Head" or "Torso"), 1.2)
end)

-- QoL: Quick target nearest button
makeButton(combatTab, "Target Nearest Player (print name)", function()
    local closest, minDist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = p
            end
        end
    end
    if closest then
        notify("Nearest player: "..closest.Name, 1.6)
    else
        notify("No target found", 1.6)
    end
end)

-- =========================
-- CHECKS TAB CONTENT
-- =========================
makeToggle(checksTab, "Wall Check (ignore behind walls)", false, function(s)
    wallCheck = s
    notify("Wall Check "..(s and "enabled" or "disabled"), 1.6)
end)

makeToggle(checksTab, "Team Check (ignore teammates)", false, function(s)
    teamCheck = s
    notify("Team Check "..(s and "enabled" or "disabled"), 1.6)
end)

makeToggle(checksTab, "Downed Check (ignore downed)", false, function(s)
    downedCheck = s
    notify("Downed Check "..(s and "enabled" or "disabled"), 1.6)
end)

-- =========================
-- PLAYER join/leave handlers for ESP and Hitbox
-- =========================
Players.PlayerAdded:Connect(function(p)
    if espEnabled then drawESP(p) end
    if espEnabled and p ~= lp then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if espEnabled then drawESP(p) end
            if hitboxEnabled then createHitboxForPlayer(p, hitboxSize) end
        end)
    end
    if hitboxEnabled and p ~= lp then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if hitboxEnabled then createHitboxForPlayer(p, hitboxSize) end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if espBoxes[p] then espBoxes[p]:Destroy() espBoxes[p]=nil end
    if espBoxes[p] then removeESP(p) end
    if hitboxes[p] then removeHitboxForPlayer(p) end
end)

makeToggle(combatTab,"Aimbot (Hold Right Mouse)",false,function(s) aimbotEnabled=s end)
makeToggle(combatTab,"Auto Attack (Hold E)",false,function(s) autoAttack=s end)

-- =========================
-- CLOSE BUTTON
-- SETTINGS TAB (Close button moved here + extras)
-- =========================
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,120,0,38)
closeBtn.Position = UDim2.new(1,-140,1,-60)
closeBtn.BackgroundColor3=Color3.fromRGB(180,40,40)
closeBtn.Text="Close GUI"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=18
closeBtn.BorderSizePixel=0
do
    local container = settingsTab
    local btnFrame = Instance.new("Frame", container)
    btnFrame.Size = UDim2.new(1,-20,0,48)
    btnFrame.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", btnFrame)
    closeBtn.Size = UDim2.new(1,0,1,0)
    closeBtn.Position = UDim2.new(0,0,0,0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    closeBtn.Text = "Close GUI"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BorderSizePixel = 0

    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0,12)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius=UDim.new(0,12)
    makeDivider(container)
end

-- Settings: Lock UI toggle
makeToggle(settingsTab, "Lock UI (disable dragging)", false, function(state)
    lockUI = state
    notify("UI Lock "..(state and "enabled" or "disabled"), 1.2)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
-- Settings: Toggle ESP update interval (QoL)
local espInterval = 2
makeSlider(settingsTab, "ESP Update Interval (sec)", 1, 10, espInterval, function(v)
    espInterval = v
    notify("ESP update interval set to "..tostring(v).."s", 1.2)
end)

-- Settings: Restore defaults button
makeButton(settingsTab, "Restore Default Settings", function()
    -- reset aimbot
    aimbotFOV = 60
    aimbotSmooth = 0.35
    aimbotAimHead = true
    -- reset hitbox
    hitboxSize = 2
    -- reset lighting
    Lighting.Brightness = 1
    Lighting.ClockTime = 0
    -- reset player
    local h = getHumanoid()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
    end
    notify("Settings restored to defaults", 1.6)
end)

-- Toggle GUI with RightShift
UIS.InputBegan:Connect(function(input,g)
if not g and input.KeyCode==Enum.KeyCode.RightShift then
main.Visible = not main.Visible
end
end)

-- =========================
-- MAIN LOOP
-- ESP UPDATE LOOP (every espInterval seconds)
-- =========================
task.spawn(function()
    while true do
        if espEnabled then
            pcall(refreshESP)
        end
        task.wait(espInterval or 2)
    end
end)

-- =========================
-- AIMBOT HELPER FUNCTIONS
-- =========================
local function getAimPartForCharacter(char)
    if not char then return nil end
    if aimbotAimHead then
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    end
end

local function isInFOV(targetPos, fovDeg)
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    local dir = (targetPos - camPos)
    if dir.Magnitude == 0 then return false end
    local forward = cam.CFrame.LookVector
    local dot = forward:Dot(dir.Unit)
    local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
    return angle <= fovDeg
end

local function isBehindWall(targetPart)
    -- Raycast from camera to target; if something hits (excluding characters) then target is behind wall
    local cam = workspace.CurrentCamera
    if not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lp.Character, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local origin = cam.CFrame.Position
    local direction = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    -- If raycast hits something, there's an obstruction between camera and target
    return result ~= nil
end

local function isDownedCharacter(char)
    if not char then return false end
    -- Prefer explicit "Downed" BoolValue if present
    local downedVal = char:FindFirstChild("Downed")
    if downedVal and downedVal:IsA("BoolValue") then
        return downedVal.Value
    end
    -- Fallback: humanoid health <= 0 or humanoid state
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Health <= 0 then return true end
        -- Some games use a "Ragdoll" or "Downed" state; we can't detect all, so use health threshold
        if hum.Health < (hum.MaxHealth * 0.15) then
            -- treat very low health as downed optionally; here we don't auto-ignore unless explicit Downed exists
            return false
        end
    end
    return false
end

-- =========================
-- MAIN LOOP (RenderStepped kept for aimbot/autoattack responsiveness)
-- =========================
RunService.RenderStepped:Connect(function()
    if espEnabled then refreshESP() end
    -- Update hitboxes to follow characters (in case of size changes or respawn)
    if hitboxEnabled then
        for p, hb in pairs(hitboxes) do
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                updateHitboxForPlayer(p, hitboxSize)
            else
                removeHitboxForPlayer(p)
            end
        end
    end

    -- Aimbot logic with FOV, smoothness, and checks
if aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest,minDist=nil,math.huge
        local cam = workspace.CurrentCamera
        local bestTarget = nil
        local bestDist = math.huge

for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist=(p.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist<minDist then
                    minDist=dist
                    closest=p.Character.HumanoidRootPart
            if p == lp then continue end
            if not p.Character or not p.Character.Parent then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum then continue end
            if hum.Health <= 0 then continue end

            -- Team check
            if teamCheck then
                local okTeam = true
                pcall(function()
                    if lp.Team and p.Team and lp.Team == p.Team then
                        okTeam = false
                    end
                end)
                if not okTeam then
                    continue
                end
            end

            -- Downed check
            if downedCheck then
                if isDownedCharacter(p.Character) then
                    continue
                end
            end

            local aimPart = getAimPartForCharacter(p.Character)
            if not aimPart then continue end

            -- Wall check
            if wallCheck then
                local blocked = isBehindWall(aimPart)
                if blocked then
                    continue
                end
            end

            local targetPos = aimPart.Position
            if isInFOV(targetPos, aimbotFOV) then
                local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
                if onScreen then
                    local centerX, centerY = cam.ViewportSize.X/2, cam.ViewportSize.Y/2
                    local dx = screenPos.X - centerX
                    local dy = screenPos.Y - centerY
                    local screenDist = math.sqrt(dx*dx + dy*dy)
                    if screenDist < bestDist then
                        bestDist = screenDist
                        bestTarget = aimPart
                    end
end
end
end
        if closest then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)

        if bestTarget then
            local camPos = cam.CFrame.Position
            local targetPos = bestTarget.Position
            local desired = CFrame.new(camPos, targetPos)
            local lerpFactor = math.clamp(aimbotSmooth, 0.01, 1)
            cam.CFrame = cam.CFrame:Lerp(desired, lerpFactor)
end
end

    -- Auto attack (simple approach)
if autoAttack and UIS:IsKeyDown(Enum.KeyCode.E) then
local char=lp.Character
if char and char:FindFirstChild("HumanoidRootPart") then
for _,p in pairs(Players:GetPlayers()) do
if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
break
end
end
end
end
end)

-- =========================
-- MOUSE-WHEEL SCROLLING
-- =========================
local scrollSpeed = 50 -- pixels per wheel notch (adjust to taste)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local page = currentTab
        if not page or not page:IsA("ScrollingFrame") or not page.Visible then return end

        local delta = -input.Position.Z * scrollSpeed
        local newY = page.CanvasPosition.Y + delta

        -- compute max scrollable Y (CanvasSize may be UDim2; handle safely)
        local canvasY = 0
        if typeof(page.CanvasSize) == "UDim2" then
            canvasY = page.CanvasSize.Y.Offset
        end
        local maxY = math.max(0, canvasY - page.AbsoluteSize.Y)

        -- clamp and apply
        newY = math.clamp(newY, 0, maxY)
        local ok, err = pcall(function()
            page:TweenCanvasPosition(Vector2.new(0, newY), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.15, true)
        end)
        if not ok then
            page.CanvasPosition = Vector2.new(0, newY)
        end
    end
end)
