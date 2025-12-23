-- BEAN HUB v2 — Updated: removed loading screen, draggable window, minimize button, theme fixes, robustness improvements
-- Place this LocalScript in StarterPlayerScripts or under PlayerGui

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
if not lp then return end
local playerGui = lp:WaitForChild("PlayerGui")

-- Safe humanoid getter
local function getHumanoid()
    if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        return lp.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- =========================
-- GLOBAL STATE
-- =========================
local espBoxes = {}
local espEnabled = false
local aimbotEnabled = false
local autoAttack = false
local hitboxEnabled = false
local hitboxes = {}
local aimbotFOV = 60
local aimbotSmooth = 0.35
local aimbotAimHead = true

local noclipEnabled = false
local noclipConn = nil

local aimFOVEnabled = false
local fovGui, fovCircle = nil, nil

local silentAimEnabled = false

local hitboxVisualizerEnabled = false
local hitboxVisuals = {}

local minimapEnabled = false
local minimapGui, minimapRoot = nil, nil
local minimapRadius = 100
local minimapScale = 0.6
local minimapUpdateConn = nil

local themes = {
    Dark = {bg = Color3.fromRGB(20,20,22), top = Color3.fromRGB(12,12,14), accent = Color3.fromRGB(0,153,255), text = Color3.fromRGB(230,230,230), panel = Color3.fromRGB(28,28,30)},
    Light = {bg = Color3.fromRGB(240,240,240), top = Color3.fromRGB(220,220,220), accent = Color3.fromRGB(0,120,215), text = Color3.fromRGB(20,20,20), panel = Color3.fromRGB(230,230,230)},
    Neon = {bg = Color3.fromRGB(6,6,10), top = Color3.fromRGB(10,6,18), accent = Color3.fromRGB(255,0,170), text = Color3.fromRGB(255,255,255), panel = Color3.fromRGB(18,18,20)}
}
local currentTheme = "Dark"

local hotkeys = {}

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local mobileGui = nil

-- =========================
-- MAIN GUI (polished)
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "BeanHubUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local window = Instance.new("Frame", gui)
window.Name = "Window"
window.Size = UDim2.new(0, 720, 0, 520)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = themes[currentTheme].bg
window.BorderSizePixel = 0
window.ZIndex = 2
local windowCorner = Instance.new("UICorner", window)
windowCorner.CornerRadius = UDim.new(0, 16)

local shadow = Instance.new("Frame", gui)
shadow.Name = "Shadow"
shadow.Size = UDim2.new(0, 740, 0, 540)
shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.85
shadow.BorderSizePixel = 0
local shadowCorner = Instance.new("UICorner", shadow)
shadowCorner.CornerRadius = UDim.new(0, 18)
shadow.ZIndex = 1

local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1,0,0,64)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = themes[currentTheme].top
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 16)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.02, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 20
titleLabel.TextColor3 = themes[currentTheme].accent
titleLabel.Text = "BEAN HUB"
titleLabel.ZIndex = 4

local versionLabel = Instance.new("TextLabel", topBar)
versionLabel.Size = UDim2.new(0.36, -60, 1, 0)
versionLabel.Position = UDim2.new(0.62, 6, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 14
versionLabel.TextColor3 = themes[currentTheme].text
versionLabel.TextXAlignment = Enum.TextXAlignment.Right
versionLabel.Text = "v1.0"
versionLabel.ZIndex = 4

local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 36, 0, 28)
minimizeBtn.Position = UDim2.new(1, -92, 0, 18)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.Text = "▾"
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 8)
minimizeBtn.ZIndex = 5

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 36, 0, 28)
closeBtn.Position = UDim2.new(1, -46, 0, 18)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Text = "✕"
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)
closeBtn.ZIndex = 5

-- left tabs column
local tabsFrame = Instance.new("Frame", window)
tabsFrame.Size = UDim2.new(0, 180, 1, -64)
tabsFrame.Position = UDim2.new(0, 0, 0, 64)
tabsFrame.BackgroundColor3 = themes[currentTheme].panel
tabsFrame.BorderSizePixel = 0
tabsFrame.ZIndex = 3
local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 12)

-- pages container
local pagesFrame = Instance.new("Frame", window)
pagesFrame.Size = UDim2.new(1, -200, 1, -96)
pagesFrame.Position = UDim2.new(0, 200, 0, 72)
pagesFrame.BackgroundTransparency = 1
pagesFrame.ZIndex = 3

-- status bar
local statusBar = Instance.new("Frame", window)
statusBar.Size = UDim2.new(1, -24, 0, 36)
statusBar.Position = UDim2.new(0, 12, 1, -44)
statusBar.BackgroundTransparency = 1
statusBar.ZIndex = 3

