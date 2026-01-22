local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local VoidNexusLib = {
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
		RedPink = {
			Main = Color3.fromRGB(20, 0, 5),
			Second = Color3.fromRGB(40, 0, 10),
			Stroke = Color3.fromRGB(255, 20, 147),
			Divider = Color3.fromRGB(220, 20, 60),
			Text = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(255, 182, 193)
		},
		PurpleWhite = {
			Main = Color3.fromRGB(30, 0, 40), -- Dark Purple
			Second = Color3.fromRGB(50, 0, 70), -- Purple
			Stroke = Color3.fromRGB(200, 150, 255), -- Light Purple
			Divider = Color3.fromRGB(255, 255, 255), -- White
			Text = Color3.fromRGB(255, 255, 255), -- White
			TextDark = Color3.fromRGB(220, 200, 255) -- Very Light Purple
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

	-- Icons disabled for stability
	local function GetIcon(IconName)
		return nil
	end

local useStudio = RunService:IsStudio() or false
local VoidNexusGUI = Instance.new("ScreenGui")
VoidNexusGUI.Name = "VoidNexusUI"
VoidNexusGUI.ResetOnSpawn = false
VoidNexusGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
VoidNexusGUI.DisplayOrder = 999

-- Improved gethui function for better executor compatibility
local function SafeGetHui()
    if gethui then
        local success, result = pcall(gethui)
        if success and result then
            return result
        end
    end
    -- Fallback to CoreGui or PlayerGui
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        return coreGui
    end
    return game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUIParent = SafeGetHui()
VoidNexusGUI.Parent = GUIParent
pcall(ProtectGui, VoidNexusGUI)

-- Remove duplicate GUIs
pcall(function()
    for _, Interface in ipairs(GUIParent:GetChildren()) do
        if Interface.Name == VoidNexusGUI.Name and Interface ~= VoidNexusGUI then
            Interface:Destroy()
        end
    end
end)

function VoidNexusLib:IsRunning()
    return VoidNexusGUI and VoidNexusGUI.Parent ~= nil
end

local function AddConnection(Signal, Function)
    local SignalConnect = Signal:Connect(Function)
    table.insert(VoidNexusLib.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
	while (VoidNexusLib:IsRunning()) do
		wait()
	end
	for _, Connection in next, VoidNexusLib.Connections do
		Connection:Disconnect()
	end
end)

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end    

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	VoidNexusLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = VoidNexusLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not VoidNexusLib.ThemeObjects[Type] then
		VoidNexusLib.ThemeObjects[Type] = {}
	end    
	table.insert(VoidNexusLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = VoidNexusLib.Themes[VoidNexusLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(VoidNexusLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = VoidNexusLib.Themes[VoidNexusLib.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if VoidNexusLib.Flags[a] then
			spawn(function() 
				if VoidNexusLib.Flags[a].Type == "Colorpicker" then
					VoidNexusLib.Flags[a]:Set(UnpackColor(b))
				else
					VoidNexusLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("VoidNexus Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(VoidNexusLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(VoidNexusLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local freeMouse = Create("TextButton", {Name = "FMouse", Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = "", Position = UDim2.new(0,0,0,0), Modal = true, Parent = VoidNexusGUI, Visible = false})
local mouselock = false

local function UnlockMouse(Value)
	if Value then
		mouselock = true
		task.spawn(function() 
			while mouselock do
				UserInputService.MouseIconEnabled = Value
				freeMouse.Visible = Value
				task.wait()
			end
			UserInputService.MouseIconEnabled = false
			freeMouse.Visible = false
		end)
	else
		mouselock = false
	end
end

CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)

CreateElement("AspectRatio", function()
	return Create("UIAspectRatioConstraint")
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {Color = Color or Color3.fromRGB(255, 255, 255), Thickness = Thickness or 1})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)})
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {PaddingBottom = UDim.new(0, Bottom or 4), PaddingLeft = UDim.new(0, Left or 4), PaddingRight = UDim.new(0, Right or 4), PaddingTop = UDim.new(0, Top or 4)})
end)

CreateElement("TFrame", function()
	return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})})
end)

