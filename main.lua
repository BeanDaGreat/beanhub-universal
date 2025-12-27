-- XENO HUB RAYFIELD-STYLE UI (FULL REDESIGN)
-- Includes: Player, World, Misc, Combat, Settings, Checks (ESP/Aimbot/Auto‑Attack, Hitbox Expander)
-- With animations, QoL features, aimbot customization, scrolling, mouse-wheel support, and notifications
-- BEAN HUB v2

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
if not lp then return end
local playerGui = lp:WaitForChild("PlayerGui")

-- SAFE HUMANOID
-- Safe humanoid getter
local function getHumanoid()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        return lp.Character.Humanoid
    if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        return lp.Character:FindFirstChildOfClass("Humanoid")
end
return nil
end

-- =========================
-- NOTIFICATIONS
-- LOADING SCREEN (polished)
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
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "BeanHubLoading"
loadingGui.ResetOnSpawn = false
loadingGui.Parent = playerGui

local loadRoot = Instance.new("Frame", loadingGui)
loadRoot.Size = UDim2.new(1,0,1,0)
loadRoot.Position = UDim2.new(0,0,0,0)
loadRoot.BackgroundColor3 = Color3.fromRGB(6,6,10)
loadRoot.BorderSizePixel = 0

local logo = Instance.new("TextLabel", loadRoot)
logo.Size = UDim2.new(0, 420, 0, 84)
logo.Position = UDim2.new(0.5, -210, 0.42, -42)
logo.BackgroundTransparency = 1
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 36
logo.TextColor3 = Color3.fromRGB(0,153,255)
logo.Text = "BEAN HUB"
logo.TextTransparency = 1

local subtitle = Instance.new("TextLabel", loadRoot)
subtitle.Size = UDim2.new(0, 480, 0, 24)
subtitle.Position = UDim2.new(0.5, -240, 0.42, 36)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(200,200,200)
subtitle.Text = "Preparing interface..."
subtitle.TextTransparency = 1

local progressBg = Instance.new("Frame", loadRoot)
progressBg.Size = UDim2.new(0, 480, 0, 12)
progressBg.Position = UDim2.new(0.5, -240, 0.5, 22)
progressBg.BackgroundColor3 = Color3.fromRGB(24,24,24)
progressBg.BorderSizePixel = 0
local progressBgCorner = Instance.new("UICorner", progressBg)
progressBgCorner.CornerRadius = UDim.new(0, 8)

local progressFill = Instance.new("Frame", progressBg)
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Position = UDim2.new(0,0,0,0)
progressFill.BackgroundColor3 = Color3.fromRGB(0,153,255)
local progressFillCorner = Instance.new("UICorner", progressFill)
progressFillCorner.CornerRadius = UDim.new(0, 8)

-- subtle animated background
local bgAccent = Instance.new("Frame", loadRoot)
bgAccent.Size = UDim2.new(1,0,1,0)
bgAccent.BackgroundColor3 = Color3.fromRGB(10,6,18)
bgAccent.BorderSizePixel = 0
bgAccent.ZIndex = 0
bgAccent.BackgroundTransparency = 0.9

