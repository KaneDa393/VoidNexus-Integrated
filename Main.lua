local function GetRaw(url)
    return game:HttpGet(url:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/"))
end

local OrionLib = loadstring(GetRaw("https://github.com/KaneDa393/VoidNexus-Integrated/blob/master/library.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "VoidNexus Integrated",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "VoidNexus",
    IntroEnabled = false
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddSection({
    Name = "Features"
})

Tab:AddButton({
    Name = "Test Button",
    Callback = function()
        print("Button clicked!")
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "Orion UI is working perfectly!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

Tab:AddToggle({
    Name = "Test Toggle",
    Default = false,
    Callback = function(Value)
        print("Toggle state:", Value)
    end    
})

OrionLib:Init()