local statusLabel = Instance.new("TextLabel", statusBar)
statusLabel.Size = UDim2.new(1,0,1,0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = themes[currentTheme].text
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Ready"
statusLabel.ZIndex = 3

-- helpers
local tabButtons = {}
local pages = {}
local currentTab = nil

-- createTab with polished button style
local function createTab(name)
    local btn = Instance.new("TextButton", tabsFrame)
    btn.Size = UDim2.new(1, -12, 0, 48)
    btn.BackgroundColor3 = themes[currentTheme].panel
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextColor3 = themes[currentTheme].text
    btn.Text = name
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    btn.ZIndex = 4

    local page = Instance.new("ScrollingFrame", pagesFrame)
    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 8
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollingEnabled = true
    pcall(function() page.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    page.ZIndex = 3

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    local function updateCanvas()
        local contentSize = layout.AbsoluteContentSize
        page.CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y + 12)
    end
    updateCanvas()
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34,34,36)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= page then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = themes[currentTheme].panel}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = themes[currentTheme].panel
            b.TextColor3 = themes[currentTheme].text
        end
        btn.BackgroundColor3 = themes[currentTheme].accent
        btn.TextColor3 = Color3.fromRGB(255,255,255)

        for _, p in pairs(pages) do
            if p ~= page then p.Visible = false end
        end
        page.Visible = true
        currentTab = page
        statusLabel.Text = name .. " tab opened"
        page.CanvasPosition = Vector2.new(0,0)
    end)

    tabButtons[name] = btn
    pages[name] = page
    return page
end

-- UI element builders (polished)
local function makeDivider(parent)
    local div = Instance.new("Frame", parent)
    div.Size = UDim2.new(1, -20, 0, 2)
    div.Position = UDim2.new(0, 10, 0, 0)
    div.BackgroundColor3 = Color3.fromRGB(40,40,42)
    div.BorderSizePixel = 0
    local c = Instance.new("UICorner", div)
    c.CornerRadius = UDim.new(0, 4)
    div.ZIndex = 3
    return div
end

local function isTouchOrMouse(inputType)
    return inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch
end

local function makeToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextColor3 = themes[currentTheme].text
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3

    local toggleBg = Instance.new("Frame", frame)
    toggleBg.Size = UDim2.new(0, 52, 0, 26)
    toggleBg.Position = UDim2.new(1, -72, 0, 7)
    toggleBg.BackgroundColor3 = Color3.fromRGB(36,36,38)
    toggleBg.BorderSizePixel = 0
    local bgCorner = Instance.new("UICorner", toggleBg)
    bgCorner.CornerRadius = UDim.new(0, 14)
    toggleBg.ZIndex = 3

    local knob = Instance.new("Frame", toggleBg)
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = default and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(0, 12)
    knob.ZIndex = 4

    local toggled = default
    local function setState(state)
        toggled = state
        if toggled then
            TweenService:Create(toggleBg, TweenInfo.new(0.18), {BackgroundColor3 = themes[currentTheme].accent}):Play()
            knob:TweenPosition(UDim2.new(1, -24, 0, 2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.18, true)
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(36,36,38)}):Play()
            knob:TweenPosition(UDim2.new(0, 2, 0, 2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.18, true)
        end
        pcall(callback, toggled)
    end

    toggleBg.InputBegan:Connect(function(input)
        if isTouchOrMouse(input.UserInputType) then setState(not toggled) end
    end)
    knob.InputBegan:Connect(function(input)
        if isTouchOrMouse(input.UserInputType) then setState(not toggled) end
    end)

    makeDivider(parent)
    return frame
end

local function makeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 64)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = themes[currentTheme].text
    label.Text = text .. ": " .. tostring(default)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -40, 0, 14)
    bar.Position = UDim2.new(0, 20, 0, 36)
    bar.BackgroundColor3 = Color3.fromRGB(36,36,38)
    bar.BorderSizePixel = 0
    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0, 8)
    bar.ZIndex = 3

    local fill = Instance.new("Frame", bar)
    local pct = 0
    if max > min then pct = (default - min) / (max - min) end
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = themes[currentTheme].accent
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 8)
    fill.ZIndex = 4

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if isTouchOrMouse(input.UserInputType) then dragging = true end
    end)
    bar.InputEnded:Connect(function(input)
        if isTouchOrMouse(input.UserInputType) then dragging = false end
    end)
    bar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
            local percent = 0
            if bar.AbsoluteSize.X > 0 then percent = pos / bar.AbsoluteSize.X end
            fill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.12, true)
            local value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. tostring(value)
            pcall(callback, value)
        end
    end)

    makeDivider(parent)
    return frame
