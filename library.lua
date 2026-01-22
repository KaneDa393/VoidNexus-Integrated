local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

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
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

-- Safe gethui function for Delta and other executors
local function SafeGetHui()
    if gethui then return gethui() end
    if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
    return game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Feather Icons
local Icons = {}
local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/xHeptc/Lucide-Roblox/main/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. tostring(Response) .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.ResetOnSpawn = false
Orion.DisplayOrder = 2147483647

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
pcall(function()
    local GUIParent = SafeGetHui()
    Orion.Parent = GUIParent
    
    -- Remove duplicate GUIs
    for _, Interface in ipairs(GUIParent:GetChildren()) do
        if Interface.Name == Orion.Name and Interface ~= Orion then
            Interface:Destroy()
        end
    end
    
    ProtectGui(Orion)
end)

function OrionLib:IsRunning()
	return Orion and Orion.Parent ~= nil
end

local function AddConnection(Signal, Function)
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end
	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

-- Load the full Orion Library source code from the official repository
-- but with our pre-initialized Orion object and Delta fixes.
local OfficialSource = game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source")

-- Modify the source to use our pre-initialized Orion object
local ModifiedSource = OfficialSource:gsub('local Orion = Instance.new%("ScreenGui"%)', '--')
ModifiedSource = ModifiedSource:gsub('Orion.Name = "Orion"', '--')
ModifiedSource = ModifiedSource:gsub('if syn then.-else.-end', '--')
ModifiedSource = ModifiedSource:gsub('if gethui then.-else.-end', '--')
-- Ensure it doesn't try to re-initialize OrionLib
ModifiedSource = ModifiedSource:gsub('local OrionLib = {.-}', '--')

-- Execute the modified source in the current environment
local func, err = loadstring(ModifiedSource)
if func then
    -- Pass our OrionLib and Orion objects to the function
    setfenv(func, setmetatable({
        OrionLib = OrionLib,
        Orion = Orion,
        SafeGetHui = SafeGetHui,
        AddConnection = AddConnection
    }, {__index = _G}))
    func()
else
    warn("Orion Library - Failed to load source: " .. tostring(err))
end

return OrionLib
