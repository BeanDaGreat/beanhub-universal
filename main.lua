-- AMNESIA v3 Minimal Template
-- Cleaned and simplified for later configuration

print("Bean Hub Loaded Made By beandagreat. in discord")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WINDOW_SIZE = Vector2.new(760, 520)
local SCRIPT_NAME = "BeanHub"
local SCRIPT_VERSION = "v2.6"

local Theme = {
    bg = Color3.fromRGB(12,12,16),
    panel = Color3.fromRGB(22,22,30),
    header = Color3.fromRGB(18,18,26),
    accent = Color3.fromRGB(88,101,242),
    text = Color3.fromRGB(235,238,243),
    textDim = Color3.fromRGB(150,155,170),
    tab = Color3.fromRGB(32,32,46),
    tabActive = Color3.fromRGB(88,101,242),
    separator = Color3.fromRGB(40,42,58),
}

-- Utility: create instance
local function create(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

-- Kill script and GUI
local function KillScript()
    local gui = PlayerGui:FindFirstChild("amnesia_v3")
    if gui then gui:Destroy() end
    if script and script.Parent then script:Destroy() end
end

-- Close on Delete key
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        KillScript()
    end
end)

-- Root GUI
local RootGui = create("ScreenGui", {
    Name = "BeanHubUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

-- Main window + shadow (simple)
local MainWindow = create("Frame", {
    Name = "MainWindow",
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
    Size = UDim2.new(0, WINDOW_SIZE.X, 0, WINDOW_SIZE.Y),
    Position = UDim2.new(0, 40, 0, 80),
}, RootGui)
create("UICorner", {CornerRadius = UDim.new(0,12)}, MainWindow)

local Header = create("Frame", {
    BackgroundColor3 = Theme.header,
    Size = UDim2.new(1,0,0,62),
    Parent = MainWindow,
})
create("UICorner", {CornerRadius = UDim.new(0,12)}, Header)

create("TextLabel", {
    Text = SCRIPT_NAME,
    Font = Enum.Font.GothamBlack,
    TextSize = 26,
    TextColor3 = Theme.text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0,16,0,8),
    Size = UDim2.new(0.6,0,0,28),
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

create("TextLabel", {
    Text = SCRIPT_VERSION,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Theme.textDim,
    BackgroundTransparency = 1,
    Position = UDim2.new(0,16,0,34),
    Size = UDim2.new(0.6,0,0,22),
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local CloseButton = create("TextButton", {
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.textDim,
    BackgroundColor3 = Color3.fromRGB(24,24,32),
    BorderSizePixel = 0,
    Size = UDim2.new(0,26,0,26),
    Position = UDim2.new(1,-34,0,10),
    AutoButtonColor = false,
}, Header)
create("UICorner", {CornerRadius = UDim.new(1,0)}, CloseButton)
CloseButton.MouseButton1Click:Connect(KillScript)

-- Sidebar and content
local Sidebar = create("Frame", {
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,0,62),
    Size = UDim2.new(0,160,1,-62),
}, MainWindow)
local SidebarList = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0,10,0,10),
    Size = UDim2.new(1,-20,1,-20),
}, Sidebar)
create("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, SidebarList)

local ContentHolder = create("Frame", {
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
    Position = UDim2.new(0,160,0,62),
    Size = UDim2.new(1,-160,1,-62),
}, MainWindow)
create("UICorner", {CornerRadius = UDim.new(0,12)}, ContentHolder)

local Content = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0,12,0,12),
    Size = UDim2.new(1,-24,1,-24),
}, ContentHolder)

-- Tab factory
local Tabs = {}
local function createTabButton(name)
    local btn = create("TextButton", {
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = Theme.textDim,
        BackgroundColor3 = Theme.tab,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,40),
        AutoButtonColor = false,
    }, SidebarList)
    create("UICorner", {CornerRadius = UDim.new(0,10)}, btn)
    return btn
end

