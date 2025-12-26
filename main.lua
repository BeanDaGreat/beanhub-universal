-- ═══════════════════════════════════════════════════════════
--  Universale OMEGA v1 (cleaned)
--  developed by Loupazerty
--  Modified: removed AutoFire feature and Kill Panel per request
-- ═══════════════════════════════════════════════════════════

-- Wait for the game to load to avoid crashing (Using `wait()`)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- === CRITICAL FUNCTION: FIND OR SET THE GUI PARENT ===
local function GetSafeParent()
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if success and core then
        -- Test if we can insert into CoreGui
        local s, e = pcall(function() local t = Instance.new("ScreenGui", core) t:Destroy() end)
        if s then return core end
    end
    -- Otherwise, use PlayerGui
    return Player:WaitForChild("PlayerGui")
end

local TargetParent = GetSafeParent()

-- === CONFIGURATION & THEME ===
local Theme = {
    -- Updated palette: higher contrast and more modern accent
    Main = Color3.fromRGB(20, 22, 30),
    Sidebar = Color3.fromRGB(28, 30, 40),
    Content = Color3.fromRGB(34, 36, 48),
    Accent = Color3.fromRGB(72, 209, 204), -- turquoise
    Text = Color3.fromRGB(242, 242, 245),
    TextDark = Color3.fromRGB(170, 174, 183),
    Stroke = Color3.fromRGB(40, 44, 54),
    StrokeAccent = Color3.fromRGB(122, 220, 215)
}

local Config = {
    Speed = 16,
    Jump = 50,
    InfJump = false,
    ClickTP = false,
    -- Combat
    HitboxExpander = false,
    HitboxSize = 5,
    Aimbot = false,
    KillAura = false,     -- NEW
    AntiKnockback = false, -- NEW
    AutoFire = false,
    -- Visuals
    ESP = false,
    BoxESP = false,
    Tracers = false,
    NameESP = false,     -- NEW
    XRay = false,        -- NEW
    Fullbright = false,
    FOV = 70,
    AimbotRange = 300, -- maximum world distance (studs) to consider for aimbot
    AimbotSmooth = 0.2, -- smoothing factor when tracking target (0..1)
    AimbotLockRetention = 0.35 -- seconds to keep a locked target when briefly occluded
}

-- Keybinds (stored as Enum.KeyCode names for save/load)
Config.Keybinds = {
    ToggleMenu = "Insert",
    Fly = "F",
    Noclip = "N"
}

-- Extended defaults for other features (usable in the Settings panel)
local defaultExtras = {
    ESP = "K",
    BoxESP = "L",
    Tracers = "O",
    NameESP = "P",
    Aimbot = "G",
    KillAura = "H",
    HitboxExpander = "J",
    Fullbright = "U",
    ClickTP = "M"
}
for k,v in pairs(defaultExtras) do if Config.Keybinds[k] == nil then Config.Keybinds[k] = v end end

local Connections = {}
local VisualsCache = {Boxes = {}, Tracers = {}, Highlights = {}, NameLabels = {}}

-- Persistent aimbot state to maintain a locked target while RMB is held
local AimbotState = {
    lockedTarget = nil,
    lastSeenAt = 0
}

-- === GUI CREATION ===
if TargetParent:FindFirstChild("Universale OMEGA V2") then
    TargetParent.UniversaLeOmegaV2:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Universale OMEGA v2"
ScreenGui.Parent = TargetParent
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
-- Direct attempt without pcall for simplicity
ScreenGui.IgnoreGuiInset = true 

-- Tracer Container (for ESP Box/Line/Name)
local TracerLayer = Instance.new("Frame", ScreenGui)
TracerLayer.Name = "TracerLayer"
TracerLayer.Size = UDim2.new(1,0,1,0)
TracerLayer.BackgroundTransparency = 1
TracerLayer.Visible = true
TracerLayer.ZIndex = 1

-- === BACKUP OPEN BUTTON (Click to hide/show) ===
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0, 20)
OpenBtn.BackgroundColor3 = Theme.Main
OpenBtn.Text = "≡"
OpenBtn.TextColor3 = Theme.Accent
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 24
local OBCorner = Instance.new("UICorner", OpenBtn) OBCorner.CornerRadius = UDim.new(0, 12)
local OBStroke = Instance.new("UIStroke", OpenBtn) OBStroke.Color = Theme.Accent OBStroke.Thickness = 2

-- Blur Effect (Safe)
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 15 

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 850, 0, 550)
Main.Position = UDim2.new(0.5, -425, 0.5, -275)
Main.BackgroundColor3 = Theme.Main
Main.ClipsDescendants = true
Main.BackgroundTransparency = 0 
Main.Visible = true             
Main.ZIndex = 2

local MainCorner = Instance.new("UICorner", Main) MainCorner.CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main) 
MainStroke.Color = Theme.StrokeAccent 
MainStroke.Thickness = 1.5 
MainStroke.Transparency = 0 

-- === DRAGGABLE SYSTEM ===
local dragging, dragInput, dragStart, startPos
local function MakeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(Main)

-- === SIDEBAR & LAYOUT (Reused) ===
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 220, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", Sidebar) SideCorner.CornerRadius = UDim.new(0, 12)

local Profile = Instance.new("Frame", Sidebar)
Profile.Size = UDim2.new(1, 0, 0, 90) Profile.BackgroundTransparency = 1

local Avatar = Instance.new("ImageLabel", Profile)
Avatar.Size = UDim2.new(0, 45, 0, 45) Avatar.Position = UDim2.new(0, 15, 0, 22)
Avatar.BackgroundColor3 = Theme.Accent
-- Helper: reliably set the player's avatar thumbnail (with graceful fallback)
local function UpdateAvatar()
    if not Player or not Player.UserId or Player.UserId <= 0 then
        return
    end
    -- Try multiple strategies to obtain a thumbnail
    for i = 1, 3 do
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and thumb and type(thumb) == "string" and thumb ~= "" then
            Avatar.Image = thumb
            Avatar.ImageTransparency = 0
            Avatar.Visible = true
            return
        end
        wait(0.15)
    end

    -- Fallback: try Roblox headshot URL (works in most environments)
    local safeUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(Player.UserId) .. "&width=420&height=420&format=png"
    local suc, _ = pcall(function() Avatar.Image = safeUrl end)
    if suc then
        Avatar.ImageTransparency = 0
        Avatar.Visible = true
        return
    end

    -- Final fallback: no image, keep colored circle
    Avatar.Image = ""
    Avatar.ImageTransparency = 1
    Avatar.Visible = true