CreateElement("ScrollFrame", function(Color, Offset)
	return Create("ScrollingFrame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ScrollBarThickness = Offset or 4, CanvasSize = UDim2.new(0, 0, 0, 0)})
end)

CreateElement("Label", function(Text, Size)
	return Create("TextLabel", {Text = Text or "Label", TextSize = Size or 14, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left})
end)

CreateElement("Button", function()
	return Create("TextButton", {Text = "", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5})
end)

CreateElement("Image", function(Image)
	return Create("ImageLabel", {Image = Image or "", BackgroundTransparency = 1, BorderSizePixel = 0})
end)

CreateElement("TextBox", function(Text, Size)
	return Create("TextBox", {Text = Text or "", TextSize = Size or 14, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
end)

function VoidNexusLib:MakeNotification(NotificationConfig)
	NotificationConfig = NotificationConfig or {}
	NotificationConfig.Name = NotificationConfig.Name or "Notification"
	NotificationConfig.Content = NotificationConfig.Content or "Content"
	NotificationConfig.Time = NotificationConfig.Time or 5

	local Notification = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
		Parent = VoidNexusGUI,
		Size = UDim2.new(0, 250, 0, 60),
		Position = UDim2.new(1, 20, 1, -80),
		ZIndex = 100
	}), {
		AddThemeObject(MakeElement("Stroke"), "Stroke"),
		SetProps(MakeElement("Label", NotificationConfig.Name, 14), {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			Font = Enum.Font.GothamBold
		}),
		AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Content, 12), {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 25)
		}), "TextDark")
	}), "Main")

	TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 1, -80)}):Play()
	task.delay(NotificationConfig.Time, function()
		TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -80)}):Play()
		wait(0.5)
		Notification:Destroy()
	end)
end

function VoidNexusLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local UIHidden = false
	
	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "VoidNexus Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	WindowConfig.IntroEnabled = WindowConfig.IntroEnabled == nil and true or WindowConfig.IntroEnabled
	WindowConfig.FreeMouse = WindowConfig.FreeMouse or false
	WindowConfig.KeyToOpenWindow = WindowConfig.KeyToOpenWindow or "RightShift"
	WindowConfig.IntroText = WindowConfig.IntroText or "VoidNexus Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	
	VoidNexusLib.Folder = WindowConfig.ConfigFolder
	VoidNexusLib.SaveCfg = WindowConfig.SaveConfig
	if WindowConfig.SaveConfig and not isfolder(WindowConfig.ConfigFolder) then
		makefolder(WindowConfig.ConfigFolder)
	end

	if WindowConfig.FreeMouse then UnlockMouse(true) end

	local MobileOpenButton = SetChildren(SetProps(MakeElement("Button"), {
		BackgroundTransparency = 0, Parent = VoidNexusGUI, Text = "Open", TextScaled = true, TextSize = 14,
		TextColor3 = Color3.new(0, 0, 0), BackgroundColor = BrickColor.new(0, 0, 0),
		TextStrokeColor3 = Color3.new(255, 255, 255), TextStrokeTransparency = 0,
		Size = UDim2.new(0.035, 0, 0.035, 0), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Visible = false, Font = Enum.Font.GothamBold
	}), {MakeElement("Corner", 0.25), SetProps(MakeElement("AspectRatio"), {DominantAxis = 0, AspectRatio = 0.986, AspectType = 1})})

	MakeDraggable(MobileOpenButton, MobileOpenButton)

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {MakeElement("List"), MakeElement("Padding", 8, 0, 0, 8)}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {Position = UDim2.new(0, 9, 0, 6), Size = UDim2.new(0, 18, 0, 18)}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {Position = UDim2.new(0, 9, 0, 6), Size = UDim2.new(0, 18, 0, 18), Name = "Ico"}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50)})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50), Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0)}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0)}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0)}), "Stroke"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 1, -50)}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1)}), "Stroke"), 
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 10, 0.5, 0)}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. (LocalPlayer and LocalPlayer.UserId or 0) .."&width=420&height=420&format=png"), {Size = UDim2.new(1, 0, 1, 0)}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1, 0, 1, 0)}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			AddThemeObject(SetProps(MakeElement("Label", (LocalPlayer and LocalPlayer.DisplayName or "Player"), WindowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13), Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold, ClipsDescendants = true
			}), "Text")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {Size = UDim2.new(1, -30, 2, 0), Position = UDim2.new(0, 25, 0, -24), Font = Enum.Font.GothamBlack, TextSize = 20}), "Text")
	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1)}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = VoidNexusGUI, Position = UDim2.new(0.5, -307, 0.5, -172), Size = UDim2.new(0, 615, 0, 344), ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 50), Name = "TopBar"}), {
			WindowName, WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -90, 0, 10)}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"), AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0)}), "Stroke"), 
				CloseBtn, MinimizeBtn
			}), "Second"), 
		}),
		DragPoint, WindowStuff
	}), "Main")

	MakeDraggable(DragPoint, MainWindow)

	local function LoadSequence()
		pcall(function()
			MainWindow.Visible = false
			local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {Parent = VoidNexusGUI, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.4, 0), Size = UDim2.new(0, 28, 0, 28), ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 1})
			local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {Parent = VoidNexusGUI, Size = UDim2.new(1, 0, 1, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 19, 0.5, 0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextTransparency = 1})
			TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
			wait(0.8)
			TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
			wait(0.3)
			TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			wait(2)
			TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			wait(0.3)
			LoadSequenceLogo:Destroy()
			LoadSequenceText:Destroy()
		end)
		-- Always show the main window, even if intro fails
		MainWindow.Visible = true
	end 

	if WindowConfig.IntroEnabled then 
		LoadSequence() 
	else
		MainWindow.Visible = true
	end	

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {Name = "Tab", Icon = ""}
			local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 0, 30), Parent = TabHolder}), {
				AddThemeObject(SetProps(MakeElement("Image", ""), {Visible = false, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 10, 0.5, 0), ImageTransparency = 1, Name = "Ico"}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"}), "Text")
			})

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {Size = UDim2.new(1, -150, 1, -50), Position = UDim2.new(0, 150, 0, 50), Parent = MainWindow, Visible = false, Name = "ItemContainer"}), {MakeElement("List", 0, 6), MakeElement("Padding", 15, 10, 10, 15)}), "Divider")
		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30) end)

		if FirstTab then FirstTab = false; Container.Visible = true; TabFrame.Ico.ImageTransparency = 0; TabFrame.Title.TextTransparency = 0 end	

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, v in next, MainWindow:GetChildren() do if v.Name == "ItemContainer" then v.Visible = false end end
			for _, v in next, TabHolder:GetChildren() do if v:IsA("TextButton") then v.Ico.ImageTransparency = 0.4; v.Title.TextTransparency = 0.4 end end
			Container.Visible = true; TabFrame.Ico.ImageTransparency = 0; TabFrame.Title.TextTransparency = 0
		end)

		local ElementFunction = {}
		function ElementFunction:AddSection(SectionConfig)
			SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1, 0, 0, 20), Parent = Container}), {AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name or "Section", 13), {Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold}), "TextDark")})
		end

			function ElementFunction:AddButton(ButtonConfig)
				local Button = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {Size = UDim2.new(1, 0, 0, 35), Parent = Container}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), Name = "Btn"}), AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name or "Button", 14), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0)}), "Text")}), "Second")
				AddConnection(Button.Btn.MouseButton1Click, ButtonConfig.Callback or function() end)
			end

			function ElementFunction:AddToggle(ToggleConfig)
				local Toggled = ToggleConfig.Default or false
				local Toggle = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {Size = UDim2.new(1, 0, 0, 35), Parent = Container}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), Name = "Btn"}), AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name or "Toggle", 14), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0)}), "Text"), AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SetProps(MakeElement("Frame", Color3.fromRGB(255, 255, 255)), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5), Visible = Toggled, Name = "Check"}, {MakeElement("Corner", 0, 2)})}), "Main")}), "Second")
				AddConnection(Toggle.Btn.MouseButton1Click, function() Toggled = not Toggled; Toggle.Frame.Check.Visible = Toggled; if ToggleConfig.Callback then ToggleConfig.Callback(Toggled) end end)
			end

		function ElementFunction:AddTextbox(TextboxConfig)
			local Textbox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {Size = UDim2.new(1, 0, 0, 35), Parent = Container}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name or "Textbox", 14), {Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 10, 0, 0)}), "Text"), AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {Size = UDim2.new(1, -120, 0, 25), Position = UDim2.new(0, 110, 0.5, -12)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SetProps(MakeElement("TextBox", TextboxConfig.Default or "", 13), {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Name = "Input"})}), "Main")}), "Second")
			AddConnection(Textbox.Frame.Input.FocusLost, function() if TextboxConfig.Callback then TextboxConfig.Callback(Textbox.Frame.Input.Text) end end)
		end
		return ElementFunction
	end
	return TabFunction
end

function VoidNexusLib:Destroy()
	VoidNexusGUI:Destroy()
end

function VoidNexusLib:Init()
	-- Initialization logic if needed
end

return VoidNexusLib
