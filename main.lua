-- XENO HUB RAYFIELD-STYLE UI (FULL REDESIGN)
-- Includes: Player, World, Misc, Combat Tab (ESP/Aimbot/Auto‑Attack)
-- With animations and bug fixes

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
do
    local dragging, startPos, dragStart = false, nil, nil
    title.InputBegan:Connect(function(input)
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
    page.ScrollBarThickness = 6
    page.BackgroundTransparency = 1
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,12)

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

-- Activate Player Tab initially
tabButtons["Player"].BackgroundColor3 = Color3.fromRGB(0,153,255)
tabButtons["Player"].TextColor3 = Color3.fromRGB(255,255,255)
playerTab.Visible = true

-- =========================
-- PLAYER TAB CONTENT
-- =========================
local infJump=false
local humanoid = getHumanoid()

makeSlider(playerTab,"WalkSpeed",8,200,humanoid and humanoid.WalkSpeed or 16,function(v)
    local h=getHumanoid()
    if h then h.WalkSpeed=v end
end)

makeSlider(playerTab,"JumpPower",50,250,humanoid and humanoid.JumpPower or 50,function(v)
    local h=getHumanoid()
    if h then h.JumpPower=v end
end)

makeToggle(playerTab,"Infinite Jump",false,function(state)
    infJump=state
end)

UIS.JumpRequest:Connect(function()
    if infJump then
        local h=getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- =========================
-- WORLD TAB CONTENT
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
end)

-- =========================
-- MISC TAB CONTENT
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
end)

makeToggle(miscTab,"ESP Placeholder",false,function() end)
makeToggle(miscTab,"Auto Farm Placeholder",false,function() end)

-- =========================
-- COMBAT TAB CONTENT
-- =========================
local espBoxes={}
local espEnabled=false
local aimbotEnabled=false
local autoAttack=false

-- ESP Create
local function drawESP(player)
    if player==lp then return end
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
end

local function refreshESP()
    for p,box in pairs(espBoxes) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee=p.Character.HumanoidRootPart
        else
            box:Destroy()
            espBoxes[p]=nil
        end
    end
end

makeToggle(combatTab,"ESP",false,function(s)
    espEnabled=s
    if not espEnabled then
        for _,b in pairs(espBoxes) do b:Destroy() end
        espBoxes={}
    else
        for _,p in pairs(Players:GetPlayers()) do drawESP(p) end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if espEnabled then drawESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    if espBoxes[p] then espBoxes[p]:Destroy() espBoxes[p]=nil end
end)

makeToggle(combatTab,"Aimbot (Hold Right Mouse)",false,function(s) aimbotEnabled=s end)
makeToggle(combatTab,"Auto Attack (Hold E)",false,function(s) autoAttack=s end)

-- =========================
-- CLOSE BUTTON
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

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius=UDim.new(0,12)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Toggle GUI with RightShift
UIS.InputBegan:Connect(function(input,g)
    if not g and input.KeyCode==Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

-- =========================
-- MAIN LOOP
-- =========================
RunService.RenderStepped:Connect(function()
    if espEnabled then refreshESP() end

    if aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest,minDist=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist=(p.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist<minDist then
                    minDist=dist
                    closest=p.Character.HumanoidRootPart
                end
            end
        end
        if closest then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
        end
    end

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