end

-- Try to set avatar now and when Player.UserId changes (some environments set UserId late)
pcall(UpdateAvatar)
if not Connections.AvatarUpdate then
    Connections.AvatarUpdate = Player:GetPropertyChangedSignal("UserId"):Connect(function()
        pcall(UpdateAvatar)
    end)
end
local AvatarCorner = Instance.new("UICorner", Avatar) AvatarCorner.CornerRadius = UDim.new(1, 0)
local AvatarStroke = Instance.new("UIStroke", Avatar) AvatarStroke.Color = Theme.Accent AvatarStroke.Thickness = 2

local Welcome = Instance.new("TextLabel", Profile)
Welcome.Size = UDim2.new(0, 130, 0, 20) Welcome.Position = UDim2.new(0, 72, 0, 25)
Welcome.Text = "Universale OMEGA V2"
Welcome.TextColor3 = Theme.TextDark 
Welcome.Font = Enum.Font.GothamMedium Welcome.TextSize = 11 Welcome.TextXAlignment = Enum.TextXAlignment.Left Welcome.BackgroundTransparency = 1

local Username = Instance.new("TextLabel", Profile)
Username.Size = UDim2.new(0, 130, 0, 20) Username.Position = UDim2.new(0, 72, 0, 42)
Username.Text = Player.DisplayName Username.TextColor3 = Theme.Text 
Username.Font = Enum.Font.GothamBlack Username.TextSize = 15
Username.TextXAlignment = Enum.TextXAlignment.Left Username.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -100) TabContainer.Position = UDim2.new(0, 0, 0, 100)
TabContainer.BackgroundTransparency = 1

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -220, 1, 0) Pages.Position = UDim2.new(0, 220, 0, 0)
Pages.BackgroundTransparency = 1

local PageTitle = Instance.new("TextLabel", Pages)
PageTitle.Size = UDim2.new(1, -40, 0, 60) PageTitle.Position = UDim2.new(0, 25, 0, 10)
PageTitle.Text = "Movement" 
PageTitle.Font = Enum.Font.GothamBlack 
PageTitle.TextSize = 32 
PageTitle.TextColor3 = Theme.Text PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.BackgroundTransparency = 1

local ContentScroll = Instance.new("ScrollingFrame", Pages)
ContentScroll.Size = UDim2.new(1, -10, 1, -80) ContentScroll.Position = UDim2.new(0, 5, 0, 80)
ContentScroll.BackgroundTransparency = 1 ContentScroll.ScrollBarThickness = 3 
ContentScroll.ScrollBarImageColor3 = Theme.Accent
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0) 

local UIList = Instance.new("UIListLayout", ContentScroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder UIList.Padding = UDim.new(0, 12) 
UIList.FillDirection = Enum.FillDirection.Vertical

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

-- === UI BUILDER FUNCTIONS (Reused) ===
local function CreateTab(name, isActive)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.85, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.Sidebar
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "      " .. name
    TabBtn.TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextDark
    TabBtn.Font = Enum.Font.GothamBold TabBtn.TextSize = 13 TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabCorner = Instance.new("UICorner", TabBtn) TabCorner.CornerRadius = UDim.new(0, 8)
    local TabListLayout = TabContainer:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 5) TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    -- Active indicator (small left bar)
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0, 6, 1, 0)
    Indicator.Position = UDim2.new(0, 0, 0, 0)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.Visible = isActive

    TabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                btn.TextColor3 = Theme.TextDark
                local ind = btn:FindFirstChildWhichIsA("Frame")
                if ind then ind.Visible = false end
            end
        end
        -- animate selected
        TweenService:Create(TabBtn, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
        TabBtn.TextColor3 = Color3.new(1,1,1)
        Indicator.Visible = true
        PageTitle.Text = name
        for _, frame in pairs(ContentScroll:GetChildren()) do
            if frame:IsA("Frame") and frame:GetAttribute("Tab") then
                frame.Visible = (frame:GetAttribute("Tab") == name)
            end
        end
    end)
end

local function CreateToggle(tabName, text, callback, initialState)
    local ToggleFrame = Instance.new("Frame", ContentScroll)
    ToggleFrame.Name = text
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Theme.Content
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame:SetAttribute("Tab", tabName)
    ToggleFrame.Visible = (tabName == "Movement")
    
    local TCorner = Instance.new("UICorner", ToggleFrame) TCorner.CornerRadius = UDim.new(0, 8)
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(0.7, 0, 1, 0) Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = text Label.TextColor3 = Theme.Text 
    Label.Font = Enum.Font.GothamSemibold Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left Label.BackgroundTransparency = 1
    
    local SwitchBg = Instance.new("Frame", ToggleFrame)
    SwitchBg.Size = UDim2.new(0, 44, 0, 24) SwitchBg.Position = UDim2.new(1, -60, 0.5, -12)
    SwitchBg.BackgroundColor3 = initialState and Theme.Accent or Color3.fromRGB(40, 40, 50) 
    local SBCorner = Instance.new("UICorner", SwitchBg) SBCorner.CornerRadius = UDim.new(1, 0)
    
    local SwitchDot = Instance.new("Frame", SwitchBg)
    SwitchDot.Size = UDim2.new(0, 20, 0, 20)
    SwitchDot.Position = initialState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) 
    SwitchDot.BackgroundColor3 = Theme.Text
    local SDCorner = Instance.new("UICorner", SwitchDot) SDCorner.CornerRadius = UDim.new(1, 0)
    
    local Button = Instance.new("TextButton", ToggleFrame)
    Button.Size = UDim2.new(1, 0, 1, 0) Button.BackgroundTransparency = 1 Button.Text = ""
    
    local toggled = initialState or false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        local targetColor = toggled and Theme.Accent or Color3.fromRGB(40, 40, 50)
        local targetPos = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        TweenService:Create(SwitchBg, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        callback(toggled) -- Removed pcall for clarity
    end)