end

local function makeButton(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(34,34,36)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.TextColor3 = themes[currentTheme].text
    btn.Text = text
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    btn.ZIndex = 4

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(40,40,42)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34,34,36)}):Play()
    end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)

    makeDivider(parent)
    return frame
end

-- Notification system (polished)
local activeNotifs = {}
local function notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame", gui)
    notif.Size = UDim2.new(0, 360, 0, 44)
    notif.AnchorPoint = Vector2.new(1, 0)
    notif.Position = UDim2.new(1, -12, 0, 12)
    notif.BackgroundColor3 = themes[currentTheme].panel
    notif.BorderSizePixel = 0
    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 10)
    notif.ZIndex = 6

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = themes[currentTheme].text
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7

    local offset = 0
    for _, v in ipairs(activeNotifs) do offset = offset + (v.AbsoluteSize.Y + 8) end
    notif.Position = notif.Position + UDim2.new(0, 0, 0, offset)
    table.insert(activeNotifs, notif)

    notif.BackgroundTransparency = 0.5
    label.TextTransparency = 1
    TweenService:Create(notif, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    TweenService:Create(label, TweenInfo.new(0.18), {TextTransparency = 0}):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
        task.wait(0.18)
        for i, v in ipairs(activeNotifs) do
            if v == notif then table.remove(activeNotifs, i) break end
        end
        for idx, v in ipairs(activeNotifs) do
            local targetY = 12
            for j = 1, idx-1 do targetY = targetY + (activeNotifs[j].AbsoluteSize.Y + 8) end
            pcall(function()
                TweenService:Create(v, TweenInfo.new(0.15), {Position = UDim2.new(1, -12, 0, targetY)}):Play()
            end)
        end
        pcall(function() notif:Destroy() end)
    end)
end

-- =========================
-- Tabs creation
-- =========================
local playerTab = createTab("Player")
local worldTab = createTab("World")
local miscTab = createTab("Misc")
local combatTab = createTab("Combat")
local checksTab = createTab("Checks")
local settingsTab = createTab("Settings")

-- default active tab
tabButtons["Player"].BackgroundColor3 = themes[currentTheme].accent
tabButtons["Player"].TextColor3 = Color3.fromRGB(255,255,255)
playerTab.Visible = true
currentTab = playerTab

-- =========================
-- Player tab content (QoL)
-- =========================
local infJump = false
makeSlider(playerTab, "WalkSpeed", 8, 200, (getHumanoid() and getHumanoid().WalkSpeed) or 16, function(v)
    local h = getHumanoid()
    if h then h.WalkSpeed = v end
    notify("WalkSpeed set to "..tostring(v), 1.4)
end)

makeSlider(playerTab, "JumpPower", 50, 250, (getHumanoid() and getHumanoid().JumpPower) or 50, function(v)
    local h = getHumanoid()
    if h then h.JumpPower = v end
    notify("JumpPower set to "..tostring(v), 1.4)
end)

makeToggle(playerTab, "Infinite Jump", false, function(state)
    infJump = state
    notify("Infinite Jump "..(state and "enabled" or "disabled"), 1.4)
end)

UIS.JumpRequest:Connect(function()
    if infJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

makeButton(playerTab, "Reset Walk/Jump", function()
    local h = getHumanoid()
    if h then h.WalkSpeed = 16 h.JumpPower = 50 end
    notify("WalkSpeed and JumpPower reset", 1.4)
end)

makeButton(playerTab, "Teleport to Spawn", function()
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
        if spawn and spawn:IsA("BasePart") then
            if char.PrimaryPart then char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0,3,0)) else char:MoveTo(spawn.Position + Vector3.new(0,3,0)) end
        else
            if char.PrimaryPart then char:SetPrimaryPartCFrame(CFrame.new(0,5,0)) else char:MoveTo(Vector3.new(0,5,0)) end
        end
        notify("Teleported to spawn", 1.4)
    end
end)

-- No-clip implementation
local function setCharacterNoClip(state)
    local char = lp.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function startNoClip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = lp.Character
        if char and noclipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoClip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    setCharacterNoClip(false)
end

makeToggle(playerTab, "No-clip", false, function(state)
    noclipEnabled = state
    if state then
        setCharacterNoClip(true)
        startNoClip()
    else
        stopNoClip()
    end
    notify("No-clip "..(state and "enabled" or "disabled"), 1.4)
end)

