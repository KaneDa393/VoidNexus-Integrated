-- Orion UI Library (Delta Compatible Version)
-- Source based on official Orion Library with Delta executor fixes

local OrionLib = {
    Flags = {},
    ThemeObjects = {},
    Connections = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default"
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Safe gethui function
local function SafeGetHui()
    local success, result = pcall(function()
        if gethui then return gethui() end
        if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
        return game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end)
    return success and result or game:GetService("CoreGui")
end

-- Icons (Silent fail)
local Icons = {}
pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Lucide-Roblox/main/src/modules/util/icons.json")).icons
end)

local function GetIcon(IconName)
    return Icons and Icons[IconName] or nil
end

-- Initialize ScreenGui
local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.ResetOnSpawn = false
Orion.DisplayOrder = 2147483647

pcall(function()
    local GUIParent = SafeGetHui()
    Orion.Parent = GUIParent
    for _, v in ipairs(GUIParent:GetChildren()) do
        if v.Name == Orion.Name and v ~= Orion then v:Destroy() end
    end
    if protectgui then protectgui(Orion) end
end)

function OrionLib:IsRunning()
    return Orion and Orion.Parent ~= nil
end

-- Utility Functions
local function AddConnection(Signal, Function)
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    return SignalConnect
end

-- The rest of the Orion Library implementation (Simplified for stability)
-- Note: This is a reconstructed version to ensure no syntax errors occur.

function OrionLib:MakeWindow(Config)
    Config.Name = Config.Name or "Orion Library"
    
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "Main"
    MainWindow.Parent = Orion
    MainWindow.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main
    MainWindow.BorderSizePixel = 0
    MainWindow.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainWindow.Size = UDim2.new(0, 600, 0, 400)
    MainWindow.Visible = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainWindow
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainWindow
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Config.Name
    Title.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainWindow
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.Size = UDim2.new(0, 150, 1, -60)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 2
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 5)
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainWindow
    ContentContainer.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second
    ContentContainer.Position = UDim2.new(0, 170, 0, 50)
    ContentContainer.Size = UDim2.new(1, -180, 1, -60)
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer

    local Tabs = {}
    
    function Tabs:AddTab(TabConfig)
        TabConfig.Name = TabConfig.Name or "Tab"
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabConfig.Name
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = TabConfig.Name
        TabButton.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
        TabButton.TextSize = 14
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabConfig.Name .. "Page"
        TabPage.Parent = ContentContainer
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, -10, 1, -10)
        TabPage.Position = UDim2.new(0, 5, 0, 5)
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 2
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = TabPage
        PageList.Padding = UDim.new(0, 5)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            TabPage.Visible = true
        end)
        
        if #TabContainer:GetChildren() == 2 then -- First tab (1 listlayout + 1 button)
            TabPage.Visible = true
        end
        
        local Elements = {}
        
        function Elements:AddButton(BtnConfig)
            BtnConfig.Name = BtnConfig.Name or "Button"
            BtnConfig.Callback = BtnConfig.Callback or function() end
            
            local Button = Instance.new("TextButton")
            Button.Name = BtnConfig.Name
            Button.Parent = TabPage
            Button.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.Font = Enum.Font.Gotham
            Button.Text = BtnConfig.Name
            Button.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
            Button.TextSize = 14
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                pcall(BtnConfig.Callback)
            end)
            
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end
        
        function Elements:AddToggle(TglConfig)
            TglConfig.Name = TglConfig.Name or "Toggle"
            TglConfig.Default = TglConfig.Default or false
            TglConfig.Callback = TglConfig.Callback or function() end
            
            local Toggled = TglConfig.Default
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = TglConfig.Name
            ToggleBtn.Parent = TabPage
            ToggleBtn.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main
            ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.Text = TglConfig.Name .. ": " .. tostring(Toggled)
            ToggleBtn.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
            ToggleBtn.TextSize = 14
            
            local TglCorner = Instance.new("UICorner")
            TglCorner.CornerRadius = UDim.new(0, 6)
            TglCorner.Parent = ToggleBtn
            
            ToggleBtn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                ToggleBtn.Text = TglConfig.Name .. ": " .. tostring(Toggled)
                pcall(TglConfig.Callback, Toggled)
            end)
            
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end
        
        return Elements
    end
    
    return Tabs
end

function OrionLib:Init()
    -- Placeholder for compatibility
end

return OrionLib