end

local function CreateSlider(tabName, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame", ContentScroll)
    SliderFrame.Name = text
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 70)
    SliderFrame.BackgroundColor3 = Theme.Content
    SliderFrame:SetAttribute("Tab", tabName)
    SliderFrame.Visible = (tabName == "Movement")
    
    local SCorner = Instance.new("UICorner", SliderFrame) SCorner.CornerRadius = UDim.new(0, 8)
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, -30, 0, 30) Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Text = text Label.TextColor3 = Theme.Text 
    Label.Font = Enum.Font.GothamSemibold Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left Label.BackgroundTransparency = 1
    
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(0, 50, 0, 30) ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.Text = tostring(default) 
    ValueLabel.TextColor3 = Theme.Accent 
    ValueLabel.Font = Enum.Font.GothamBold ValueLabel.TextSize = 14
    ValueLabel.BackgroundTransparency = 1
    
    local SlideBg = Instance.new("Frame", SliderFrame)
    SlideBg.Size = UDim2.new(1, -30, 0, 8) 
    SlideBg.Position = UDim2.new(0, 15, 0, 45)
    SlideBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    local SBgCorner = Instance.new("UICorner", SlideBg) SBgCorner.CornerRadius = UDim.new(1, 0)
    
    local SlideFill = Instance.new("Frame", SlideBg)
    SlideFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SlideFill.BackgroundColor3 = Theme.Accent
    local SFCorner = Instance.new("UICorner", SlideFill) SFCorner.CornerRadius = UDim.new(1, 0)
    
    local Trigger = Instance.new("TextButton", SlideBg)
    Trigger.Size = UDim2.new(1, 0, 2, 0) Trigger.Position = UDim2.new(0, 0, -0.5, 0) Trigger.BackgroundTransparency = 1 Trigger.Text = ""
    
    local draggingSlider = false
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = UDim2.new(math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1), 0, 1, 0)
            SlideFill.Size = pos
            local val = math.floor(min + ((max - min) * pos.X.Scale))
            ValueLabel.Text = tostring(val)
            callback(val) -- Removed pcall
        end
    end)
end

local function CreateButton(tabName, text, callback)
    local BtnFrame = Instance.new("Frame", ContentScroll)
    BtnFrame.Size = UDim2.new(0.95, 0, 0, 50) BtnFrame.BackgroundColor3 = Theme.Content
    BtnFrame:SetAttribute("Tab", tabName) BtnFrame.Visible = (tabName == "Movement")
    local RC = Instance.new("UICorner", BtnFrame) RC.CornerRadius = UDim.new(0, 8)
    local Btn = Instance.new("TextButton", BtnFrame)
    Btn.Size = UDim2.new(1,0,1,0) Btn.BackgroundTransparency = 1
    Btn.Text = text 
    Btn.TextColor3 = Theme.Accent 
    Btn.Font = Enum.Font.GothamBold 
    Btn.TextSize = 16
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {TextSize = 14}):Play()
        wait(0.1) -- Replaced task.wait with wait
        TweenService:Create(Btn, TweenInfo.new(0.1), {TextSize = 16}):Play()
        callback() -- Removed pcall
    end)
end

local function CreateInput(tabName, placeholder, callback)
    local Frame = Instance.new("Frame", ContentScroll)
    Frame.Size = UDim2.new(0.95, 0, 0, 50) Frame.BackgroundColor3 = Theme.Content
    Frame:SetAttribute("Tab", tabName) Frame.Visible = (tabName == "Movement")
    local RC = Instance.new("UICorner", Frame) RC.CornerRadius = UDim.new(0, 8)
    
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(1, -20, 1, 0) Box.Position = UDim2.new(0, 10, 0, 0)
    Box.BackgroundTransparency = 1 
    Box.TextColor3 = Color3.new(1,1,1)
    Box.PlaceholderText = placeholder 
    Box.Font = Enum.Font.Gotham 
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    
    Box.FocusLost:Connect(function(enter)
        if enter then callback(Box.Text) end -- Removed pcall
    end)
    return Box
end

-- === SETUP TABS ===
CreateTab("Movement", true)
CreateTab("Combat", false)
CreateTab("Visuals", false)
CreateTab("Teleport", false)
CreateTab("Settings", false)
CreateTab("Server", false)
CreateTab("Autres", false)
CreateTab("Contact", false)


-- === MOVEMENT LOGIC ===
local function UpdateInfiniteJump(state)
    Config.InfJump = state

    if Connections.InfJump then 
        Connections.InfJump:Disconnect() 
        Connections.InfJump = nil
    end

    if state then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local char = Player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

CreateToggle("Movement", "Infinite Jump (SPACE)", UpdateInfiniteJump)

-- Helper functions to control Fly and Noclip from code (used by toggles and keybinds)
local function SetFlyState(state)
    -- Disconnect previous
    if Connections.Fly then Connections.Fly:Disconnect() end
    if state then
        Connections.Fly = RunService.Heartbeat:Connect(function()
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local cam = workspace.CurrentCamera
                local vel = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
                if vel.Magnitude > 0 then
                    root.Velocity = vel.Unit * (Config.Speed * 3)
                    root.Anchored = false
                else
                    root.Velocity = Vector3.new()
                    root.Anchored = true
                end
            end
        end)
    else
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.Anchored = false
        end
    end
end