-- =========================
-- World tab content
-- =========================
makeToggle(worldTab, "FullBright", false, function(state)
    if state then Lighting.Brightness = 3 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 else Lighting.Brightness = 1 Lighting.FogEnd = 1000 end
    notify("FullBright "..(state and "enabled" or "disabled"), 1.4)
end)

makeSlider(worldTab, "Brightness", 0, 5, Lighting.Brightness or 1, function(v)
    Lighting.Brightness = v
    notify("Brightness set to "..tostring(v), 1.2)
end)

makeToggle(worldTab, "Daytime ClockTime 14", false, function(state)
    if state then Lighting.ClockTime = 14 else Lighting.ClockTime = 0 end
    notify("Daytime "..(state and "enabled" or "disabled"), 1.2)
end)

-- Minimap implementation
local function createMinimap()
    if minimapGui then return end
    minimapGui = Instance.new("ScreenGui", gui)
    minimapGui.Name = "BeanMinimap"
    minimapRoot = Instance.new("Frame", minimapGui)
    minimapRoot.Size = UDim2.new(0, 160, 0, 160)
    minimapRoot.Position = UDim2.new(1, -180, 0, 20)
    minimapRoot.BackgroundColor3 = themes[currentTheme].panel
    minimapRoot.BorderSizePixel = 0
    local corner = Instance.new("UICorner", minimapRoot)
    corner.CornerRadius = UDim.new(0, 8)
    local centerDot = Instance.new("Frame", minimapRoot)
    centerDot.Size = UDim2.new(0,6,0,6)
    centerDot.Position = UDim2.new(0.5, -3, 0.5, -3)
    centerDot.BackgroundColor3 = themes[currentTheme].accent
    centerDot.BorderSizePixel = 0
    local c2 = Instance.new("UICorner", centerDot)
    c2.CornerRadius = UDim.new(1,0)
end

local function updateMinimap()
    if not minimapRoot then return end
    for _, child in pairs(minimapRoot:GetChildren()) do
        if child.Name == "PlayerDot" then child:Destroy() end
    end
    local myPos = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position
    if not myPos then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local offset = Vector3.new(pos.X - myPos.X, 0, pos.Z - myPos.Z)
            local dist = Vector3.new(offset.X, 0, offset.Z).Magnitude
            if dist <= minimapRadius then
                local px = (offset.X / minimapRadius) * (minimapRoot.AbsoluteSize.X/2) * minimapScale
                local py = (offset.Z / minimapRadius) * (minimapRoot.AbsoluteSize.Y/2) * minimapScale
                local dot = Instance.new("Frame", minimapRoot)
                dot.Name = "PlayerDot"
                dot.Size = UDim2.new(0,6,0,6)
                dot.Position = UDim2.new(0.5, px - 3, 0.5, py - 3)
                dot.BackgroundColor3 = Color3.fromRGB(255,80,80)
                dot.BorderSizePixel = 0
                local dc = Instance.new("UICorner", dot)
                dc.CornerRadius = UDim.new(1,0)
            end
        end
    end
end

makeToggle(worldTab, "Minimap", false, function(s)
    minimapEnabled = s
    if s then
        createMinimap()
        if minimapUpdateConn then minimapUpdateConn:Disconnect() end
        minimapUpdateConn = RunService.Heartbeat:Connect(function(dt) updateMinimap() end)
    else
        if minimapGui then minimapGui:Destroy(); minimapGui = nil minimapRoot = nil end
        if minimapUpdateConn then minimapUpdateConn:Disconnect(); minimapUpdateConn = nil end
    end
    notify("Minimap "..(s and "enabled" or "disabled"), 1.4)
end)

-- =========================
-- Misc tab content
-- =========================
local afkConn
makeToggle(miscTab, "Anti-AFK", false, function(state)
    if state then
        afkConn = lp.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if afkConn then afkConn:Disconnect() afkConn = nil end
    end
    notify("Anti-AFK "..(state and "enabled" or "disabled"), 1.4)
end)

makeButton(miscTab, "Respawn", function()
    local char = lp.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.Health = 0 end end
    notify("Respawn triggered", 1.2)
end)

makeToggle(miscTab, "Lock Camera to Character", false, function(state)
    if state then workspace.CurrentCamera.CameraType = Enum.CameraType.Custom else workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end
    notify("Camera lock "..(state and "enabled" or "disabled"), 1.2)
end)

