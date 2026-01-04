--[[
    BEAN HUB V2.0 - ULTIMATE EDITION
    Author: Gemini AI
    Design: Modern Dark/Acrylic
    Features: Universal, Config Saving, Deep Theming, Optimized ESP/Aimbot
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // FILESYSTEM & CONFIG //
local ConfigName = "BeanHub_v2_Config.json"
local CurrentConfig = {
    Theme = "Bean Green",
    Keybind = "RightControl",
    WalkSpeed = 16,
    JumpPower = 50,
    Flight = false,
    FlySpeed = 50,
    Aimbot = false,
    AimbotFOV = 100,
    AimbotSmooth = 1,
    ESP_Box = false,
    ESP_Name = false,
    ESP_Tracers = false,
    HitboxExpander = false,
    HitboxSize = 2,
    FullBright = false
}

-- Safe File System Wrapper
local writefile = writefile or function() end
local readfile = readfile or function() end
local isfile = isfile or function() return false end

local function SaveSettings()
    pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(CurrentConfig))
    end)
end

local function LoadSettings()
    if isfile(ConfigName) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigName))
            for k,v in pairs(data) do CurrentConfig[k] = v end
        end)
    end
end
LoadSettings()

-- // THEME ENGINE //
local Themes = {
    ["Bean Green"] = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(75, 220, 100),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150)
    },
    ["Midnight Blue"] = {
        Main = Color3.fromRGB(20, 20, 30),
        Secondary = Color3.fromRGB(30, 30, 45),
        Accent = Color3.fromRGB(80, 140, 255),
        Text = Color3.fromRGB(240, 240, 255),
        TextDark = Color3.fromRGB(120, 120, 160)
    },
    ["Crimson Void"] = {
        Main = Color3.fromRGB(25, 15, 15),
        Secondary = Color3.fromRGB(40, 20, 20),
        Accent = Color3.fromRGB(220, 60, 60),
        Text = Color3.fromRGB(255, 240, 240),
        TextDark = Color3.fromRGB(160, 120, 120)
    },
    ["Royal Purple"] = {
        Main = Color3.fromRGB(25, 20, 30),
        Secondary = Color3.fromRGB(35, 25, 45),
        Accent = Color3.fromRGB(160, 80, 240),
        Text = Color3.fromRGB(250, 240, 255),
        TextDark = Color3.fromRGB(140, 120, 160)
    },
    ["Cotton Candy"] = {
        Main = Color3.fromRGB(35, 30, 35),
        Secondary = Color3.fromRGB(50, 45, 50),
        Accent = Color3.fromRGB(255, 150, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 160, 180)
    },
}

local UI_Registry = {} -- Stores all UI objects to update them dynamically
local CurrentTheme = Themes[CurrentConfig.Theme] or Themes["Bean Green"]