local function SetNoclipState(s)
    -- Reuse the previous noclip implementation but within a callable function
    -- Cleanup old Noclip connections (handles old and new formats)
    if Connections.Noclip then
        if type(Connections.Noclip) == "table" then
            if Connections.Noclip.CharAdded then Connections.Noclip.CharAdded:Disconnect() end
            if Connections.Noclip.DescAdded then Connections.Noclip.DescAdded:Disconnect() end
            if Connections.Noclip.Heartbeat then Connections.Noclip.Heartbeat:Disconnect() end
        else
            pcall(function() Connections.Noclip:Disconnect() end)
        end
        Connections.Noclip = nil
    end

    local originalCanCollide = Connections._originalCanCollide or {}
    Connections._originalCanCollide = originalCanCollide

    if s then
        local function applyNoClipToCharacter(char)
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if originalCanCollide[part] == nil then originalCanCollide[part] = part.CanCollide end
                    if part.CanCollide then part.CanCollide = false end
                end
            end
        end

        local function onDescendantAdded(desc)
            if desc:IsA("BasePart") then
                if originalCanCollide[desc] == nil then originalCanCollide[desc] = desc.CanCollide end
                desc.CanCollide = false
            end
        end

        applyNoClipToCharacter(Player.Character)

        Connections.Noclip = {}
        local last = 0
        local thr = 0.1
        Connections.Noclip.Heartbeat = RunService.Heartbeat:Connect(function(dt)
            last = last + dt
            if last >= thr then
                last = 0
                if Player.Character then applyNoClipToCharacter(Player.Character) end
            end
        end)

        if Player.Character then
            Connections.Noclip.DescAdded = Player.Character.DescendantAdded:Connect(onDescendantAdded)
        end

        Connections.Noclip.CharAdded = Players.LocalPlayer.CharacterAdded:Connect(function(char)
            if Connections.Noclip.DescAdded then Connections.Noclip.DescAdded:Disconnect() end
            applyNoClipToCharacter(char)
            Connections.Noclip.DescAdded = char.DescendantAdded:Connect(onDescendantAdded)
        end)
    else
        local function restoreCharacterCollisions(char)
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if originalCanCollide[part] ~= nil then
                        pcall(function() part.CanCollide = originalCanCollide[part] end)
                        originalCanCollide[part] = nil
                    else
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
        end

        if Player.Character then restoreCharacterCollisions(Player.Character) end

        if Connections.Noclip then
            if type(Connections.Noclip) == "table" then
                if Connections.Noclip.CharAdded then Connections.Noclip.CharAdded:Disconnect() end
                if Connections.Noclip.DescAdded then Connections.Noclip.DescAdded:Disconnect() end
                if Connections.Noclip.Heartbeat then Connections.Noclip.Heartbeat:Disconnect() end
            end
            Connections.Noclip = nil
        end
        Connections._originalCanCollide = {}
    end
end


CreateToggle("Movement", "Fly Mode", function(s)
    Config.Fly = s
    SetFlyState(s)
end)

CreateToggle("Movement", "Noclip", function(s)
    Config.Noclip = s
    SetNoclipState(s)
end)


CreateSlider("Movement", "Walk Speed", 16, 300, 16, function(v)
    Config.Speed = v
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        -- Apply immediately and ensure maintainer enforcer is aware
        local h = Player.Character:FindFirstChild("Humanoid")
        pcall(function() h.WalkSpeed = v end)
        if Connections.StatMaintainers and Connections.StatMaintainers[h] and Connections.StatMaintainers[h].reapply then
            pcall(Connections.StatMaintainers[h].reapply)
        end
    end
end)

CreateSlider("Movement", "Jump Power", 50, 500, 50, function(v)
    Config.Jump = v
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local h = Player.Character:FindFirstChild("Humanoid")
        pcall(function() h.UseJumpPower = true h.JumpPower = v end)
        if Connections.StatMaintainers and Connections.StatMaintainers[h] and Connections.StatMaintainers[h].reapply then
            pcall(Connections.StatMaintainers[h].reapply)
        end
    end
end)



-- === COMBAT LOGIC ===
CreateToggle("Combat", "Kill Aura (Auto-attack)", function(s)
    Config.KillAura = s
    if Connections.KillAura then Connections.KillAura:Disconnect() end

    local function GetClosestTarget()
        local minDistance = 30 -- Range of the Aura
        local closestTarget = nil
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                local distance = (root.Position - targetRoot.Position).Magnitude
                if distance < minDistance and targetRoot.Parent:FindFirstChildOfClass("Humanoid") and targetRoot.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                    minDistance = distance
                    closestTarget = targetRoot
                end
            end
        end
        return closestTarget
    end
    
    if s then
        Connections.KillAura = RunService.Heartbeat:Connect(function()
            local target = GetClosestTarget()
            if target then
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Quick rotation towards the target
                    root.CFrame = CFrame.new(root.Position, target.Position)
                    -- Simulate a mouse click to trigger the equipped tool's attack
                    UserInputService:SimulateMouseClick(Mouse.X, Mouse.Y)
                end
            end
        end)
    end
end)