-- =========================
-- Combat tab content (ESP, Aimbot, Hitbox)
-- =========================
local function drawESP(player)
    if player == lp then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if espBoxes[player] then return end

    local hrp = player.Character.HumanoidRootPart
    local cam = workspace.CurrentCamera
    if not cam then return end

    local guiBill = Instance.new("BillboardGui", cam)
    guiBill.Name = "ESPBOX"
    guiBill.Adornee = hrp
    guiBill.Size = UDim2.new(0, 160, 0, 80)
    guiBill.AlwaysOnTop = true
    guiBill.StudsOffset = Vector3.new(0, 2.6, 0)

    local bg = Instance.new("Frame", guiBill)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 0.28
    bg.BackgroundColor3 = Color3.fromRGB(8,8,8)
    bg.BorderSizePixel = 0
    local bgc = Instance.new("UICorner", bg)
    bgc.CornerRadius = UDim.new(0,6)

    local name = Instance.new("TextLabel", guiBill)
    name.Size = UDim2.new(1, -12, 0, 18)
    name.Position = UDim2.new(0, 8, 0, 4)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextColor3 = Color3.fromRGB(255,255,255)
    name.Text = player.Name
    name.TextXAlignment = Enum.TextXAlignment.Left

    local info = Instance.new("TextLabel", guiBill)
    info.Size = UDim2.new(1, -12, 0, 14)
    info.Position = UDim2.new(0, 8, 0, 24)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(200,200,200)
    info.Text = ""

    local healthBg = Instance.new("Frame", guiBill)
    healthBg.Size = UDim2.new(0.9, 0, 0, 8)
    healthBg.Position = UDim2.new(0.05, 0, 1, -14)
    healthBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    healthBg.BorderSizePixel = 0
    local hc = Instance.new("UICorner", healthBg)
    hc.CornerRadius = UDim.new(0,4)

    local healthFill = Instance.new("Frame", healthBg)
    healthFill.Size = UDim2.new(1,0,1,0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
    local hfc = Instance.new("UICorner", healthFill)
    hfc.CornerRadius = UDim.new(0,4)

    espBoxes[player] = {gui = guiBill, name = name, info = info, healthFill = healthFill}
end

local function removeESP(player)
    local data = espBoxes[player]
    if data and data.gui then data.gui:Destroy() end
    espBoxes[player] = nil
end

local function refreshESP()
    for p, data in pairs(espBoxes) do
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if data.gui then data.gui.Adornee = hrp end
            local cam = workspace.CurrentCamera
            if not cam then continue end
            local dist = (hrp.Position - cam.CFrame.Position).Magnitude
            local distText = (dist >= 10) and string.format("%.1f m", dist) or string.format("%.0f m", dist)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local maxH = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
                local hpPct = math.clamp(hum.Health / maxH, 0, 1)
                data.healthFill.Size = UDim2.new(hpPct, 0, 1, 0)
                if hpPct > 0.6 then data.healthFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
                elseif hpPct > 0.3 then data.healthFill.BackgroundColor3 = Color3.fromRGB(255,200,0)
                else data.healthFill.BackgroundColor3 = Color3.fromRGB(220,50,50) end
                data.info.Text = distText .. "  |  " .. tostring(math.floor(hum.Health)) .. " HP"
            else
                data.info.Text = distText
                data.healthFill.Size = UDim2.new(0,0,1,0)
            end
        else
            removeESP(p)
        end
    end
end

local function createHitboxForPlayer(player, sizeMultiplier)
    if not player or player == lp then return end
    if hitboxes[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local hb = Instance.new("Part")
    hb.Name = "XenoHitbox"
    hb.Transparency = 1
    hb.CanCollide = false
    hb.Anchored = false
    hb.Massless = true
    hb.Size = Vector3.new(math.max(1, hrp.Size.X * (sizeMultiplier or 2)), math.max(1, hrp.Size.Y * (sizeMultiplier or 2)), math.max(1, hrp.Size.Z * (sizeMultiplier or 2)))
    hb.CFrame = hrp.CFrame
    hb.Parent = player.Character
    local weld = Instance.new("WeldConstraint", hb)
    weld.Part0 = hb
    weld.Part1 = hrp
    hitboxes[player] = hb

    if hitboxVisualizerEnabled then
        if hitboxVisuals[player] then hitboxVisuals[player]:Destroy() end
        local adorn = Instance.new("BoxHandleAdornment")
        adorn.Adornee = hb
        adorn.Size = hb.Size
        adorn.Transparency = 0.6
        adorn.Color3 = Color3.fromRGB(255, 100, 100)
        adorn.AlwaysOnTop = true
        adorn.Parent = workspace.CurrentCamera
        hitboxVisuals[player] = adorn
    end
end

local function removeHitboxForPlayer(player)
    local hb = hitboxes[player]
    if hb and hb.Parent then hb:Destroy() end
    hitboxes[player] = nil
    if hitboxVisuals[player] then hitboxVisuals[player]:Destroy() hitboxVisuals[player] = nil end
end

local function updateHitboxForPlayer(player, sizeMultiplier)
    local hb = hitboxes[player]
    if hb and hb.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hb.Size = Vector3.new(math.max(1, hrp.Size.X * (sizeMultiplier or 2)), math.max(1, hrp.Size.Y * (sizeMultiplier or 2)), math.max(1, hrp.Size.Z * (sizeMultiplier or 2)))
        hb.CFrame = hrp.CFrame
        if hitboxVisuals[player] then hitboxVisuals[player].Size = hb.Size end
    end
end

-- Combat controls (UI wiring)
makeToggle(combatTab, "ESP", false, function(s)
    espEnabled = s
    if not espEnabled then
        for p,_ in pairs(espBoxes) do removeESP(p) end
        espBoxes = {}
    else
        for _, p in pairs(Players:GetPlayers()) do if p ~= lp then drawESP(p) end end
        refreshESP()
    end
    notify("ESP "..(s and "enabled" or "disabled"), 1.4)
end)

makeToggle(combatTab, "Aimbot (Hold Right Mouse)", false, function(s)
    aimbotEnabled = s
    notify("Aimbot "..(s and "enabled" or "disabled"), 1.4)
end)

makeToggle(combatTab, "Auto Attack (Hold E)", false, function(s)
    autoAttack = s
    notify("Auto Attack "..(s and "enabled" or "disabled"), 1.4)
end)

makeToggle(combatTab, "Hitbox Expander", false, function(s)
    hitboxEnabled = s
    if not hitboxEnabled then
        for p,_ in pairs(hitboxes) do removeHitboxForPlayer(p) end
        hitboxes = {}
    else
        for _, p in pairs(Players:GetPlayers()) do if p ~= lp then createHitboxForPlayer(p, 2) end end
    end
    notify("Hitbox Expander "..(s and "enabled" or "disabled"), 1.4)
end)

local hitboxSize = 2
makeSlider(combatTab, "Hitbox Size Multiplier", 1, 5, hitboxSize, function(v)
    hitboxSize = v
    if hitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp then
                if hitboxes[p] then updateHitboxForPlayer(p, hitboxSize) else createHitboxForPlayer(p, hitboxSize) end
            end
        end
    end
    notify("Hitbox size set to "..tostring(v).."x", 1.2)
end)

makeToggle(combatTab, "Show Hitbox Visuals", false, function(s)
    hitboxVisualizerEnabled = s
    if not s then
        for _, v in pairs(hitboxVisuals) do pcall(function() v:Destroy() end) end
        hitboxVisuals = {}
    else
        for p,_ in pairs(hitboxes) do
            if hitboxes[p] then
                if hitboxVisuals[p] then hitboxVisuals[p]:Destroy() end
                local hb = hitboxes[p]
                local adorn = Instance.new("BoxHandleAdornment")
                adorn.Adornee = hb
                adorn.Size = hb.Size
                adorn.Transparency = 0.6
                adorn.Color3 = Color3.fromRGB(255, 100, 100)
                adorn.AlwaysOnTop = true
                adorn.Parent = workspace.CurrentCamera
                hitboxVisuals[p] = adorn
            end
        end
    end
    notify("Hitbox visualizer "..(s and "enabled" or "disabled"), 1.4)
end)

-- Aim FOV visualizer
local function createFOVGui()
    if fovGui then return end
    fovGui = Instance.new("ScreenGui", gui)
    fovGui.Name = "AimFOVGui"
    fovGui.ResetOnSpawn = false
    fovCircle = Instance.new("Frame", fovGui)
    fovCircle.Size = UDim2.new(0, 0, 0, 0)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    local circ = Instance.new("UICorner", fovCircle)
    circ.CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", fovCircle)
    stroke.Color = themes[currentTheme].accent
    stroke.Thickness = 2
end

local function updateFOVGui()
    if not fovCircle then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local screenY = cam.ViewportSize.Y
    local pixelRadius = (aimbotFOV / math.max(1, cam.FieldOfView)) * (screenY * 0.35)
    fovCircle.Size = UDim2.new(0, math.floor(pixelRadius*2), 0, math.floor(pixelRadius*2))
end

makeSlider(combatTab, "Aimbot FOV", 10, 180, aimbotFOV, function(v)
    aimbotFOV = v
    updateFOVGui()
    notify("Aimbot FOV set to "..tostring(v), 1.2)
end)

makeToggle(combatTab, "Show Aim FOV", false, function(s)
    aimFOVEnabled = s
    if s then createFOVGui(); updateFOVGui() else if fovGui then fovGui:Destroy(); fovGui = nil fovCircle = nil end end
    notify("Aim FOV visualizer "..(s and "enabled" or "disabled"), 1.2)
end)

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateFOVGui)
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFOVGui)
end