local function runLoading()
    TweenService:Create(logo, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

    local steps = {
        {pct = 0.18, text = "Loading interface..."},
        {pct = 0.45, text = "Applying styles..."},
        {pct = 0.72, text = "Initializing features..."},
        {pct = 0.92, text = "Finalizing..."},
        {pct = 1.00, text = "Ready!"}
    }
    for _, step in ipairs(steps) do
        local target = step.pct * progressBg.AbsoluteSize.X
        pcall(function()
            progressFill:TweenSize(UDim2.new(0, target, 1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.7, true)
        end)
        subtitle.Text = step.text
        task.wait(0.85)
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
    task.wait(0.25)
    TweenService:Create(loadRoot, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    TweenService:Create(logo, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    task.wait(0.45)
    pcall(function() loadingGui:Destroy() end)
end

spawn(runLoading)

-- =========================
-- UI CREATION
-- MAIN GUI (polished)
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "BeanHubGUI"
gui.Name = "BeanHubUI"
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
local window = Instance.new("Frame", gui)
window.Name = "Window"
window.Size = UDim2.new(0, 720, 0, 520)
window.Position = UDim2.new(0.5, 0, 0.5, 0) -- will be centered precisely later
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(20,20,22)
window.BorderSizePixel = 0
window.Visible = false
local windowCorner = Instance.new("UICorner", window)
windowCorner.CornerRadius = UDim.new(0, 16)

-- subtle shadow (Frame behind window)
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
shadow.ZIndex = 0
window.ZIndex = 1

-- top bar (draggable)
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1,0,0,64)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = Color3.fromRGB(12,12,14)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 16)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.02, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(0,153,255)
titleLabel.Text = "BEAN HUB"
titleLabel.ZIndex = 3

local versionLabel = Instance.new("TextLabel", topBar)
versionLabel.Size = UDim2.new(0.36, -12, 1, 0)
versionLabel.Position = UDim2.new(0.62, 6, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 14
versionLabel.TextColor3 = Color3.fromRGB(170,170,170)
versionLabel.TextXAlignment = Enum.TextXAlignment.Right
versionLabel.Text = "v1.0"
versionLabel.ZIndex = 3

-- close button (polished)
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
closeBtn.ZIndex = 3

-- left tabs column
local tabsFrame = Instance.new("Frame", window)
tabsFrame.Size = UDim2.new(0, 180, 1, -64)
tabsFrame.Position = UDim2.new(0, 0, 0, 64)
tabsFrame.BackgroundTransparency = 1
tabsFrame.ZIndex = 2

local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0,8)
tabsLayout.Padding = UDim.new(0, 12)

local pagesFrame = Instance.new("Frame", main)
pagesFrame.Size = UDim2.new(1, -160, 1, -50)
pagesFrame.Position = UDim2.new(0,160,0,50)
-- pages container
local pagesFrame = Instance.new("Frame", window)
pagesFrame.Size = UDim2.new(1, -200, 1, -96)
pagesFrame.Position = UDim2.new(0, 200, 0, 72)
pagesFrame.BackgroundTransparency = 1

local tabButtons, pages = {}, {}
pagesFrame.ZIndex = 2

-- status bar
local statusBar = Instance.new("Frame", window)
statusBar.Size = UDim2.new(1, -24, 0, 36)
statusBar.Position = UDim2.new(0, 12, 1, -44)
statusBar.BackgroundTransparency = 1
statusBar.ZIndex = 2

local statusLabel = Instance.new("TextLabel", statusBar)
statusLabel.Size = UDim2.new(1,0,1,0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(170,170,170)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Ready"
statusLabel.ZIndex = 2

-- helpers
local tabButtons = {}
local pages = {}
local currentTab = nil

-- createTab with proper scrolling support
-- createTab with polished button style
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 17
    local btn = Instance.new("TextButton", tabsFrame)
    btn.Size = UDim2.new(1, -12, 0, 48)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,30)
btn.BorderSizePixel = 0
    btn.Parent = tabsFrame

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,10)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(210,210,210)
    btn.Text = name
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    btn.ZIndex = 2

local page = Instance.new("ScrollingFrame", pagesFrame)
page.Size = UDim2.new(1,0,1,0)
page.Position = UDim2.new(0,0,0,0)
page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.ScrollBarThickness = 8
page.BackgroundTransparency = 1
page.Visible = false
page.ScrollingEnabled = true

pcall(function() page.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    page.ZIndex = 2

local layout = Instance.new("UIListLayout", page)
layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,12)

    layout.Padding = UDim.new(0, 12)
local function updateCanvas()
local contentSize = layout.AbsoluteContentSize
page.CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y + 12)
end

updateCanvas()
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    tabButtons[name] = btn
    pages[name] = page
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34,34,36)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= page then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28,28,30)}):Play()
        end
    end)

btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        page.Visible = true
        currentTab = page
        -- Highlight
        for _,b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(50,50,50)
            b.TextColor3 = Color3.fromRGB(230,230,230)
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(28,28,30)
            b.TextColor3 = Color3.fromRGB(210,210,210)
end
btn.BackgroundColor3 = Color3.fromRGB(0,153,255)
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

-- =========================
-- UI ELEMENT HELPERS
-- =========================
-- UI element builders (polished)
local function makeDivider(parent)
    local div = Instance.new("Frame")
    local div = Instance.new("Frame", parent)
div.Size = UDim2.new(1, -20, 0, 2)
div.Position = UDim2.new(0, 10, 0, 0)
    div.BackgroundColor3 = Color3.fromRGB(70,70,70)
    div.BackgroundColor3 = Color3.fromRGB(40,40,42)
div.BorderSizePixel = 0
    div.Parent = parent
    local c = Instance.new("UICorner", div)
    c.CornerRadius = UDim.new(0, 4)
    div.ZIndex = 2
return div
end

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
    frame.Size = UDim2.new(1, -20, 0, 40)