CreateToggle("Combat", "Anti-Knockback", function(s)
    Config.AntiKnockback = s
    if Connections.AntiKnockback then Connections.AntiKnockback:Disconnect() end
    
    if s then
        Connections.AntiKnockback = RunService.Heartbeat:Connect(function()
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Force the Running state to cancel external knockback forces
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end)

CreateToggle("Combat", "Hitbox Expander", function(s)
    Config.HitboxExpander = s
    if not s then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                -- Restore head properties
                p.Character.Head.Size = Vector3.new(2,1,1) -- standard head size
                p.Character.Head.Transparency = 0
                p.Character.Head.CanCollide = true
            end
        end
    end
end)

CreateSlider("Combat", "Hitbox Size", 2, 20, 5, function(v) Config.HitboxSize = v end)
CreateToggle("Combat", "Aimbot (Right Click)", function(s) Config.Aimbot = s end)

RunService.RenderStepped:Connect(function()
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- Enforce WalkSpeed
        if humanoid.WalkSpeed ~= Config.Speed then humanoid.WalkSpeed = Config.Speed end
        -- Enforce JumpPower
        if humanoid.JumpPower ~= Config.Jump then humanoid.UseJumpPower = true humanoid.JumpPower = Config.Jump end
    end

    if Config.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                p.Character.Head.Transparency = 0.6
                p.Character.Head.CanCollide = false
            end
        end
    end

    local rightHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if Config.Aimbot and rightHeld then
        -- if we don't have a locked target yet, search for the best candidate nearby the crosshair
        if not AimbotState.lockedTarget then
            local closest = nil
            local dist = math.huge
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and myRoot then
                        local worldDist = (myRoot.Position - targetRoot.Position).Magnitude
                        if worldDist <= (Config.AimbotRange or 300) then
                            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                            if vis then
                                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                                if mag < dist and mag < 200 then
                                    dist = mag
                                    closest = p
                                end
                            end
                        end
                    end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                AimbotState.lockedTarget = closest
                AimbotState.lastSeenAt = tick()
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position), Config.AimbotSmooth or 0.2)
            end
        else
            -- we have a locked target; keep tracking it until it becomes invalid
            local target = AimbotState.lockedTarget
            local valid = target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("HumanoidRootPart")
            if valid then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                local withinRange = true
                if myRoot and targetRoot then withinRange = (myRoot.Position - targetRoot.Position).Magnitude <= (Config.AimbotRange or 300) end
                if not withinRange then
                    AimbotState.lockedTarget = nil
                else
                    local head = target.Character:FindFirstChild("Head")
                    local pos, vis = Camera:WorldToViewportPoint(head.Position)
                    if vis then AimbotState.lastSeenAt = tick() end
                    if tick() - (AimbotState.lastSeenAt or 0) <= (Config.AimbotLockRetention or 0.35) then
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, head.Position), Config.AimbotSmooth or 0.2)
                    else
                        -- lost too long while occluded -> release lock
                        AimbotState.lockedTarget = nil
                    end
                end
            else
                -- invalid target anymore
                AimbotState.lockedTarget = nil
            end
        end
    else
        -- RMB released -> clear lock
        AimbotState.lockedTarget = nil
        AimbotState.lastSeenAt = 0
    end
end)

-- === VISUALS LOGIC ===
CreateToggle("Visuals", "ESP Highlight", function(s)
    Config.ESP = s
    if not s then
        for _, hl in pairs(VisualsCache.Highlights) do
            if hl.Parent then hl:Destroy() end
        end
        VisualsCache.Highlights = {}
    end
end)

CreateToggle("Visuals", "Box ESP", function(s)
    Config.BoxESP = s
    if not s then
        for _, box in pairs(VisualsCache.Boxes) do box.Visible = false end
    end
end)

CreateToggle("Visuals", "Tracers", function(s)
    Config.Tracers = s
    if not s then
        for _, line in pairs(VisualsCache.Tracers) do line.Visible = false end
    end
end)

CreateToggle("Visuals", "Name ESP", function(s)
    Config.NameESP = s
    if not s then
        for _, label in pairs(VisualsCache.NameLabels) do label.Visible = false end
    end
end)