local function UpdateThemes(newThemeName)
    CurrentConfig.Theme = newThemeName
    CurrentTheme = Themes[newThemeName]
    SaveSettings()
    
    for _, item in pairs(UI_Registry) do
        local instance = item.Instance
        local type = item.Type
        
        -- Use Tween for smooth transition
        if type == "Main" then
            TweenService:Create(instance, TweenInfo.new(0.5), {BackgroundColor3 = CurrentTheme.Main}):Play()
        elseif type == "Secondary" then
            TweenService:Create(instance, TweenInfo.new(0.5), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
        elseif type == "Accent" then
            if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                TweenService:Create(instance, TweenInfo.new(0.5), {TextColor3 = CurrentTheme.Accent}):Play()
            else
                TweenService:Create(instance, TweenInfo.new(0.5), {BackgroundColor3 = CurrentTheme.Accent}):Play()
            end
        elseif type == "Text" then
            TweenService:Create(instance, TweenInfo.new(0.5), {TextColor3 = CurrentTheme.Text}):Play()
        elseif type == "TextDark" then
            TweenService:Create(instance, TweenInfo.new(0.5), {TextColor3 = CurrentTheme.TextDark}):Play()
        elseif type == "ImageAccent" then
            TweenService:Create(instance, TweenInfo.new(0.5), {ImageColor3 = CurrentTheme.Accent}):Play()
        end
    end
end

-- // UTILITY FUNCTIONS //
local function AddToRegistry(instance, type)
    table.insert(UI_Registry, {Instance = instance, Type = type})
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

-- // UI LIBRARY //
local Library = {}

function Library:Init()
    -- Cleanup Old UI
    if CoreGui:FindFirstChild("BeanHubV2") then CoreGui.BeanHubV2:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BeanHubV2"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    -- Loading Screen
    local LoadFrame = Instance.new("Frame")
    LoadFrame.Size = UDim2.new(1,0,1,0)
    LoadFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
    LoadFrame.Parent = ScreenGui
    
    local LoadText = Instance.new("TextLabel")
    LoadText.Text = "BEAN HUB"
    LoadText.Size = UDim2.new(1,0,1,0)
    LoadText.BackgroundTransparency = 1
    LoadText.Font = Enum.Font.GothamBold
    LoadText.TextSize = 0
    LoadText.TextColor3 = CurrentTheme.Accent
    LoadText.Parent = LoadFrame
    
    TweenService:Create(LoadText, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextSize = 50}):Play()
    task.wait(1.5)
    TweenService:Create(LoadFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    LoadFrame:Destroy()

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = CurrentTheme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    AddToRegistry(Main, "Main")

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(50,50,50)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = CurrentTheme.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    AddToRegistry(Sidebar, "Secondary")

    local SideCorner = Instance.new("UICorner", Sidebar)
    SideCorner.CornerRadius = UDim.new(0, 8)
    
    local SideFix = Instance.new("Frame", Sidebar)
    SideFix.Size = UDim2.new(0,10,1,0)
    SideFix.Position = UDim2.new(1,-10,0,0)
    SideFix.BackgroundColor3 = CurrentTheme.Secondary
    SideFix.BorderSizePixel = 0
    AddToRegistry(SideFix, "Secondary")

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "BEAN HUB"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 24
    Title.TextColor3 = CurrentTheme.Accent
    Title.Size = UDim2.new(1,0,0,60)
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar
    AddToRegistry(Title, "Accent") -- Use Accent Color for Title

    local Version = Instance.new("TextLabel")
    Version.Text = "v2.0"
    Version.Font = Enum.Font.Gotham
    Version.TextSize = 12
    Version.TextColor3 = CurrentTheme.TextDark
    Version.Position = UDim2.new(0,0,0,40)
    Version.Size = UDim2.new(1,0,0,20)
    Version.BackgroundTransparency = 1
    Version.Parent = Sidebar
    AddToRegistry(Version, "TextDark")

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1,0,1,-70)
    TabContainer.Position = UDim2.new(0,0,0,70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0,5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Content Area
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1,-170,1,-20)
    Pages.Position = UDim2.new(0,165,0,10)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    MakeDraggable(Main, Sidebar)

    -- Toggle UI
    UserInputService.InputBegan:Connect(function(input, g)
        if not g and input.KeyCode == Enum.KeyCode[CurrentConfig.Keybind] then
            Main.Visible = not Main.Visible
        end
    end)

    return {Main = Main, Tabs = TabContainer, Pages = Pages}
end