frame.BackgroundTransparency = 1
    frame.ZIndex = 2

local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-70,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235,235,235)
label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.TextSize = 15
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = text
label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2

local toggleBg = Instance.new("Frame", frame)
    toggleBg.Size = UDim2.new(0,50,0,24)
    toggleBg.Position = UDim2.new(1,-60,0,8)
    toggleBg.BackgroundColor3 = Color3.fromRGB(70,70,70)
    toggleBg.Size = UDim2.new(0, 52, 0, 26)
    toggleBg.Position = UDim2.new(1, -72, 0, 7)
    toggleBg.BackgroundColor3 = Color3.fromRGB(36,36,38)
toggleBg.BorderSizePixel = 0

local bgCorner = Instance.new("UICorner", toggleBg)
    bgCorner.CornerRadius = UDim.new(0,12)

    local circle = Instance.new("Frame", toggleBg)
    circle.Size = UDim2.new(0,20,0,20)
    circle.Position = UDim2.new(default and 1 or 0, default and -22 or 2, 0, 2)
    circle.BackgroundColor3 = Color3.fromRGB(235,235,235)
    circle.BorderSizePixel = 0
    bgCorner.CornerRadius = UDim.new(0, 14)
    toggleBg.ZIndex = 2

    local circCorner = Instance.new("UICorner", circle)
    circCorner.CornerRadius = UDim.new(0,10)
    local knob = Instance.new("Frame", toggleBg)
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = default and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(0, 12)
    knob.ZIndex = 3

local toggled = default
    local function animate()
    local function setState(state)
        toggled = state
if toggled then
            toggleBg.BackgroundColor3 = Color3.fromRGB(0,153,255)
            circle:TweenPosition(UDim2.new(1,-22,0,2),
                Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
            TweenService:Create(toggleBg, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,153,255)}):Play()
            knob:TweenPosition(UDim2.new(1, -24, 0, 2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.18, true)
else
            toggleBg.BackgroundColor3 = Color3.fromRGB(70,70,70)
            circle:TweenPosition(UDim2.new(0,2,0,2),
                Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
            TweenService:Create(toggleBg, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(36,36,38)}):Play()
            knob:TweenPosition(UDim2.new(0, 2, 0, 2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.18, true)
end
        pcall(callback, toggled)
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
    toggleBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then setState(not toggled) end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then setState(not toggled) end
    end)

    animate()
makeDivider(parent)
return frame
end

local function makeSlider(parent, text, min, max, default, callback)
local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-20,0,60)
    frame.Size = UDim2.new(1, -20, 0, 64)
frame.BackgroundTransparency = 1
    frame.ZIndex = 2

local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,-20,0,20)
    label.Position = UDim2.new(0,10,0,0)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(235,235,235)
label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = text .. ": " .. tostring(default)
label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2

local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,-40,0,14)
    bar.Position = UDim2.new(0,20,0,38)
    bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
    bar.Size = UDim2.new(1, -40, 0, 14)
    bar.Position = UDim2.new(0, 20, 0, 36)
    bar.BackgroundColor3 = Color3.fromRGB(36,36,38)
bar.BorderSizePixel = 0

local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0,7)
    barCorner.CornerRadius = UDim.new(0, 8)
    bar.ZIndex = 2

local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    local pct = (default - min) / math.max(1, (max - min))
    fill.Size = UDim2.new(pct, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0,153,255)
    fill.BorderSizePixel = 0

local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0,7)
    fillCorner.CornerRadius = UDim.new(0, 8)
    fill.ZIndex = 3

    local down=false
    local dragging = false
bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            down = true
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            down = false
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
bar.InputChanged:Connect(function(input)
        if down and input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local pos = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
local percent = pos / bar.AbsoluteSize.X
            fill:TweenSize(UDim2.new(percent,0,1,0),
                Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.15, true)
            local value = math.floor(min + (max-min)*percent)
            label.Text = text..": "..tostring(value)
            callback(value)
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
    frame.ZIndex = 2

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(34,34,36)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Text = text
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    btn.ZIndex = 3

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
    duration = duration or 2.5
    local notif = Instance.new("Frame", gui)
    notif.Size = UDim2.new(0, 360, 0, 44)
    notif.AnchorPoint = Vector2.new(1, 0)
    notif.Position = UDim2.new(1, -12, 0, 12)
    notif.BackgroundColor3 = Color3.fromRGB(28,28,30)
    notif.BorderSizePixel = 0
    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 10)
    notif.ZIndex = 5

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6

    local offset = 0
    for _, v in ipairs(activeNotifs) do offset = offset + (v.AbsoluteSize.Y + 8) end
    notif.Position = notif.Position + UDim2.new(0, 0, 0, offset)
    table.insert(activeNotifs, notif)

    notif.BackgroundTransparency = 1
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
-- SETUP TABS
-- Tabs creation
-- =========================
local playerTab = createTab("Player")
local worldTab = createTab("World")
@@ -387,308 +512,213 @@ local combatTab = createTab("Combat")
local checksTab = createTab("Checks")
local settingsTab = createTab("Settings")