CreateToggle("Visuals", "X-Ray/Wallhack", function(s)
    Config.XRay = s
    local function setTransparency(part, t)
        if part:IsA("BasePart") and part.CanCollide and not part:IsDescendantOf(Player.Character) then part.LocalTransparencyModifier = t end
    end
    if s then
        Lighting.ClearColor = Color3.fromRGB(0,0,0) -- Darken environment
        for _, part in pairs(workspace:GetDescendants()) do setTransparency(part, 0.5) end
        if Connections.XRay then Connections.XRay:Disconnect() end
        -- Ensure to disconnect previous
        Connections.XRay = workspace.DescendantAdded:Connect(function(descendant) setTransparency(descendant, 0.5) end)
    else
        if Connections.XRay then Connections.XRay:Disconnect() end
        Lighting.ClearColor = Color3.fromRGB(200, 200, 200) -- Return to normal (default color)
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.LocalTransparencyModifier then part.LocalTransparencyModifier = 0 end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not Config.ESP and not Config.BoxESP and not Config.Tracers and not Config.NameESP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)

            -- ESP (Highlight)
            if Config.ESP then
                if not VisualsCache.Highlights[p] or not VisualsCache.Highlights[p].Parent then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.FillColor = Theme.Accent
                    hl.OutlineColor = Color3.new(1,1,1)
                    hl.FillTransparency = 0.5
                    VisualsCache.Highlights[p] = hl
                end
            else
                if VisualsCache.Highlights[p] and VisualsCache.Highlights[p].Parent then
                    VisualsCache.Highlights[p]:Destroy()
                    VisualsCache.Highlights[p] = nil
                end
            end

            -- Tracers
            local line = VisualsCache.Tracers[p]
            if not line then
                line = Instance.new("Frame", TracerLayer)
                line.BorderSizePixel = 0
                line.BackgroundColor3 = Theme.Accent
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                VisualsCache.Tracers[p] = line
            end

            -- Boxes (outline visible + slight transparent fill)
            local box = VisualsCache.Boxes[p]
            if not box then
                box = Instance.new("Frame", TracerLayer)
                box.BorderSizePixel = 0
                box.BackgroundColor3 = Color3.new(0,0,0)
                box.BackgroundTransparency = 0.6
                box.ClipsDescendants = true
                box.AnchorPoint = Vector2.new(0.5, 0.5)
                VisualsCache.Boxes[p] = box
                -- use UIStroke for visible outline
                local stroke = Instance.new("UIStroke", box)
                stroke.Thickness = 2
                stroke.Transparency = 0
                stroke.Color = Theme.Accent
            else
                -- ensure stroke exists
                if not box:FindFirstChildOfClass("UIStroke") then
                    local stroke = Instance.new("UIStroke", box)
                    stroke.Thickness = 2
                    stroke.Transparency = 0
                    stroke.Color = Theme.Accent
                end
            end

            -- Name ESP
            local nameLabel = VisualsCache.NameLabels[p]
            if not nameLabel then
                nameLabel = Instance.new("TextLabel", TracerLayer)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Theme.Accent
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 12
                nameLabel.TextStrokeTransparency = 0.7
                VisualsCache.NameLabels[p] = nameLabel
            end

            if vis then
                local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
                local topWorld = head.Position + Vector3.new(0, 0.4, 0)
                local bottomWorld = rootPart and (rootPart.Position - Vector3.new(0, 2, 0)) or (head.Position - Vector3.new(0, 3.5, 0))
                local topScreen = Camera:WorldToViewportPoint(topWorld)
                local bottomScreen = Camera:WorldToViewportPoint(bottomWorld)

                -- compute box dimensions and center (used both for BoxESP and NameESP)
                local boxH = math.clamp(math.floor(math.abs(bottomScreen.Y - topScreen.Y)), 30, 800)
                local boxW = math.floor(boxH / 1.5)
                local centerX = (topScreen.X + bottomScreen.X) / 2
                local centerY = (topScreen.Y + bottomScreen.Y) / 2
                local rawSize = 2500 / pos.Z
                local size = math.clamp(math.floor(rawSize), 30, 600)

                -- Tracers
                if Config.Tracers then
                    local start = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local target = Vector2.new(pos.X, pos.Y)
                    local dist = (target - start).Magnitude
                    line.Visible = true
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Position = UDim2.new(0, (start.X + target.X)/2, 0, (start.Y + target.Y)/2)
                    line.Rotation = math.deg(math.atan2(target.Y - start.Y, target.X - start.X))
                else
                    line.Visible = false
                end

                -- BoxESP: size from head -> root, centered and clamped to viewport
                if Config.BoxESP then
                    box.Visible = true
                    box.Size = UDim2.new(0, boxW, 0, boxH)
                    local px = math.clamp(centerX, boxW/2, Camera.ViewportSize.X - boxW/2)
                    local py = math.clamp(centerY, boxH/2, Camera.ViewportSize.Y - boxH/2)
                    box.Position = UDim2.new(0, px, 0, py)
                else
                    box.Visible = false
                end

                -- NameESP: position relative to the box center (keeps label visually attached)
                if Config.NameESP then
                    nameLabel.Visible = true
                    nameLabel.Text = p.DisplayName .. "\n(" .. p.Name .. ")"
                    nameLabel.Size = UDim2.new(0, 150, 0, 40)
                    local labelX = math.clamp(centerX - 75, 0, Camera.ViewportSize.X - 150)
                    local labelY = math.clamp(centerY - (boxH/2) - 20, 0, Camera.ViewportSize.Y - 40)
                    nameLabel.Position = UDim2.new(0, labelX, 0, labelY)
                else
                    nameLabel.Visible = false
                end
            else
                -- Offscreen
                line.Visible = false
                box.Visible = false
                nameLabel.Visible = false
            end
        else
            -- Cleanup if the character no longer exists
            if VisualsCache.Tracers[p] then VisualsCache.Tracers[p].Visible = false end
            if VisualsCache.Boxes[p] then VisualsCache.Boxes[p].Visible = false end
            if VisualsCache.NameLabels[p] then VisualsCache.NameLabels[p].Visible = false end
            if VisualsCache.Highlights[p] and VisualsCache.Highlights[p].Parent then VisualsCache.Highlights[p]:Destroy() VisualsCache.Highlights[p] = nil end
        end
    end
end)

CreateSlider("Visuals", "FOV", 70, 120, 70, function(v) Camera.FieldOfView = v end)

CreateToggle("Visuals", "Fullbright", function(s)
    if s then
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

-- === TELEPORT LOGIC ===
CreateInput("Teleport", "TP Player: Name...", function(text)
    local targetFound = false
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #text) == string.lower(text) or string.sub(string.lower(p.DisplayName), 1, #text) == string.lower(text) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Player.Character then
                Player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                targetFound = true
                break
            end
        end
    end
    if not targetFound then warn("Teleport Player: No matching player found for '" .. text .. "'.") end
end)

local tpCoordsInput = CreateInput("Teleport", "TP Coords: X, Y, Z (ex: 100, 50, -200)", function(text)
    local parts = string.split(text, ",")
    if #parts == 3 then
        local x = tonumber(parts[1])
        local y = tonumber(parts[2])
        local z = tonumber(parts[3])
        if x and y and z and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y + 3, z)
            tpCoordsInput.Text = ""
        else warn("Teleport Coords: Invalid coordinate format (must be numeric X, Y, Z).") end
    else warn("Teleport Coords: Please enter 3 coordinates separated by commas (X, Y, Z).") end
end)

CreateToggle("Teleport", "Click TP (Ctrl+Click)", function(s) Config.ClickTP = s end)

Mouse.Button1Down:Connect(function()
    if Config.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local pos = Mouse.Hit.p
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
        end
    end
end)

CreateButton("Teleport", "TP to Player Spawn", function()
    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation") or workspace:FindFirstChild("SpawnLocation")
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and spawnLocation then
        Player.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    elseif Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        -- Attempt to TP to map center if no SpawnLocation found
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
    end
end)

-- === SETTINGS LOGIC ===
-- Keybind manager UI inside Settings tab
local KeybindButtons = {}
local Rebinding = nil
local KEYBINDS_FILE = "univ_omega_keybinds.json"

-- Theme presets
local ThemePresets = {
    DarkTurquoise = { Main = Color3.fromRGB(20,22,30), Sidebar = Color3.fromRGB(28,30,40), Content = Color3.fromRGB(34,36,48), Accent = Color3.fromRGB(72,209,204), Text = Color3.fromRGB(242,242,245), TextDark = Color3.fromRGB(170,174,183), Stroke = Color3.fromRGB(40,44,54), StrokeAccent = Color3.fromRGB(122,220,215) },
    MidnightPurple = { Main = Color3.fromRGB(12,10,25), Sidebar = Color3.fromRGB(18,16,36), Content = Color3.fromRGB(24,22,46), Accent = Color3.fromRGB(178,102,255), Text = Color3.fromRGB(240,240,245), TextDark = Color3.fromRGB(160,150,170), Stroke = Color3.fromRGB(30,26,44), StrokeAccent = Color3.fromRGB(150,110,255) },
    Solar = { -- Revised Solar: warmer, higher-contrast accents and cleaner neutrals
        Main = Color3.fromRGB(250,244,236), Sidebar = Color3.fromRGB(247,241,231), Content = Color3.fromRGB(242,237,222), Accent = Color3.fromRGB(255,159,67), Text = Color3.fromRGB(28,28,26), TextDark = Color3.fromRGB(115,110,100), Stroke = Color3.fromRGB(225,218,204), StrokeAccent = Color3.fromRGB(255,140,50)
    }
}