function Library:CreateTab(Window, name, iconId)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-20,0,35)
    Button.Position = UDim2.new(0,10,0,0)
    Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Button.BackgroundTransparency = 1
    Button.Text = name
    Button.TextColor3 = CurrentTheme.TextDark
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Window.Tabs
    AddToRegistry(Button, "TextDark") -- Default state

    local Padding = Instance.new("UIPadding", Button)
    Padding.PaddingLeft = UDim.new(0,15)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = CurrentTheme.Accent
    Page.Visible = false
    Page.Parent = Window.Pages
    AddToRegistry(Page, "ImageAccent") -- Scrollbar color

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end)

    -- Tab Selection Logic
    Button.MouseButton1Click:Connect(function()
        -- Reset all tabs
        for _, v in pairs(Window.Pages:GetChildren()) do v.Visible = false end
        for _, v in pairs(Window.Tabs:GetChildren()) do 
            if v:IsA("TextButton") then
                TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextDark}):Play()
                -- Temporarily remove from specific registry tracking to manual override
            end
        end
        
        Page.Visible = true
        TweenService:Create(Button, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Accent}):Play()
    end)

    local Elements = {}

    function Elements:CreateSection(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1,0,0,30)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = CurrentTheme.Text
        Label.Font = Enum.Font.GothamBlack
        Label.TextSize = 16
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Page
        AddToRegistry(Label, "Text")
    end

    function Elements:CreateToggle(text, configKey, callback)
        local state = CurrentConfig[configKey] or false
        
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1,-5,0,38)
        Frame.BackgroundColor3 = CurrentTheme.Secondary
        Frame.Parent = Page
        AddToRegistry(Frame, "Secondary")
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7,0,1,0)
        Label.Position = UDim2.new(0,10,0,0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = CurrentTheme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        AddToRegistry(Label, "Text")

        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0,40,0,20)
        SwitchBg.Position = UDim2.new(1,-50,0.5,-10)
        SwitchBg.BackgroundColor3 = state and CurrentTheme.Accent or Color3.fromRGB(60,60,60)
        SwitchBg.Parent = Frame
        Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(0,10)
        
        -- Special registry for toggles (dynamic color)
        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0,16,0,16)
        SwitchDot.Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
        SwitchDot.Parent = SwitchBg
        Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(0,8)

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,0,1,0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.Parent = Frame

        Btn.MouseButton1Click:Connect(function()
            state = not state
            CurrentConfig[configKey] = state
            
            local targetColor = state and CurrentTheme.Accent or Color3.fromRGB(60,60,60)
            local targetPos = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
            
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = targetPos}):Play()
            
            callback(state)
            SaveSettings()
        end)

        -- Allow external theme updates to affect the active state
        table.insert(UI_Registry, {Instance = SwitchBg, Type = "ToggleBG", State = function() return CurrentConfig[configKey] end})
        
        if state then callback(true) end
    end

    function Elements:CreateSlider(text, min, max, configKey, callback)
        local val = CurrentConfig[configKey] or min
        
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1,-5,0,50)
        Frame.BackgroundColor3 = CurrentTheme.Secondary
        Frame.Parent = Page
        AddToRegistry(Frame, "Secondary")
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1,-20,0,20)
        Label.Position = UDim2.new(0,10,0,5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = CurrentTheme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.Parent = Frame
        AddToRegistry(Label, "Text")

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(1,-20,0,20)
        ValLabel.Position = UDim2.new(0,-10,0,5)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Text = tostring(val)
        ValLabel.TextColor3 = CurrentTheme.TextDark
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Font = Enum.Font.Gotham
        ValLabel.TextSize = 14
        ValLabel.Parent = Frame
        AddToRegistry(ValLabel, "TextDark")

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1,-20,0,4)
        Bar.Position = UDim2.new(0,10,0,35)
        Bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Bar.Parent = Frame
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,2)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
        Fill.BackgroundColor3 = CurrentTheme.Accent
        Fill.Parent = Bar
        AddToRegistry(Fill, "Accent")
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,2)

        local Trigger = Instance.new("TextButton")
        Trigger.Size = UDim2.new(1,0,1,0)
        Trigger.BackgroundTransparency = 1
        Trigger.Text = ""
        Trigger.Parent = Frame

        local dragging = false
        Trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false SaveSettings() end end)
        
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max-min)*pct)
                ValLabel.Text = tostring(val)
                Fill.Size = UDim2.new(pct,0,1,0)
                CurrentConfig[configKey] = val
                callback(val)
            end
        end)
    end

    function Elements:CreateDropdown(text, options, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1,-5,0,38)
        Frame.BackgroundColor3 = CurrentTheme.Secondary
        Frame.ClipsDescendants = true
        Frame.Parent = Page
        AddToRegistry(Frame, "Secondary")
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)

        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Size = UDim2.new(1,-40,0,38)
        Label.Position = UDim2.new(0,10,0,0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = CurrentTheme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        AddToRegistry(Label, "Text")

        local Arrow = Instance.new("ImageLabel")
        Arrow.Image = "rbxassetid://6034818372"
        Arrow.Size = UDim2.new(0,20,0,20)
        Arrow.Position = UDim2.new(1,-30,0,9)
        Arrow.BackgroundTransparency = 1
        Arrow.ImageColor3 = CurrentTheme.Text
        Arrow.Parent = Frame
        AddToRegistry(Arrow, "ImageAccent")

        local Trigger = Instance.new("TextButton")
        Trigger.Size = UDim2.new(1,0,0,38)
        Trigger.BackgroundTransparency = 1
        Trigger.Text = ""
        Trigger.Parent = Frame
        
        local open = false
        local height = 38 + (#options * 30)
        
        Trigger.MouseButton1Click:Connect(function()
            open = not open
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1,-5,0, open and height or 38)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = open and 180 or 0}):Play()
        end)

        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1,0,0,30)
            OptBtn.Position = UDim2.new(0,0,0,38 + ((i-1)*30))
            OptBtn.BackgroundColor3 = CurrentTheme.Secondary
            OptBtn.Text = opt
            OptBtn.TextColor3 = CurrentTheme.TextDark
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 14
            OptBtn.Parent = Frame
            AddToRegistry(OptBtn, "TextDark")
            
            OptBtn.MouseButton1Click:Connect(function()
                callback(opt)
                open = false
                TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1,-5,0,38)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
            end)
        end
    end

    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,-5,0,35)
        Btn.BackgroundColor3 = CurrentTheme.Secondary
        Btn.Text = text
        Btn.TextColor3 = CurrentTheme.Text
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 14
        Btn.Parent = Page
        AddToRegistry(Btn, "Secondary")
        AddToRegistry(Btn, "Text") -- Text color also managed
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.Accent}):Play()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
            callback()
        end)
    end

    return Elements