local function createPage()
    local page = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Visible = false,
        Parent = Content,
    })
    local layout = create("UIListLayout", {Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    layout.FillDirection = Enum.FillDirection.Vertical
    return page
end

-- Define tabs
local tabNames = {"Player","Visuals","Info","Configs"}
for _, name in ipairs(tabNames) do
    Tabs[name] = { Button = createTabButton(name), Page = createPage() }
end

local function setTabActive(name)
    for k,v in pairs(Tabs) do
        if k == name then
            v.Button.BackgroundColor3 = Theme.tabActive
            v.Button.TextColor3 = Theme.text
            v.Page.Visible = true
        else
            v.Button.BackgroundColor3 = Theme.tab
            v.Button.TextColor3 = Theme.textDim
            v.Page.Visible = false
        end
    end
end

for name, data in pairs(Tabs) do
    data.Button.MouseButton1Click:Connect(function() setTabActive(name) end)
end
setTabActive("Player")

-- UI factories (simple)
local function createSlider(parent, title, minVal, maxVal, defaultVal)
    local frame = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,42)}, parent)
    create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35,0,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local valueBox = create("TextBox", {
        Text = tostring(defaultVal),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.text,
        BackgroundColor3 = Theme.tab,
        BorderSizePixel = 0,
        Size = UDim2.new(0,60,0,28),
        Position = UDim2.new(1,-150,0.5,-14),
        ClearTextOnFocus = false,
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0,8)}, valueBox)

    -- Minimal slider visual (no dragging math here)
    local sliderBg = create("Frame", {
        BackgroundColor3 = Theme.separator,
        BorderSizePixel = 0,
        Size = UDim2.new(0.50,-10,0,6),
        Position = UDim2.new(0.29,0,0.5,-3),
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(1,0)}, sliderBg)

    local current = defaultVal
    local function Set(v)
        v = math.clamp(tonumber(v) or defaultVal, minVal, maxVal)
        current = v
        valueBox.Text = tostring(v)
    end

    valueBox.FocusLost:Connect(function()
        Set(valueBox.Text)
    end)

    Set(defaultVal)
    return { Get = function() return current end, Set = Set }
end

local function createToggle(parent, title)
    local frame = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,36)}, parent)
    create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6,0,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local btn = create("TextButton", {
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.text,
        BackgroundColor3 = Theme.tab,
        BorderSizePixel = 0,
        Size = UDim2.new(0,80,0,28),
        Position = UDim2.new(1,-90,0.5,-14),
        AutoButtonColor = false,
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0,8)}, btn)

    btn.MouseButton1Click:Connect(function()
        local on = btn.Text == "OFF"
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Theme.accent or Theme.tab
    end)

    return btn
end

local function createColorPicker(parent, title, defaultColor)
    local frame = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40)}, parent)
    local button = create("TextButton", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.text,
        BackgroundColor3 = Theme.tab,
        BorderSizePixel = 0,
        Size = UDim2.new(0,220,0,32),
        AutoButtonColor = false,
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0,8)}, button)

    local colorBox = create("Frame", {
        BackgroundColor3 = defaultColor or Theme.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0,22,0,22),
        Position = UDim2.new(1,-28,0.5,-11),
        Parent = button,
    })
    create("UICorner", {CornerRadius = UDim.new(0,6)}, colorBox)

    -- Simple toggle popup (no HSV picker)
    local popup = create("Frame", {
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0,160,0,60),
        Visible = false,
        Position = UDim2.new(0,0,1,6),
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0,10)}, popup)

    local preset = create("TextButton", {
        Text = "Set Random",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.text,
        BackgroundColor3 = Theme.tab,
        Size = UDim2.new(1,-10,0,28),
        Position = UDim2.new(0,5,0,16),
        Parent = popup,
    })
    create("UICorner", {CornerRadius = UDim.new(0,6)}, preset)

    preset.MouseButton1Click:Connect(function()
        local c = Color3.fromHSV(math.random(), 0.8, 0.9)
        colorBox.BackgroundColor3 = c
        popup.Visible = false
    end)

    button.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
    end)

    return {
        Get = function() return colorBox.BackgroundColor3 end,
        Set = function(c) colorBox.BackgroundColor3 = c end
    }
end

-- Example controls on Player tab
local speedSlider = createSlider(Tabs.Player.Page, "Speed", 0, 72, 16)
local jumpSlider  = createSlider(Tabs.Player.Page, "Jump", 0, 200, 50)
local shiftToggle = createToggle(Tabs.Player.Page, "Shift run")

-- Visuals tab examples
local espToggle = createToggle(Tabs.Visuals.Page, "ESP")
local espColor = createColorPicker(Tabs.Visuals.Page, "ESP Color", Color3.fromRGB(255,0,0))