-- Silent Aim (target selection only)
local function isInFOV(screenPos, fovPixels)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local center = cam.ViewportSize/2
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return dist <= fovPixels
end

local function getSilentAimTarget()
    if not silentAimEnabled then return nil end
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local best, bestDist = nil, math.huge
    local screenCenter = cam.ViewportSize/2
    local fovPixels = (aimbotFOV / math.max(1, cam.FieldOfView)) * (cam.ViewportSize.Y * 0.35)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = (aimbotAimHead and p.Character:FindFirstChild("Head")) or p.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                if onScreen and isInFOV(Vector2.new(screenPos.X, screenPos.Y), fovPixels) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < bestDist then bestDist = dist best = {player = p, part = targetPart, pos = targetPart.Position} end
                end
            end
        end
    end
    return best
end

makeToggle(combatTab, "Silent Aim target select only", false, function(s)
    silentAimEnabled = s
    notify("Silent Aim "..(s and "enabled" or "disabled"), 1.4)
end)

-- =========================
-- Settings tab: Theme manager & Hotkey manager & Mobile support
-- =========================
local function applyTheme(name)
    local t = themes[name]
    if not t then return end
    currentTheme = name
    -- core elements
    window.BackgroundColor3 = t.bg
    topBar.BackgroundColor3 = t.top
    titleLabel.TextColor3 = t.accent
    versionLabel.TextColor3 = t.text
    tabsFrame.BackgroundColor3 = t.panel
    if minimapRoot then minimapRoot.BackgroundColor3 = t.panel end
    -- update tab buttons
    for _, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = t.panel
        btn.TextColor3 = t.text
    end
    -- update text colors across GUI for consistency
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            -- keep title accent
            if obj == titleLabel then
                obj.TextColor3 = t.accent
            else
                obj.TextColor3 = t.text
            end
        elseif obj:IsA("Frame") and obj ~= window and obj ~= topBar and obj ~= tabsFrame and obj.Parent == gui then
            -- avoid overriding specialized frames; keep general panels consistent
            obj.BackgroundColor3 = t.panel
        end
    end
    -- update notification style
    for _, v in pairs(activeNotifs) do
        if v and v:IsA("Frame") then
            v.BackgroundColor3 = t.panel
            for _, child in pairs(v:GetChildren()) do
                if child:IsA("TextLabel") then child.TextColor3 = t.text end
            end
        end
    end
    -- update fov stroke color if present
    if fovGui and fovCircle then
        local stroke = fovCircle:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = t.accent end
    end
    notify("Theme set to "..name, 1.2)