-- Activate Player Tab initially
-- default active tab
tabButtons["Player"].BackgroundColor3 = Color3.fromRGB(0,153,255)
tabButtons["Player"].TextColor3 = Color3.fromRGB(255,255,255)
playerTab.Visible = true
currentTab = playerTab

-- =========================
-- PLAYER TAB CONTENT (QoL)
-- Player tab content (QoL)
-- =========================
local infJump=false
local humanoid = getHumanoid()

makeSlider(playerTab,"WalkSpeed",8,200,humanoid and humanoid.WalkSpeed or 16,function(v)
    local h=getHumanoid()
    if h then h.WalkSpeed=v end
    notify("WalkSpeed set to "..tostring(v), 1.6)
local infJump = false
makeSlider(playerTab, "WalkSpeed", 8, 200, (getHumanoid() and getHumanoid().WalkSpeed) or 16, function(v)
    local h = getHumanoid()
    if h then h.WalkSpeed = v end
    notify("WalkSpeed set to "..tostring(v), 1.4)
end)

makeSlider(playerTab,"JumpPower",50,250,humanoid and humanoid.JumpPower or 50,function(v)
    local h=getHumanoid()
    if h then h.JumpPower=v end
    notify("JumpPower set to "..tostring(v), 1.6)
makeSlider(playerTab, "JumpPower", 50, 250, (getHumanoid() and getHumanoid().JumpPower) or 50, function(v)
    local h = getHumanoid()
    if h then h.JumpPower = v end
    notify("JumpPower set to "..tostring(v), 1.4)
end)

makeToggle(playerTab,"Infinite Jump",false,function(state)
    infJump=state
    notify("Infinite Jump "..(state and "enabled" or "disabled"), 1.6)
makeToggle(playerTab, "Infinite Jump", false, function(state)
    infJump = state
    notify("Infinite Jump "..(state and "enabled" or "disabled"), 1.4)
end)

UIS.JumpRequest:Connect(function()
if infJump then
        local h=getHumanoid()
        local h = getHumanoid()
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
    if h then h.WalkSpeed = 16 h.JumpPower = 50 end
    notify("WalkSpeed and JumpPower reset", 1.4)
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
            if char.PrimaryPart then char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0,3,0)) else char:MoveTo(spawn.Position + Vector3.new(0,3,0)) end
else
            if char.PrimaryPart then
                char:SetPrimaryPartCFrame(CFrame.new(0,5,0))
            else
                char:MoveTo(Vector3.new(0,5,0))
            end
            if char.PrimaryPart then char:SetPrimaryPartCFrame(CFrame.new(0,5,0)) else char:MoveTo(Vector3.new(0,5,0)) end
end
        notify("Teleported to spawn", 1.6)
        notify("Teleported to spawn", 1.4)
end
end)

-- =========================
-- WORLD TAB CONTENT (QoL)
-- World tab content
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
makeToggle(worldTab, "FullBright", false, function(state)
    if state then Lighting.Brightness = 3 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 else Lighting.Brightness = 1 Lighting.FogEnd = 1000 end
    notify("FullBright "..(state and "enabled" or "disabled"), 1.4)
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
    if state then Lighting.ClockTime = 14 else Lighting.ClockTime = 0 end
notify("Daytime "..(state and "enabled" or "disabled"), 1.2)
end)

-- =========================
-- MISC TAB CONTENT (QoL)
-- Misc tab content
-- =========================
local afkConn
makeToggle(miscTab,"Anti-AFK",false,function(state)
makeToggle(miscTab, "Anti-AFK", false, function(state)
if state then
afkConn = lp.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
else
        if afkConn then afkConn:Disconnect() afkConn=nil end
        if afkConn then afkConn:Disconnect() afkConn = nil end
end
    notify("Anti-AFK "..(state and "enabled" or "disabled"), 1.6)
    notify("Anti-AFK "..(state and "enabled" or "disabled"), 1.4)
end)

-- QoL: Respawn button
makeButton(miscTab, "Respawn", function()
local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        notify("Respawn triggered", 1.2)
    end
    if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.Health = 0 end end
    notify("Respawn triggered", 1.2)
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
    if state then workspace.CurrentCamera.CameraType = Enum.CameraType.Custom else workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end
notify("Camera lock "..(state and "enabled" or "disabled"), 1.2)
end)

-- =========================
-- COMBAT TAB CONTENT
-- Combat tab content (ESP, Aimbot, Hitbox)
-- =========================
local espBoxes = {}        -- maps player -> {gui = BillboardGui, nameLabel = TextLabel, distLabel = TextLabel, healthBar = Frame}
local espBoxes = {}
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
local hitboxes = {}
local aimbotFOV = 60
local aimbotSmooth = 0.35
local aimbotAimHead = true

-- Create a detailed ESP for a player
local function drawESP(player)
if player == lp then return end
if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
if espBoxes[player] then return end

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
    local hrp = player.Character.HumanoidRootPart
    local gui = Instance.new("BillboardGui", workspace.CurrentCamera)
    gui.Name = "ESPBOX"
    gui.Adornee = hrp
    gui.Size = UDim2.new(0, 160, 0, 80)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2.6, 0)

    local bg = Instance.new("Frame", gui)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 0.28
    bg.BackgroundColor3 = Color3.fromRGB(8,8,8)
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
    local bgc = Instance.new("UICorner", bg)
    bgc.CornerRadius = UDim.new(0,6)

    local name = Instance.new("TextLabel", gui)
    name.Size = UDim2.new(1, -12, 0, 18)
    name.Position = UDim2.new(0, 8, 0, 4)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextColor3 = Color3.fromRGB(255,255,255)
    name.Text = player.Name
    name.TextXAlignment = Enum.TextXAlignment.Left

    local info = Instance.new("TextLabel", gui)
    info.Size = UDim2.new(1, -12, 0, 14)
    info.Position = UDim2.new(0, 8, 0, 24)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(200,200,200)
    info.Text = ""

    local healthBg = Instance.new("Frame", gui)
healthBg.Size = UDim2.new(0.9, 0, 0, 8)
healthBg.Position = UDim2.new(0.05, 0, 1, -14)
    healthBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
    healthBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
healthBg.BorderSizePixel = 0
    local hc = Instance.new("UICorner", healthBg)
    hc.CornerRadius = UDim.new(0,4)

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
    healthFill.Size = UDim2.new(1,0,1,0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
    local hfc = Instance.new("UICorner", healthFill)
    hfc.CornerRadius = UDim.new(0,4)

    espBoxes[player] = {gui = gui, name = name, info = info, healthFill = healthFill}
end

-- Remove ESP for a player
local function removeESP(player)
local data = espBoxes[player]
    if data and data.gui then
        data.gui:Destroy()
    end
    if data and data.gui then data.gui:Destroy() end
espBoxes[player] = nil
end

-- Refresh and update ESP elements (health & distance) — called on a configurable interval
local function refreshESP()
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
            local distText = (dist >= 10) and string.format("%.1f m", dist) or string.format("%.0f m", dist)
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
                local hpPct = math.clamp(hum.Health / maxH, 0, 1)
                data.healthFill.Size = UDim2.new(hpPct, 0, 1, 0)
                if hpPct > 0.6 then data.healthFill.BackgroundColor3 = Color3.fromRGB(0,200,0)
                elseif hpPct > 0.3 then data.healthFill.BackgroundColor3 = Color3.fromRGB(255,200,0)
                else data.healthFill.BackgroundColor3 = Color3.fromRGB(220,50,50) end
                data.info.Text = distText .. "  |  " .. tostring(math.floor(hum.Health)) .. " HP"
else
                data.healthBar.Size = UDim2.new(0,0,1,0)
                data.info.Text = distText
                data.healthFill.Size = UDim2.new(0,0,1,0)
end
else
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
@@ -698,20 +728,15 @@ local function createHitboxForPlayer(player, sizeMultiplier)
hb.Size = Vector3.new(math.max(1, hrp.Size.X * (sizeMultiplier or 2)), math.max(1, hrp.Size.Y * (sizeMultiplier or 2)), math.max(1, hrp.Size.Z * (sizeMultiplier or 2)))
hb.CFrame = hrp.CFrame
hb.Parent = player.Character

    local weld = Instance.new("WeldConstraint")
    local weld = Instance.new("WeldConstraint", hb)
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
    if hb and hb.Parent then hb:Destroy() end
hitboxes[player] = nil
end

@@ -724,69 +749,58 @@ local function updateHitboxForPlayer(player, sizeMultiplier)
end
end

-- Toggle ESP
makeToggle(combatTab,"ESP",false,function(s)
-- Combat controls (UI wiring)
makeToggle(combatTab, "ESP", false, function(s)
espEnabled = s
if not espEnabled then
for p,_ in pairs(espBoxes) do removeESP(p) end
espBoxes = {}
else
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp then drawESP(p) end
        end
        for _, p in pairs(Players:GetPlayers()) do if p ~= lp then drawESP(p) end end
refreshESP()
end
    notify("ESP "..(s and "enabled" or "disabled"), 1.6)
    notify("ESP "..(s and "enabled" or "disabled"), 1.4)
end)

-- Toggle Aimbot and Auto Attack
makeToggle(combatTab,"Aimbot (Hold Right Mouse)",false,function(s)
    aimbotEnabled=s
    notify("Aimbot "..(s and "enabled" or "disabled"), 1.6)
makeToggle(combatTab, "Aimbot (Hold Right Mouse)", false, function(s)
    aimbotEnabled = s
    notify("Aimbot "..(s and "enabled" or "disabled"), 1.4)
end)
makeToggle(combatTab,"Auto Attack (Hold E)",false,function(s)
    autoAttack=s
    notify("Auto Attack "..(s and "enabled" or "disabled"), 1.6)

makeToggle(combatTab, "Auto Attack (Hold E)", false, function(s)
    autoAttack = s
    notify("Auto Attack "..(s and "enabled" or "disabled"), 1.4)
end)

-- Hitbox expander toggle and size slider
local hitboxSize = 2
makeToggle(combatTab,"Hitbox Expander",false,function(s)
makeToggle(combatTab, "Hitbox Expander", false, function(s)
hitboxEnabled = s
if not hitboxEnabled then
for p,_ in pairs(hitboxes) do removeHitboxForPlayer(p) end
hitboxes = {}
else
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp then createHitboxForPlayer(p, hitboxSize) end
        end
        for _, p in pairs(Players:GetPlayers()) do if p ~= lp then createHitboxForPlayer(p, 2) end end
end
    notify("Hitbox Expander "..(s and "enabled" or "disabled"), 1.6)
    notify("Hitbox Expander "..(s and "enabled" or "disabled"), 1.4)
end)

makeSlider(combatTab,"Hitbox Size Multiplier",1,5,2,function(v)
local hitboxSize = 2
makeSlider(combatTab, "Hitbox Size Multiplier", 1, 5, hitboxSize, function(v)
hitboxSize = v
if hitboxEnabled then
        for _,p in pairs(Players:GetPlayers()) do
        for _, p in pairs(Players:GetPlayers()) do
if p ~= lp then
                if hitboxes[p] then
                    updateHitboxForPlayer(p, hitboxSize)
                else
                    createHitboxForPlayer(p, hitboxSize)
                end
                if hitboxes[p] then updateHitboxForPlayer(p, hitboxSize) else createHitboxForPlayer(p, hitboxSize) end
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
@@ -797,150 +811,141 @@ makeToggle(combatTab, "Aim Head (else Torso)", true, function(s)
notify("Aimbot aim target: "..(s and "Head" or "Torso"), 1.2)
end)

-- QoL: Quick target nearest button
makeButton(combatTab, "Target Nearest Player (print name)", function()
local closest, minDist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
    for _, p in pairs(Players:GetPlayers()) do
if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
local dist = (p.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = p
            end
            if dist < minDist then minDist = dist closest = p end
end
end
    if closest then
        notify("Nearest player: "..closest.Name, 1.6)
    else
        notify("No target found", 1.6)
    end
    if closest then notify("Nearest player: "..closest.Name, 1.6) else notify("No target found", 1.6) end
end)

-- =========================
-- CHECKS TAB CONTENT
-- Checks tab content
-- =========================
local wallCheck = false
local teamCheck = false
local downedCheck = false

makeToggle(checksTab, "Wall Check (ignore behind walls)", false, function(s)
wallCheck = s
    notify("Wall Check "..(s and "enabled" or "disabled"), 1.6)
    notify("Wall Check "..(s and "enabled" or "disabled"), 1.4)
end)

makeToggle(checksTab, "Team Check (ignore teammates)", false, function(s)
teamCheck = s
    notify("Team Check "..(s and "enabled" or "disabled"), 1.6)
    notify("Team Check "..(s and "enabled" or "disabled"), 1.4)
end)

makeToggle(checksTab, "Downed Check (ignore downed)", false, function(s)
downedCheck = s
    notify("Downed Check "..(s and "enabled" or "disabled"), 1.6)
    notify("Downed Check "..(s and "enabled" or "disabled"), 1.4)
end)

-- =========================
-- PLAYER join/leave handlers for ESP and Hitbox
-- =========================
Players.PlayerAdded:Connect(function(p)
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
local function isBehindWall(targetPart)
    if not targetPart then return false end
    local cam = workspace.CurrentCamera
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lp.Character, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local origin = cam.CFrame.Position
    local dir = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, dir, params)
    return result ~= nil
end

Players.PlayerRemoving:Connect(function(p)
    if espBoxes[p] then removeESP(p) end
    if hitboxes[p] then removeHitboxForPlayer(p) end
end)
local function isDownedCharacter(char)
    if not char then return false end
    local downedVal = char:FindFirstChild("Downed")
    if downedVal and downedVal:IsA("BoolValue") then return downedVal.Value end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then if hum.Health <= 0 then return true end end
    return false
end

-- =========================
-- SETTINGS TAB (Close button moved here + extras)
-- Settings tab content
-- =========================
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

    makeDivider(container)
end

-- Settings: Lock UI toggle
makeToggle(settingsTab, "Lock UI (disable dragging)", false, function(state)
lockUI = state
notify("UI Lock "..(state and "enabled" or "disabled"), 1.2)
end)

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
    if h then h.WalkSpeed = 16 h.JumpPower = 50 end
notify("Settings restored to defaults", 1.6)
end)

-- Toggle GUI with RightShift
UIS.InputBegan:Connect(function(input,g)
    if not g and input.KeyCode==Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
do
    local closeFrame = Instance.new("Frame", settingsTab)
    closeFrame.Size = UDim2.new(1, -20, 0, 44)
    closeFrame.BackgroundTransparency = 1
    local closeBtn2 = Instance.new("TextButton", closeFrame)
    closeBtn2.Size = UDim2.new(1, 0, 1, 0)
    closeBtn2.BackgroundColor3 = Color3.fromRGB(180,40,40)
    closeBtn2.BorderSizePixel = 0
    closeBtn2.Font = Enum.Font.GothamBold
    closeBtn2.TextSize = 16
    closeBtn2.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn2.Text = "Close GUI"
    local c = Instance.new("UICorner", closeBtn2)
    c.CornerRadius = UDim.new(0, 8)
    closeBtn2.MouseButton1Click:Connect(function() pcall(function() gui:Destroy() end) end)
    makeDivider(settingsTab)
end

-- =========================
-- Player join/leave handlers
-- =========================
Players.PlayerAdded:Connect(function(p)
    if espEnabled and p ~= lp then
        p.CharacterAdded:Connect(function()
            task.wait(0.12)
            if espEnabled then drawESP(p) end
            if hitboxEnabled then createHitboxForPlayer(p, hitboxSize) end
        end)
end
    if hitboxEnabled and p ~= lp then
        p.CharacterAdded:Connect(function()
            task.wait(0.12)
            if hitboxEnabled then createHitboxForPlayer(p, hitboxSize) end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if espBoxes[p] then removeESP(p) end
    if hitboxes[p] then removeHitboxForPlayer(p) end
end)

-- =========================
-- ESP UPDATE LOOP (every espInterval seconds)
-- ESP update loop
-- =========================
task.spawn(function()
    while true do
        if espEnabled then
            pcall(refreshESP)
        end
    while gui.Parent do
        if espEnabled then pcall(refreshESP) end
task.wait(espInterval or 2)
end
end)

-- =========================
-- AIMBOT HELPER FUNCTIONS
-- Aimbot helpers and main loop
-- =========================
local function getAimPartForCharacter(char)
if not char then return nil end
@@ -962,48 +967,10 @@ local function isInFOV(targetPos, fovDeg)
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
    -- Update hitboxes to follow characters (in case of size changes or respawn)
    -- update hitboxes
if hitboxEnabled then
        for p, hb in pairs(hitboxes) do
        for p,_ in pairs(hitboxes) do
if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
updateHitboxForPlayer(p, hitboxSize)
else
@@ -1012,49 +979,29 @@ RunService.RenderStepped:Connect(function()
end
end

    -- Aimbot logic with FOV, smoothness, and checks
    -- aimbot
if aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
local cam = workspace.CurrentCamera
local bestTarget = nil
local bestDist = math.huge

        for _,p in pairs(Players:GetPlayers()) do
        for _, p in pairs(Players:GetPlayers()) do
if p == lp then continue end
if not p.Character or not p.Character.Parent then continue end
local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum then continue end
            if hum.Health <= 0 then continue end
            if not hum or hum.Health <= 0 then continue end

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
                local ok = true
                pcall(function() if lp.Team and p.Team and lp.Team == p.Team then ok = false end end)
                if not ok then continue end
end

            -- Downed check
            if downedCheck then
                if isDownedCharacter(p.Character) then
                    continue
                end
            end
            if downedCheck and isDownedCharacter(p.Character) then continue end

local aimPart = getAimPartForCharacter(p.Character)
if not aimPart then continue end

            -- Wall check
            if wallCheck then
                local blocked = isBehindWall(aimPart)
                if blocked then
                    continue
                end
            end
            if wallCheck and isBehindWall(aimPart) then continue end

local targetPos = aimPart.Position
if isInFOV(targetPos, aimbotFOV) then
@@ -1064,29 +1011,25 @@ RunService.RenderStepped:Connect(function()
local dx = screenPos.X - centerX
local dy = screenPos.Y - centerY
local screenDist = math.sqrt(dx*dx + dy*dy)
                    if screenDist < bestDist then
                        bestDist = screenDist
                        bestTarget = aimPart
                    end
                    if screenDist < bestDist then bestDist = screenDist bestTarget = aimPart end
end
end
end

if bestTarget then
local camPos = cam.CFrame.Position
            local targetPos = bestTarget.Position
            local desired = CFrame.new(camPos, targetPos)
            local desired = CFrame.new(camPos, bestTarget.Position)
local lerpFactor = math.clamp(aimbotSmooth, 0.01, 1)
cam.CFrame = cam.CFrame:Lerp(desired, lerpFactor)
end
end

    -- Auto attack (simple approach)
    -- auto attack
if autoAttack and UIS:IsKeyDown(Enum.KeyCode.E) then
        local char=lp.Character
        local char = lp.Character
if char and char:FindFirstChild("HumanoidRootPart") then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
break
end
@@ -1096,31 +1039,84 @@ RunService.RenderStepped:Connect(function()
end)

-- =========================
-- MOUSE-WHEEL SCROLLING
-- Mouse-wheel scrolling
-- =========================
local scrollSpeed = 50 -- pixels per wheel notch (adjust to taste)
local scrollSpeed = 80
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
        if typeof(page.CanvasSize) == "UDim2" then canvasY = page.CanvasSize.Y.Offset end
local maxY = math.max(0, canvasY - page.AbsoluteSize.Y)

        -- clamp and apply
newY = math.clamp(newY, 0, maxY)
        local ok, err = pcall(function()
            page:TweenCanvasPosition(Vector2.new(0, newY), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.15, true)
        local ok = pcall(function() page:TweenCanvasPosition(Vector2.new(0, newY), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.15, true) end)
        if not ok then page.CanvasPosition = Vector2.new(0, newY) end
    end
end)

-- =========================
-- Draggable top bar (polished)
-- =========================
local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not lockUI then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
end)
        if not ok then
            page.CanvasPosition = Vector2.new(0, newY)
        end
end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        shadow.Position = window.Position + UDim2.new(0, 0, 0, 6)
    end
end)

-- Close button behavior
closeBtn.MouseButton1Click:Connect(function()
    pcall(function() gui:Destroy() end)
end)

-- =========================
-- Show main GUI after loading and center it (polished entrance)
-- =========================
spawn(function()
    while loadingGui.Parent do task.wait(0.05) end

    -- center window and shadow
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.Position = UDim2.new(0.5, 0, 0.5, -36)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = window.Position + UDim2.new(0, 0, 0, 6)

    window.Visible = true
    TweenService:Create(window, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    TweenService:Create(shadow, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 6)}):Play()

    -- subtle pop
    local uiScale = Instance.new("UIScale", window)
    uiScale.Scale = 0.96
    local scaleUp = TweenService:Create(uiScale, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.02})
    local scaleDown = TweenService:Create(uiScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 1})
    scaleUp:Play()
    scaleUp.Completed:Wait()
    scaleDown:Play()

    notify("Bean Hub loaded", 2.0)
end)

-- final safety: ensure currentTab set
if not currentTab then
    currentTab = playerTab
    playerTab.Visible = true
end