-- Extra themes
ThemePresets.Emerald = { Main = Color3.fromRGB(10,30,20), Sidebar = Color3.fromRGB(12,36,24), Content = Color3.fromRGB(18,46,30), Accent = Color3.fromRGB(0,230,118), Text = Color3.fromRGB(240,250,245), TextDark = Color3.fromRGB(150,170,160), Stroke = Color3.fromRGB(10,40,28), StrokeAccent = Color3.fromRGB(0,200,100) }
ThemePresets.Crimson = { Main = Color3.fromRGB(30,10,12), Sidebar = Color3.fromRGB(36,12,14), Content = Color3.fromRGB(46,18,20), Accent = Color3.fromRGB(255,82,82), Text = Color3.fromRGB(250,240,240), TextDark = Color3.fromRGB(170,140,140), Stroke = Color3.fromRGB(40,18,20), StrokeAccent = Color3.fromRGB(220,80,80) }
ThemePresets.MidnightBlue = { Main = Color3.fromRGB(6,12,30), Sidebar = Color3.fromRGB(8,16,40), Content = Color3.fromRGB(12,24,56), Accent = Color3.fromRGB(97,137,255), Text = Color3.fromRGB(240,245,255), TextDark = Color3.fromRGB(130,150,180), Stroke = Color3.fromRGB(20,30,50), StrokeAccent = Color3.fromRGB(100,140,255) }

local function ApplyTheme(preset)
    if not preset then return end
    -- copy values into Theme
    for k,v in pairs(preset) do Theme[k] = v end
    -- update main UI elements
    pcall(function()
        Main.BackgroundColor3 = Theme.Main
        Sidebar.BackgroundColor3 = Theme.Sidebar
        ContentScroll.ScrollBarImageColor3 = Theme.Accent
        OpenBtn.BackgroundColor3 = Theme.Main
        OpenBtn.TextColor3 = Theme.Accent
        MainStroke.Color = Theme.StrokeAccent
        Avatar.BackgroundColor3 = Theme.Accent
        AvatarStroke.Color = Theme.Accent
        PageTitle.TextColor3 = Theme.Text
        -- update keybind buttons color
        for _, btn in pairs(KeybindButtons) do if btn and btn:IsA("TextButton") then btn.TextColor3 = Theme.Accent end end
        -- update visuals cache
        for p,hl in pairs(VisualsCache.Highlights) do if hl and hl.Parent then hl.FillColor = Theme.Accent end end
        for p,line in pairs(VisualsCache.Tracers) do if line and line.Parent then line.BackgroundColor3 = Theme.Accent end end
        for p,box in pairs(VisualsCache.Boxes) do if box and box.Parent then
            -- try update UIStroke if present
            for _,c in pairs(box:GetChildren()) do if c:IsA("UIStroke") then c.Color = Theme.Accent end end
        end end
        for p,name in pairs(VisualsCache.NameLabels) do if name and name.Parent then name.TextColor3 = Theme.Accent end end
    end)
end

-- Refresh theme selector visuals when theme changes
pcall(function()
    if TBtn and Swatch and TDropdown then
        TBtn.BackgroundColor3 = Theme.Content
        TBtn.TextColor3 = Theme.Text
        Swatch.BackgroundColor3 = Theme.Accent
        Caret.TextColor3 = Theme.Text
        -- update dropdown entries colors
        for _, child in pairs(TDropdown:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = Theme.Content child.TextColor3 = Theme.Text end
        end
    end
end)

local function SaveKeybinds()
    if type(writefile) ~= "function" then warn("Save impossible: 'writefile' not available in this environment.") return false end
    local ok, err = pcall(function() writefile(KEYBINDS_FILE, HttpService:JSONEncode(Config.Keybinds)) end)
    if not ok then warn("Error saving keybinds:", err) end
    return ok
end

local function LoadKeybinds()
    if type(readfile) ~= "function" then return false end
    local ok, content = pcall(function() return readfile(KEYBINDS_FILE) end)
    if not ok or not content then return false end
    local suc, data = pcall(function() return HttpService:JSONDecode(content) end)
    if suc and type(data) == "table" then
        for k,v in pairs(data) do Config.Keybinds[k] = v end
        return true
    end
    return false
end

-- Build Settings panel content
local SettingsFrame = Instance.new("Frame", ContentScroll)
SettingsFrame.Name = "KeybindsManager"
-- size will be set dynamically below based on how many rows we create
SettingsFrame.Size = UDim2.new(0.95, 0, 0, 180)
SettingsFrame.BackgroundColor3 = Theme.Content
-- Keybinds manager belongs to the Settings tab (hidden by default)
SettingsFrame:SetAttribute("Tab", "Settings")
SettingsFrame.Visible = false
local SC = Instance.new("UICorner", SettingsFrame) SC.CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", SettingsFrame) Title.Size = UDim2.new(1, -20, 0, 30) Title.Position = UDim2.new(0, 10, 0, 8) Title.BackgroundTransparency = 1 Title.Text = "Keybinds" Title.TextColor3 = Theme.Text Title.Font = Enum.Font.GothamBold Title.TextSize = 16 Title.TextXAlignment = Enum.TextXAlignment.Left

-- Theme selector moved to the 'Autres' tab (see lower in the file)
local function makeBindRow(actionName, displayName, yOffset)
    local row = Instance.new("Frame", SettingsFrame)
    row.Size = UDim2.new(1, -20, 0, 36)
    row.Position = UDim2.new(0, 10, 0, 50 + yOffset)
    row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = displayName
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.Position = UDim2.new(1, -130, 0, 4)
    btn.Text = Config.Keybinds[actionName] or "Unset"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Theme.Accent
    local btnCorner = Instance.new("UICorner", btn) btnCorner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() Rebinding = actionName btn.Text = "Press a key..." end)
    KeybindButtons[actionName] = btn
