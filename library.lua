-- Orion X Library (Custom Colored & Delta Compatible)
-- Base Source: https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local PlayerService = game:GetService("Players")
local UserService = game:GetService("UserService")

local LocalPlayer = PlayerService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		},

		Custom = {
			Main = Color3.fromRGB(15, 15, 20), -- 深みのあるネイビーブラック
			Second = Color3.fromRGB(25, 25, 35), -- 少し明るいネイビー
			Stroke = Color3.fromRGB(0, 170, 255), -- 鮮やかなスカイブルー
			Divider = Color3.fromRGB(0, 100, 200), -- 落ち着いたブルー
			Text = Color3.fromRGB(255, 255, 255), -- 純白
			TextDark = Color3.fromRGB(180, 200, 220) -- 淡いブルーグレー
		}
	},
	SelectedTheme = "Custom",
	Folder = nil,
	SaveCfg = false
}

-- Safe gethui function for Delta
local function SafeGetHui()
    local success, result = pcall(function()
        if gethui then return gethui() end
        if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
        return game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end)
    return success and result or game:GetService("CoreGui")
end

-- Feather Icons (Silent fail)
local Icons = {}
pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Lucide-Roblox/main/src/modules/util/icons.json")).icons
end)

local function GetIcon(IconName)
	if Icons and Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionCustom"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.ResetOnSpawn = false
Orion.DisplayOrder = 2147483647

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
pcall(function()
    local GUIParent = SafeGetHui()
    Orion.Parent = GUIParent
    for _, v in ipairs(GUIParent:GetChildren()) do
        if v.Name == Orion.Name and v ~= Orion then v:Destroy() end
    end
    ProtectGui(Orion)
end)

-- Load the full Orion X source code from the provided URL
-- but with our pre-initialized Orion object and Custom Theme.
local success, source = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X")
end)

if success then
    -- Inject our Delta-compatible Orion object and Custom Theme into the source
    local ModifiedSource = source
    -- Remove the original Orion initialization
    ModifiedSource = ModifiedSource:gsub('local Orion = Instance.new%("ScreenGui"%)', '--')
    ModifiedSource = ModifiedSource:gsub('Orion.Name = "OrionBliz"', '--')
    ModifiedSource = ModifiedSource:gsub('Orion.Parent = GUIParent', '--')
    ModifiedSource = ModifiedSource:gsub('getgenv%(%).gethui = function%(%) return game.CoreGui end', '--')
    
    -- Inject our OrionLib configuration
    ModifiedSource = ModifiedSource:gsub('local OrionLib = {.-}', '--')
    
    local func, err = loadstring(ModifiedSource)
    if func then
        local env = getfenv()
        env.OrionLib = OrionLib
        env.Orion = Orion
        env.SafeGetHui = SafeGetHui
        setfenv(func, env)
        func()
    else
        warn("Orion X - Load Error: " .. tostring(err))
    end
else
    warn("Orion X - Failed to fetch source")
end

return OrionLib