end

-- Add theme buttons
makeButton(settingsTab, "Theme: Dark", function() applyTheme("Dark") end)
makeButton(settingsTab, "Theme: Light", function() applyTheme("Light") end)
makeButton(settingsTab, "Theme: Neon", function() applyTheme("Neon") end)
applyTheme(currentTheme)

-- Hotkey manager
local function registerHotkey(action, defaultKey, callback)
    hotkeys[action] = {Key = defaultKey, Callback = callback, TouchButton = nil}
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for action, data in pairs(hotkeys) do
            if input.KeyCode == data.Key then
                pcall(data.Callback)
            end
        end
    end
end)

local function rebindNextKey(action)
    notify("Press a key to bind for "..action, 2)
    local conn
    conn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            hotkeys[action].Key = input.KeyCode
            notify(action.." bound to "..tostring(input.KeyCode), 1.6)
            conn:Disconnect()
        end
    end)
end

-- Example hotkey: Toggle No-clip with N
registerHotkey("ToggleNoClip", Enum.KeyCode.N, function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then setCharacterNoClip(true); startNoClip() else stopNoClip() end
    notify("No-clip "..(noclipEnabled and "enabled" or "disabled"), 1.2)
end)

makeButton(settingsTab, "Rebind ToggleNoClip", function()
    rebindNextKey("ToggleNoClip")
end)