-- Info box
local infoBox = create("Frame", {
    BackgroundColor3 = Theme.tab,
    BorderSizePixel = 0,
    Size = UDim2.new(1,-10,0,90),
    Parent = Tabs.Info.Page,
})
create("UICorner", {CornerRadius = UDim.new(0,10)}, infoBox)
create("TextLabel", {
    Text = "Info\nTime: --:--\nExecutor: --",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Theme.text,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-20,1,-10),
    Position = UDim2.new(0,10,0,5),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, infoBox)

-- Config system (simple in-memory + optional file save)
local function BuildConfigTable()
    return {
        speed = speedSlider.Get(),
        jump = jumpSlider.Get(),
        shift = shiftToggle.Text == "ON",
        esp = espToggle.Text == "ON",
        espColor = {espColor.Get().R, espColor.Get().G, espColor.Get().B},
    }
end

local function ApplyConfigTable(cfg)
    if not cfg then return end
    if cfg.speed then speedSlider.Set(cfg.speed) end
    if cfg.jump then jumpSlider.Set(cfg.jump) end
    local function applyToggle(btn, val)
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Theme.accent or Theme.tab
    end
    applyToggle(shiftToggle, cfg.shift)
    applyToggle(espToggle, cfg.esp)
    if cfg.espColor then
        espColor.Set(Color3.new(cfg.espColor[1], cfg.espColor[2], cfg.espColor[3]))
    end
end

-- Optional file helpers (use only if executor supports writefile/readfile)
local function safeWrite(path, data)
    if type(writefile) ~= "function" then return false end
    local ok, err = pcall(function() writefile(path, data) end)
    return ok, err
end
local function safeRead(path)
    if type(readfile) ~= "function" then return nil end
    local ok, content = pcall(function() return readfile(path) end)
    if ok then return content end
    return nil
end

local CONFIG_PATH = "amnesia_config.json"
local function SaveConfig()
    local cfg = BuildConfigTable()
    local encoded = HttpService:JSONEncode(cfg)
    safeWrite(CONFIG_PATH, encoded)
end

local function LoadConfig()
    local raw = safeRead(CONFIG_PATH)
    if raw then
        local ok, cfg = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and cfg then ApplyConfigTable(cfg) end
    end
end

-- Config UI (simple)
local cfgRow = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40)}, Tabs.Configs.Page)
create("TextLabel", {
    Text = "Local Config",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.text,
    BackgroundTransparency = 1,
    Size = UDim2.new(0.4,0,1,0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, cfgRow)

local saveBtn = create("TextButton", {
    Text = "Save",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Theme.text,
    BackgroundColor3 = Theme.tab,
    BorderSizePixel = 0,
    Size = UDim2.new(0,70,0,30),
    Position = UDim2.new(0.45,0,0.5,-15),
}, cfgRow)
create("UICorner", {CornerRadius = UDim.new(0,8)}, saveBtn)
saveBtn.MouseButton1Click:Connect(SaveConfig)

local loadBtn = create("TextButton", {
    Text = "Load",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Theme.text,
    BackgroundColor3 = Theme.tab,
    BorderSizePixel = 0,
    Size = UDim2.new(0,70,0,30),
    Position = UDim2.new(0.62,0,0.5,-15),
}, cfgRow)
create("UICorner", {CornerRadius = UDim.new(0,8)}, loadBtn)
loadBtn.MouseButton1Click:Connect(LoadConfig)

-- Placeholder hooks for game logic
-- TODO: Add your gameplay code here. Example pattern:
-- local function ApplyPlayerSettings()
--     -- Example: set humanoid properties if you want
--     -- local char = LocalPlayer.Character
--     -- if char and char:FindFirstChild("Humanoid") then
--     --     char.Humanoid.WalkSpeed = speedSlider.Get()
--     --     char.Humanoid.JumpPower = jumpSlider.Get()
--     -- end
-- end
-- You can call ApplyPlayerSettings() on events or a loop with a safe wait.

-- Minimal loop to update info label (non-invasive)
local infoLabel = infoBox:FindFirstChildOfClass("TextLabel")
task.spawn(function()
    while true do
        if infoLabel then
            local t = os.date("*t")
            infoLabel.Text = string.format("Time: %02d:%02d:%02d\nDate: %02d.%02d.%04d\nExecutor: %s",
                t.hour, t.min, t.sec, t.day, t.month, t.year, "Template")
        end
        task.wait(1)
    end
end)

-- End of template