end

-- // INITIALIZE WINDOW //
local UI = Library:Init()

-- // TABS //
local Tab_Combat = Library:CreateTab(UI, "Combat")
local Tab_Player = Library:CreateTab(UI, "Player")
local Tab_Visuals = Library:CreateTab(UI, "Visuals")
local Tab_Themes = Library:CreateTab(UI, "Themes")
local Tab_Misc = Library:CreateTab(UI, "Misc")

-- // ================= FEATURES ================= //

-- --- COMBAT ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

Tab_Combat:CreateSection("Aimbot")
Tab_Combat:CreateToggle("Enable Aimbot", "Aimbot", function(v) FOVCircle.Visible = v end)
Tab_Combat:CreateSlider("FOV Radius", 50, 600, "AimbotFOV", function(v) FOVCircle.Radius = v end)

Tab_Combat:CreateSection("Hitboxes")
Tab_Combat:CreateToggle("Hitbox Expander", "HitboxExpander", function(v) end)
Tab_Combat:CreateSlider("Hitbox Size", 2, 20, "HitboxSize", function(v) end)

-- Combat Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    if CurrentConfig.Aimbot then FOVCircle.Visible = true else FOVCircle.Visible = false end

    -- Hitbox Expander Logic
    if CurrentConfig.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(CurrentConfig.HitboxSize, CurrentConfig.HitboxSize, CurrentConfig.HitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.5
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- Aimbot Logic
    if CurrentConfig.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest = nil
        local maxDist = CurrentConfig.AimbotFOV
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = p.Character.Head
                        end
                    end
                end
            end
        end
        if closest then
            TweenService:Create(Camera, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)}):Play()
        end
    end
end)


-- --- VISUALS ---
local ESP_Cache = {}

Tab_Visuals:CreateSection("ESP Settings")
Tab_Visuals:CreateToggle("Enable Boxes", "ESP_Box", function(v) end)
Tab_Visuals:CreateToggle("Enable Names", "ESP_Name", function(v) end)
Tab_Visuals:CreateToggle("Enable Tracers", "ESP_Tracers", function(v) end)