end

-- Rows to show in the settings panel
local rows = {
    {"ToggleMenu", "Toggle Menu"},
    {"Fly", "Fly Mode"},
    {"Noclip", "Noclip"},
    {"ESP", "ESP"},
    {"BoxESP", "BoxESP"},
    {"Tracers", "Tracers"},
    {"NameESP", "Name ESP"},
    {"Aimbot", "Aimbot"},
    {"KillAura", "KillAura"},
    {"HitboxExpander", "Hitbox Expander"},
    {"Fullbright", "Fullbright"},
    {"ClickTP", "Click TP"}
}
local rowCount = #rows
local settingsHeight = 50 + (rowCount * 40) + 60
SettingsFrame.Size = UDim2.new(0.95, 0, 0, settingsHeight)
for i, r in ipairs(rows) do makeBindRow(r[1], r[2], (i-1) * 40) end

local SaveBtn = Instance.new("TextButton", SettingsFrame)
SaveBtn.Size = UDim2.new(0, 100, 0, 28)
SaveBtn.Position = UDim2.new(0, 10, 1, -40)
SaveBtn.Text = "Save"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.TextColor3 = Theme.Text
local SaveCorner = Instance.new("UICorner", SaveBtn) SaveCorner.CornerRadius = UDim.new(0, 6)
SaveBtn.MouseButton1Click:Connect(function() if SaveKeybinds() then warn("Keybinds saved") end end)

local LoadBtn = Instance.new("TextButton", SettingsFrame)
LoadBtn.Size = UDim2.new(0, 100, 0, 28)
LoadBtn.Position = UDim2.new(0, 120, 1, -40)
LoadBtn.Text = "Load"
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextSize = 14
LoadBtn.TextColor3 = Theme.Text
local LoadCorner = Instance.new("UICorner", LoadBtn) LoadCorner.CornerRadius = UDim.new(0, 6)
LoadBtn.MouseButton1Click:Connect(function()
    if LoadKeybinds() then
        for k,btn in pairs(KeybindButtons) do btn.Text = Config.Keybinds[k] or "Unset" end
        warn("Keybinds loaded")
    else warn("No keybinds file found or reading not supported.") end
end)

-- Try load at startup (best-effort)
pcall(LoadKeybinds)
for k,btn in pairs(KeybindButtons) do if btn and btn.Text then btn.Text = Config.Keybinds[k] or btn.Text end end

-- Helper: toggle feature by action name (used by keybinds)
local function ToggleFeatureByName(action)
    if action == "ESP" then
        Config.ESP = not Config.ESP
        if not Config.ESP then
            for _, hl in pairs(VisualsCache.Highlights) do if hl.Parent then hl:Destroy() end end
            VisualsCache.Highlights = {}
        end
        return
    end
    if action == "BoxESP" then
        Config.BoxESP = not Config.BoxESP
        if not Config.BoxESP then for _,box in pairs(VisualsCache.Boxes) do box.Visible = false end end
        return
    end
    if action == "Tracers" then
        Config.Tracers = not Config.Tracers
        if not Config.Tracers then for _,l in pairs(VisualsCache.Tracers) do l.Visible = false end end
        return
    end
    if action == "NameESP" then
        Config.NameESP = not Config.NameESP
        if not Config.NameESP then for _,n in pairs(VisualsCache.NameLabels) do n.Visible = false end end
        return
    end
    if action == "Aimbot" then Config.Aimbot = not Config.Aimbot return end
    if action == "KillAura" then
        -- reuse existing KillAura logic: disconnect then (re)create if enabled
        if Connections.KillAura then Connections.KillAura:Disconnect() Connections.KillAura = nil end
        Config.KillAura = not Config.KillAura
        if Config.KillAura then
            local function GetClosestTarget()
                local minDistance = 30
                local closestTarget = nil
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if not root then return nil end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = p.Character.HumanoidRootPart
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance < minDistance and targetRoot.Parent:FindFirstChildOfClass("Humanoid") and targetRoot.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                            minDistance = distance
                            closestTarget = targetRoot
                        end
                    end
                end
                return closestTarget
            end
            Connections.KillAura = RunService.Heartbeat:Connect(function()
                local target = GetClosestTarget()
                if target then
                    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(root.Position, target.Position)
                        pcall(function() UserInputService:SimulateMouseClick(Mouse.X, Mouse.Y) end)
                    end
                end
            end)
        end
        return
    end
    if action == "HitboxExpander" then
        Config.HitboxExpander = not Config.HitboxExpander
        if not Config.HitboxExpander then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = Vector3.new(2,1,1)
                    p.Character.Head.Transparency = 0
                    p.Character.Head.CanCollide = true
                end
            end
        end
        return
    end
    if action == "Fullbright" then
        Config.Fullbright = not Config.Fullbright
        if Config.Fullbright then Lighting.Brightness = 5 Lighting.ClockTime = 12 Lighting.GlobalShadows = false else Lighting.Brightness = 1 Lighting.GlobalShadows = true end
        return
    end
    if action == "ClickTP" then Config.ClickTP = not Config.ClickTP return end
end

-- Allow toggle of AutoFire via keybind through this function
if not ToggleFeatureByName then -- noop (shouldn't happen) end

-- === SERVER LOGIC ===
CreateButton("Server", "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)
CreateButton("Server", "Server Hop (Other server)", function()
    -- Attempt to find another server (may not work depending on permissions)
    TeleportService:Teleport(game.PlaceId)
end)

-- === CONTACT LOGIC ===
CreateButton("Contact", "Discord : le_joueur_de_berock2009", function() setclipboard("le_joueur_de_berock2009")
