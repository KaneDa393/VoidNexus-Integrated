
-- Obfuscated by VoidNexus
local _ = function(...) return ... end
local LIBRARY_URL = "https://raw.githubusercontent.com/KaneDa393/VoidNexus-Integrated/master/library.lua"
local MAIN_URL = "https://raw.githubusercontent.com/KaneDa393/VoidNexus-Integrated/master/Main.lua"
local VoidNexusLib = loadstring(game:HttpGet(LIBRARY_URL))()
VoidNexusLib.SelectedTheme = "RedPink"
local VALID_KEYS = {"test"}
local DISCORD_LINK = "https://discord.gg/yourserver"
local SAVE_FILE = "VoidNexusKey.txt"
local function ValidateKey(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then return true end
    end
    return false
end
local function SaveKey(key)
    writefile(SAVE_FILE, key)
end
local function LoadKey()
    if isfile(SAVE_FILE) then
        return readfile(SAVE_FILE)
    end
    return nil
end
local savedKey = LoadKey()
if savedKey and ValidateKey(savedKey) then
    VoidNexusLib:MakeNotification({
        Name = "Auto Login",
        Content = "Saved key found. Logging in to VoidNexus...",
        Time = 3
    })
    wait(1)
    loadstring(game:HttpGet(MAIN_URL))()
    return
end
local Window = VoidNexusLib:MakeWindow({
    Name = "VoidNexus Key System",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "VoidNexus",
    KeyToOpenWindow = "M"
})
local AuthTab = Window:MakeTab({
    Name = "Authentication",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
AuthTab:AddSection({
    Name = "Key Verification"
})
local inputKey = ""
AuthTab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = false,
    Callback = function(v)
        inputKey = v
    end
})
local shouldSave = true
AuthTab:AddToggle({
    Name = "Save Key",
    Default = true,
    Callback = function(v)
        shouldSave = v
    end
})
AuthTab:AddButton({
    Name = "Verify & Login",
    Callback = function()
        if ValidateKey(inputKey) then
            if shouldSave then
                SaveKey(inputKey)
            end
            VoidNexusLib:MakeNotification({
                Name = "Access Granted",
                Content = "Key verified! Loading VoidNexus...",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            wait(1.5)
            loadstring(game:HttpGet(MAIN_URL))()
        else
            VoidNexusLib:MakeNotification({
                Name = "Access Denied",
                Content = "The key you entered is incorrect.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})
local GetKeyTab = Window:MakeTab({
    Name = "Get Key",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
GetKeyTab:AddSection({
    Name = "Discord Server"
})
GetKeyTab:AddParagraph("Instructions","Join our Discord server to get your free access key. Click the button below to copy the link.")
GetKeyTab:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard(DISCORD_LINK)
        VoidNexusLib:MakeNotification({
            Name = "Copied",
            Content = "Discord link copied to clipboard.",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
SettingsTab:AddSection({
    Name = "Key Management"
})
SettingsTab:AddButton({
    Name = "Delete Saved Key",
    Callback = function()
        if isfile(SAVE_FILE) then
            delfile(SAVE_FILE)
            VoidNexusLib:MakeNotification({
                Name = "Deleted",
                Content = "Saved key has been removed.",
                Time = 3
            })
        else
            VoidNexusLib:MakeNotification({
                Name = "Error",
                Content = "No saved key found.",
                Time = 3
            })
        end
    end
})
SettingsTab:AddSection({
    Name = "UI Settings"
})
SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        VoidNexusLib:Destroy()
    end
})
VoidNexusLib:Init()
print("VoidNexus Key System Loaded")
