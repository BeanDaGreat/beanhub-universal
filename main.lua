-- BeanHub Universal • Rayfield Minimal
-- Author: BeanDaGreat
-- Version: 1.0

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "BeanHub Universal • Rayfield",
    LoadingTitle = "BeanHub Universal",
    LoadingSubtitle = "by BeanDaGreat",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BeanHubUniversal",
        FileName = "UniversalConfig"
    }
})

-- Create empty tabs
local MovementTab = Window:CreateTab("Movement", 4483345998)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local CombatTab = Window:CreateTab("Combat", 4483345998)
local UtilitiesTab = Window:CreateTab("Utilities", 4483345998)
local InfoTab = Window:CreateTab("Info", 4483345998)

-- Optional: Add placeholder paragraphs
MovementTab:CreateParagraph({Title = "Movement", Content = "No features yet."})
VisualsTab:CreateParagraph({Title = "Visuals", Content = "No features yet."})
CombatTab:CreateParagraph({Title = "Combat", Content = "No features yet."})
UtilitiesTab:CreateParagraph({Title = "Utilities", Content = "No features yet."})
InfoTab:CreateParagraph({Title = "Info", Content = "No features yet."})