-- Mobile support: on-screen buttons
local function createMobileControls()
    if mobileGui then return end
    mobileGui = Instance.new("ScreenGui", playerGui)
    mobileGui.Name = "MobileControls"
    mobileGui.ResetOnSpawn = false

    local btnSize = UDim2.new(0, 72, 0, 72)
    local function makeMobileButton(name, pos, callback)
        local b = Instance.new("TextButton", mobileGui)
        b.Size = btnSize
        b.Position = pos
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Text = name
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        b.BackgroundColor3 = Color3.fromRGB(34,34,36)
        local c = Instance.new("UICorner", b)
        c.CornerRadius = UDim.new(0, 12)
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                pcall(callback)
            end
        end)
        return b
    end

    makeMobileButton("Aim", UDim2.new(1, -100, 1, -120), function() aimbotEnabled = not aimbotEnabled notify("Aimbot "..(aimbotEnabled and "on" or "off")) end)
    makeMobileButton("Attack", UDim2.new(1, -30, 1, -120), function() autoAttack = not autoAttack notify("Auto Attack "..(autoAttack and "on" or "off")) end)
    makeMobileButton("NoClip", UDim2.new(1, -100, 1, -40), function() noclipEnabled = not noclipEnabled if noclipEnabled then setCharacterNoClip(true); startNoClip() else stopNoClip() end notify("No-clip "..(noclipEnabled and "on" or "off")) end)
end

if isMobile then
    createMobileControls()
    local cam = workspace.CurrentCamera
    if cam then
        window.Size = UDim2.new(0, math.min(720, cam.ViewportSize.X - 40), 0, math.min(520, cam.ViewportSize.Y - 80))
    end
end

-- =========================
-- Dragging and Minimize behavior
-- =========================
local dragging = false
local dragStart = nil
local startPos = nil
local minimized = false
local stored = {Size = window.Size, Position = window.Position, Visible = true}

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function updateDrag(input)
    if not dragging or not dragStart or not startPos then return end
    local delta = input.Position - dragStart
    local newX = startPos.X.Scale + (delta.X / workspace.CurrentCamera.ViewportSize.X)
    local newY = startPos.Y.Scale + (delta.Y / workspace.CurrentCamera.ViewportSize.Y)
    window.Position = UDim2.new(newX, startPos.X.Offset + delta.X, newY, startPos.Y.Offset + delta.Y)
    shadow.Position = UDim2.new(window.Position.X.Scale, window.Position.X.Offset, window.Position.Y.Scale, window.Position.Y.Offset + 6)
end

topBar.InputBegan:Connect(function(input)
    startDrag(input)
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Minimize button behavior
minimizeBtn.MouseButton1Click:Connect(function()
    if minimized then
        -- restore
        window.Size = stored.Size
        window.Position = stored.Position
        shadow.Visible = true
        for _, child in pairs({tabsFrame, pagesFrame, statusBar}) do
            if child then child.Visible = true end
        end
        minimizeBtn.Text = "▾"
        minimized = false
    else
        -- store and minimize
        stored.Size = window.Size
        stored.Position = window.Position
        window.Size = UDim2.new(0, 420, 0, 64)
        window.Position = UDim2.new(window.Position.X.Scale, window.Position.X.Offset, window.Position.Y.Scale, window.Position.Y.Offset)
        shadow.Visible = false
        tabsFrame.Visible = false
        pagesFrame.Visible = false
        statusBar.Visible = false
        minimizeBtn.Text = "▴"
        minimized = true
    end
end)

-- Close button hides UI
closeBtn.MouseButton1Click:Connect(function()
    window.Visible = false
    shadow.Visible = false
end)

-- =========================
-- Runtime updates and housekeeping
-- =========================
-- Player event wiring
local function onPlayerAdded(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        if espEnabled and p ~= lp then drawESP(p) end
        if hitboxEnabled and p ~= lp then createHitboxForPlayer(p, hitboxSize) end
    end)
    p.CharacterRemoving:Connect(function()
        removeESP(p)
        removeHitboxForPlayer(p)
    end)
end

for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    removeHitboxForPlayer(p)
end)

-- Heartbeat updates
local lastMinimap = 0
RunService.Heartbeat:Connect(function(dt)
    if espEnabled then refreshESP() end
    if hitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and hitboxes[p] then updateHitboxForPlayer(p, hitboxSize) end
        end
    end
    if aimFOVEnabled and fovCircle then updateFOVGui() end

    if minimapEnabled and minimapRoot then
        local now = tick()
        if now - lastMinimap > 0.12 then
            updateMinimap()
            lastMinimap = now
        end
    end
end)

-- Ensure noclip persists on respawn if enabled
lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if noclipEnabled then setCharacterNoClip(true) end
end)

-- Show window by default
window.Visible = true
shadow.Visible = true

-- Final note: getSilentAimTarget returns a local target table only.
-- Use responsibly and only in permitted testing environments.

-- End of script
