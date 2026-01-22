-- Orion UI Library (Delta Compatible Version)
-- This version uses the official Orion source but ensures it displays on Delta

local function SafeGetHui()
    local success, result = pcall(function()
        if gethui then return gethui() end
        if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
        return game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end)
    return success and result or game:GetService("CoreGui")
end

-- Pre-initialize the ScreenGui to ensure it's placed correctly in Delta
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

-- Now load the official Orion source and inject our pre-created Orion object
local success, source = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source")
end)

if success then
    -- Inject our Delta-compatible Orion object into the source
    local ModifiedSource = source
    ModifiedSource = ModifiedSource:gsub('local Orion = Instance.new%("ScreenGui"%)', '--')
    ModifiedSource = ModifiedSource:gsub('Orion.Name = "Orion"', '--')
    ModifiedSource = ModifiedSource:gsub('if syn then.-else.-end', '--')
    ModifiedSource = ModifiedSource:gsub('if gethui then.-else.-end', '--')
    
    local func, err = loadstring(ModifiedSource)
    if func then
        -- Set the environment to include our Orion object
        local env = getfenv()
        env.Orion = Orion
        setfenv(func, env)
        return func()
    else
        warn("Orion Library - Load Error: " .. tostring(err))
    end
else
    warn("Orion Library - Failed to fetch source")
end