Tab_Visuals:CreateSection("World")
Tab_Visuals:CreateToggle("Fullbright", "FullBright", function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            
            if not ESP_Cache[p] then
                -- Create Drawings
                ESP_Cache[p] = {
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text"),
                    Tracer = Drawing.new("Line")
                }
                -- Setup defaults
                ESP_Cache[p].Box.Color = Color3.fromRGB(255, 50, 50)
                ESP_Cache[p].Box.Thickness = 1
                ESP_Cache[p].Box.Filled = false
                
                ESP_Cache[p].Name.Color = Color3.fromRGB(255, 255, 255)
                ESP_Cache[p].Name.Size = 16
                ESP_Cache[p].Name.Center = true
                
                ESP_Cache[p].Tracer.Color = Color3.fromRGB(255, 50, 50)
                ESP_Cache[p].Tracer.Thickness = 1
            end
            
            local cache = ESP_Cache[p]
            local hrp = p.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                -- Box
                if CurrentConfig.ESP_Box then
                    cache.Box.Visible = true
                    local size = Vector2.new(2000 / vector.Z, 2500 / vector.Z)
                    cache.Box.Size = size
                    cache.Box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                else
                    cache.Box.Visible = false
                end
                
                -- Name
                if CurrentConfig.ESP_Name then
                    cache.Name.Visible = true
                    cache.Name.Text = p.Name
                    cache.Name.Position = Vector2.new(vector.X, vector.Y - (1500/vector.Z))
                else
                    cache.Name.Visible = false
                end

                -- Tracer
                if CurrentConfig.ESP_Tracers then
                    cache.Tracer.Visible = true
                    cache.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    cache.Tracer.To = Vector2.new(vector.X, vector.Y)
                else
                    cache.Tracer.Visible = false
                end
            else
                cache.Box.Visible = false
                cache.Name.Visible = false
                cache.Tracer.Visible = false
            end
        else
            if ESP_Cache[p] then
                ESP_Cache[p].Box.Visible = false
                ESP_Cache[p].Name.Visible = false
                ESP_Cache[p].Tracer.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESP_Cache[p] then
        ESP_Cache[p].Box:Remove()
        ESP_Cache[p].Name:Remove()
        ESP_Cache[p].Tracer:Remove()
        ESP_Cache[p] = nil
    end
end)


-- --- PLAYER ---
Tab_Player:CreateSection("Movement")
Tab_Player:CreateSlider("WalkSpeed", 16, 300, "WalkSpeed", function(v) 
    if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
end)
Tab_Player:CreateSlider("JumpPower", 50, 300, "JumpPower", function(v) 
    if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = v end 
end)

Tab_Player:CreateToggle("Flight (CFrame)", "Flight", function(v) end)
Tab_Player:CreateSlider("Fly Speed", 10, 100, "FlySpeed", function(v) end)

Tab_Player:CreateToggle("SpinBot", "SpinBot", function(v)
    if v then
        local bg = Instance.new("BodyAngularVelocity")
        bg.Name = "SpinBot"
        bg.MaxTorque = Vector3.new(0, math.huge, 0)
        bg.AngularVelocity = Vector3.new(0, 20, 0)
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            bg.Parent = LocalPlayer.Character.PrimaryPart
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart:FindFirstChild("SpinBot") then
            LocalPlayer.Character.PrimaryPart.SpinBot:Destroy()
        end
    end
end)

-- Flight Loop
RunService.RenderStepped:Connect(function()
    if CurrentConfig.Flight and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = Camera.CFrame
        local speed = CurrentConfig.FlySpeed
        local velocity = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + (cam.LookVector * speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - (cam.LookVector * speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - (cam.RightVector * speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + (cam.RightVector * speed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, speed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, speed, 0) end
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (velocity * RunService.RenderStepped:Wait())
    end
    
    -- Enforce Stats
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.WalkSpeed ~= CurrentConfig.WalkSpeed then
            LocalPlayer.Character.Humanoid.WalkSpeed = CurrentConfig.WalkSpeed
        end
        if LocalPlayer.Character.Humanoid.JumpPower ~= CurrentConfig.JumpPower then
            LocalPlayer.Character.Humanoid.JumpPower = CurrentConfig.JumpPower
        end
    end
end)


-- --- THEMES ---
Tab_Themes:CreateSection("Select Theme")
Tab_Themes:CreateDropdown("Choose Theme", {"Bean Green", "Midnight Blue", "Crimson Void", "Royal Purple", "Cotton Candy"}, function(val)
    UpdateThemes(val)
end)

Tab_Themes:CreateButton("Unload Cheat", function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, v in pairs(ESP_Cache) do
        v.Box:Remove()
        v.Name:Remove()
        v.Tracer:Remove()
    end
end)

-- --- MISC ---
Tab_Misc:CreateSection("Utilities")
Tab_Misc:CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

Tab_Misc:CreateToggle("Anti-AFK", "AntiAFK", function(v)
    if v then
        LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
end)

-- Initialize Defaults
UpdateThemes(CurrentConfig.Theme)
print(beanhub loaded)
