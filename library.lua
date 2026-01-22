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

		Bliz_T = {
			Main = Color3.fromRGB(15, 15, 20), -- カスタム：深みのあるネイビーブラック
			Second = Color3.fromRGB(25, 25, 35), -- カスタム：少し明るいネイビー
			Stroke = Color3.fromRGB(0, 170, 255), -- カスタム：鮮やかなスカイブルー
			Divider = Color3.fromRGB(0, 100, 200), -- カスタム：落ち着いたブルー
			Text = Color3.fromRGB(255, 255, 255), -- カスタム：純白
			TextDark = Color3.fromRGB(180, 200, 220) -- カスタム：淡いブルーグレー
		}
	},
	SelectedTheme = "Bliz_T",
	Folder = nil,
	SaveCfg = false
}

-- Load the full Orion X source code from the provided URL
local success, source = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X")
end)

if success then
    -- Inject our Custom Theme into the source while keeping everything else original
    local ModifiedSource = source
    
    -- Replace the original OrionLib definition with our customized one
    ModifiedSource = ModifiedSource:gsub('local OrionLib = {.-}', '--')
    
    local func, err = loadstring(ModifiedSource)
    if func then
        local env = getfenv()
        env.OrionLib = OrionLib
        setfenv(func, env)
        return func()
    else
        warn("Orion X - Load Error: " .. tostring(err))
    end
else
    warn("Orion X - Failed to fetch source")
end
