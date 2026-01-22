--[[
	==== VOID NEXUS ====
		Main Script
		Based on Suisei Hub
]]

local VoidNexusLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KaneDa393/VoidNexus-Integrated/master/library.lua"))()
VoidNexusLib.SelectedTheme = "PurpleWhite"
local service = setmetatable({}, {
	__index = function(self, k)
		local s = game:GetService(k)
		rawset(self, k, s)
		return s
	end,
})

local loop = Instance.new("BindableEvent")
service.RunService.Heartbeat:Connect(function(dt)
	loop:Fire(dt)
end)

do
	--// USELESS UTILS
	function hn(func, ...)
		if (service.RunService:IsStudio()) then print'hn call' end
		if (coroutine.status(task.spawn(hn, func, ...)) == "dead") then return end
		return pcall(func, ...)
	end
	function sn(depth, func, ...)
		if (depth >= 80) then return pcall(func, ...) end
		task.defer(sn, depth + 1, func, ...)
	end

	--// FUNCTIONS/VARIABLES/UTILS
	local get = game.FindFirstChild
	local cget = game.FindFirstChildOfClass
	local waitc = game.WaitForChild
	local function getLocalPlayer()
		return service.Players.LocalPlayer
	end
	local function getMouse()
		return getLocalPlayer():GetMouse()
	end
	local function getLookTarget()
		return getMouse().Target
	end
	local function getLocalChar()
		return getLocalPlayer().Character
	end
	local function getLocalRoot()
		if (not getLocalChar()) then return end
		return get(getLocalChar(), "HumanoidRootPart") or get(getLocalChar(), "Torso")
	end
	local function getLocalHum()
		if (not getLocalChar()) then return end
		return cget(getLocalChar(), "Humanoid")
	end
	local function Velocity(part, value)
		local b = Instance.new("BodyVelocity")
		b.MaxForce = Vector3.one * math.huge
		b.Velocity = value
		b.Parent = part
		task.spawn(task.delay, 1, game.Destroy, b)
	end
	local function SetNetworkOwner(part)
		service.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, getLocalRoot().CFrame)
	end
	local function GetNearParts(origin, radius)
		return workspace:GetPartBoundsInRadius(origin, radius)
	end
	local function IsInRadius(part, origin, radius)
		if ((part.Position - origin).Magnitude <= radius) then
			return true
		end
		return false
	end
	local function MoveTo(part, x)
		for _, v in ipairs(part.Parent:GetDescendants()) do
			if (v:IsA("BasePart")) then
				v.CanCollide = false
			end
		end
		local pos = typeof(x) == "CFrame" and x.Position or x
		local b = Instance.new("BodyPosition")
		b.MaxForce = Vector3.one * math.huge
		b.Position = pos
		b.P = 2e4
		b.D = 5e3
		b.Parent = part
		task.spawn(function()
			b.ReachedTarget:Wait()
			pcall(game.Destroy, b)
			for _, v in ipairs(part.Parent:GetDescendants()) do
				if (v:IsA("BasePart")) then
					v.CanCollide = true
				end
			end
		end)
	end
	local function anchor(part)
		local pos = getLocalRoot().CFrame
		local tpos = part.CFrame
		for _ = 1, 2 do
			getLocalRoot().CFrame = part.CFrame
			SetNetworkOwner(part)
			task.spawn(function()
				task.wait(.5)
				for _ = 1, 2 do
					task.wait(.5)
					SetNetworkOwner(part)
					local p = Instance.new("BodyPosition")
					p.Position = part.CFrame.Position
					p.MaxForce = Vector3.one * math.huge
					p.Parent = part
					local r = Instance.new("BodyGyro")
					r.CFrame = tpos
					r.MaxTorque = Vector3.one * math.huge
					r.Parent = part
				end
			end)
			task.wait()
		end
		getLocalRoot().CFrame = pos
	end
	local function lag(value)
		for _ = 1, value do
			service.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer()
		end
	end
	local function ping(value)
		for _ = 1, value do
			service.ReplicatedStorage.GrabEvents.ExtendGrabLine:FireServer(string.rep("Balls Balls Balls Balls", value))
		end
	end
	local function createLine(part)
		service.ReplicatedStorage.GrabEvents.CreateGrabLine:FireServer(part, CFrame.identity)
	end
	local function ungrab(part)
		service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(part)
	end
	local function kickGrab(player)
		local char = player.Character
		if (not char) then return end
		local root = get(char, "HumanoidRootPart")
		local fpp = get(root, "FirePlayerPart")
		fpp.Size = Vector3.new(4.5, 5.5, 4.5)
		fpp.CollisionGroup = "1"
		fpp.CanQuery = true
	end
	local function getInv()
		return get(workspace, getLocalPlayer().Name .. "SpawnedInToys")
	end
	local function spawntoy(name, cframe, vector3)
		local toy = service.ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(table.unpack({
			[1] = name,
			[2] = cframe,
			[3] = vector3 or Vector3.zero
		}))
		local r = get(getInv(), name)
		return r
	end
	local function destroyToy(model)
		service.ReplicatedStorage.MenuToys.DestroyToy:FireServer(model)
	end
	curAntiDetectPart = nil
	local function AntiDetect()
		repeat task.wait() until getLocalChar() and getLocalRoot()
		local exists = false
		if (getInv()) then
			for _, v in pairs(getInv():GetChildren()) do
				if (v.Name == "NinjaShuriken") then
					exists = true
					if (get(v.StickyPart, "PartOwner")) then destroyToy(v) end
					if (get(v.SoundPart, "PartOwner")) then destroyToy(v) end
					if (v.StickyPart.StickyWeld.Part1 and v.StickyPart.StickyWeld.Part1:IsDescendantOf(getLocalChar())) then return end
					destroyToy(v)
					break
				end
			end
		end
		if (not exists) then
			curAntiDetectPart = spawntoy("NinjaShuriken", getLocalRoot().CFrame)
			repeat task.wait() until (get(getInv(), "NinjaShuriken"))
			SetNetworkOwner(curAntiDetectPart.SoundPart)
			curAntiDetectPart.SoundPart.CFrame = getLocalRoot().CFrame + Vector3.new(0, .5, 0)
		end
		repeat task.wait() until (get(getInv(), "NinjaShuriken"))
		curAntiDetectPart.SoundPart.CFrame = getLocalRoot().CFrame + Vector3.new(0, .5, 0)
		local w = Instance.new("WeldConstraint")
		w.Part0 = curAntiDetectPart.SoundPart
		w.Part1 = getLocalRoot()
		w.Parent = getLocalRoot()
	end
	local IsSafespot = false
	local function Safespot()
		if (not IsSafespot) then
			local p = Instance.new("Part", workspace)
			p.Material = Enum.Material.Grass
			p.Transparency = .5
			p.Anchored = true
			p.CFrame = CFrame.new(1e4, 1e4, 1e4)
			p.Size = Vector3.new(128, 4, 128)
			IsSafespot = true
		end
		getLocalRoot().CFrame = CFrame.new(1e4, 1e4 + 10, 1e4)
	end

	local function ragdoll()
		local args = {
			[1] = getLocalRoot(),
			[2] = 0
		}
		service.ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(unpack(args))
	end

	local function BlackBoxpos()
		return CFrame.new(32e32, 32e32, 32e32)
	end

	--// BLOBMAN
	local function getBlobman()
		local v = get(getInv(), "CreatureBlobman", true)
		if (not v) then
			for _, p in ipairs(workspace.PlotItems:GetChildren()) do
				if (p) then
					local m = get(p, "CreatureBlobman")
					if (not m) or (m and m.PlayerValue.Value ~= getLocalPlayer().Name) then
						VoidNexusLib:MakeNotification({
							Name = "Void Nexus",
							Content = "Blobman not found!",
							Image = "rbxassetid://4483345998",
							Time = 5
						})
						return
					end
					v = m
				end
			end
		end
		if (v.ClassName ~= "Model") then return false end
		if (not get(v, "VehicleSeat")) then return false end
		return v
	end
	local function spawnBlobman()
		local blobman = spawntoy("CreatureBlobman", getLocalRoot().CFrame)
		return blobman
	end
	local function blobGrab(blob, target, side)
		local args = {
			[1] = get(blob, side .. "Detector"),
			[2] = target,
			[3] = get(get(blob, side .. "Detector"), side .. "Weld")
		}
		blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
	end
	local function blobDrop(blob, target, side)
		local args = {
			[1] = get(blob, side .. "Detector"),
			[2] = target
		}
		blob.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(unpack(args))
	end
	local function sirentBlobGrab(blob, target, side)
		local args = {
			[1] = get(blob, side .. "Detector"),
			[2] = target,
			[3] = get(blob, side .. "Detector").AttachPlayer
		}
		blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
	end
	local function blobBring(blob, target, side)
		local pos = getLocalRoot().CFrame
		getLocalRoot().CFrame = target.CFrame
		task.wait(.25)
		blobGrab(blob, target, side)
		task.wait(.25)
		getLocalRoot().CFrame = pos
	end
	local function blobKick(blob, target, side)
		blobGrab(blob, getLocalRoot(), side)
		task.wait(.1)
		SetNetworkOwner(target)
		task.wait()
		target.CFrame += Vector3.new(0, 16, 0)
		task.wait(.1)
		ungrab(target)
		blobGrab(blob, target, side)
	end

	local function IsFriend(p)
		if (not p or not p.UserId or not getLocalPlayer()) then return end
		return getLocalPlayer():IsFriendsWith(p.UserId)
	end
	local function IsInPlot(p)
		return p.InPlot.Value
	end
	local function IsInOwnedPlot(p)
		return p.InOwnedPlot.Value
	end

	local function getPlayerFromName(name)
		local tplayer = nil
		local sname = name:lower()
		for _, player in pairs(service.Players:GetPlayers()) do
			if (player.DisplayName:lower():sub(1, #sname) == sname) then
				tplayer = player
				break
			elseif (player.Name:lower():sub(1, #sname) == sname) then
				if (not tplayer) then
					tplayer = player
				end
			end
		end
		return tplayer
	end

	local function playSound(id)
		task.spawn(function()
			local s = Instance.new("Sound", service.JointsService)
			s.SoundId = id
			s:Play()
			return s
		end)
	end

	local function Snipefunc(root, func, ...)
		local pos = getLocalRoot().CFrame
		task.spawn(function(...)
			local parts = { "Head", "Torso", "HumanoidRootPart" }
			for _, p in pairs(parts) do get(getLocalChar(), p).CanCollide = false end
			getLocalRoot().CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 15)
			task.wait(0.1)
			workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, root.Position)
			for _ = 1, 4 do SetNetworkOwner(root) task.wait(0.05) end
			local look = workspace.CurrentCamera.CFrame
			task.wait(0.1)
			func(...)
			workspace.CurrentCamera.CFrame = look
			task.wait(0.1)
			getLocalRoot().CFrame = pos
			for _, p in pairs(parts) do get(getLocalChar(), p).CanCollide = true end
		end, ...)
	end

	--// CONFIG
	local config = {
		Movements = {
			CrouchSpeedHack = {
				Value = getLocalHum().WalkSpeed,
				Loop = false
			},
			JumpPower = {
				Value = getLocalHum().JumpPower
			},
			Freeze = {
				Value = false,
				CFrame = CFrame.new(0, 0, 0)
			},
			Infjump = {
				Value = false
			},
			Fly = {
				Value = false
			},
			Noclip = {
				Value = false
			},
			Teleports = {
				Target = {
					Value = false
				},
				Barn = {
					CFrame = CFrame.new(-234, 85, -311)
				},
				BlueBouse = {
					CFrame = CFrame.new(525, 98, -375)
				},
				Factory = {
					CFrame = CFrame.new(138, 365, 346)
				},
				GlassHouse = {
					CFrame = CFrame.new(-325, 109, 337)
				},
				JapaneseHouse = {
					CFrame = CFrame.new(584, 141, -100)
				},
				PinkRoofHouse = {
					CFrame = CFrame.new(-525, 22, -165)
				},
				SpookyHouse = {
					CFrame = CFrame.new(303, 14, 483)
				},
				TudorHouse = {
					CFrame = CFrame.new(-572, 20, 89)
				},
				TrainCave = {
					CFrame = CFrame.new(571, 48, -153)
				},
				SmallSecretCave = {
					CFrame = CFrame.new(-50, -7, -298)
				},
				BigSecretCave = {
					CFrame = CFrame.new(-130, -7, 575)
				}
			}
		},
		Players = {
			AntiDetect = {
				Value = false
			},
			AntiRagdoll = {
				Value = false
			},
			AntiTouch = {
				Value = false
			},
			AntiBanana = {
				Value = false
			},
			AutoSlot = {
				Value = false,
				Time = 0
			},
			Ragdoll = {
				Value = false
			},
			AntiGucci = {
				Value = false
			}
		},
		Visuals = {
			ESP = {
				Value = false,
				FillColor = Color3.new(0.25, 0, 1),
				OutlineColor = Color3.new(1, 1, 1)
			},
			FOV = {
				Value = 70
			},
			TPS = {
				Value = false
			},
			Spectate = {
				Value = false
			}
		},
		Combats = {
			AntiGrab = {
				Value = false
			},
			AntiVoid = {
				Value = false
			},
			AntiFar = {
				Value = false
			},
			AntiExplode = {
				Value = false
			},
			StrAntiGrab = {
				Value = false
			},
			Extinguisher = {
				Value = false
			},
			InvisLine = {
				Value = false
			},
			SuperStrength = {
				Value = false,
				Power = {
					Value = 250
				}
			},
			InfLine = {
				Value = false,
				Dist = {
					Value = 0
				}
			},
			Revenge = {
				Void = {
					Value = false
				},
				Kill = {
					Value = false
				},
				Poison = {
					Value = false
				},
				Ragdoll = {
					Value = false
				},
				Death = {
					Value = false
				}
			},
			AimBot = {
				Value = false,
				Radius = {
					Value = 30
				},
				Part = {
					Value = "Torso"
				}
			}
		},
		Auras = {
			VoidAura = {
				Value = false
			},
			KillAura = {
				Value = false
			},
			PoisonAura = {
				Value = false
			},
			RagdollAura = {
				Value = false
			},
			DeathAura = {
				Value = false
			},
			FireAura = {
				Value = false
			},
			AnchorAura = {
				Value = false
			},
			NoclipAura = {
				Value = false
			}
		},
		Grabs = {
			VoidGrab = {
				Value = false
			},
			KillGrab = {
				Value = false
			},
			PoisonGrab = {
				Value = false
			},
			RagdollGrab = {
				Value = false
			},
			DeathGrab = {
				Value = false
			},
			AnchorGrab = {
				Value = false
			},
			KickGrab = {
				Value = false
			},
			NoclipGrab = {
				Value = false
			}
		},
		Miscs = {
			NWOAura = {
				Value = false
			},
			Control = {
				Target = {
					Value = false
				},
				Value = false
			},
			NoTyping = {
				Value = false
			},
			AntiKickDisabler = {
				Value = false
			}
		},
		Blobman = {
			Target = {
				Value = nil
			},
			ArmSide = {
				Value = "Left"
			},
			Noclip = {
				Value = false
			},
			GrabAura = {
				Value = false
			},
			KickAura = {
				Value = false
			},
			LoopKick = {
				Value = false
			},
			LoopKickAll = {
				Value = false
			}
		},
		Snipes = {
			Target = {
				Value = nil
			},
			LoopVoid = {
				Value = false
			},
			LoopKill = {
				Value = false
			},
			LoopPoison = {
				Value = false
			},
			LoopRagdoll = {
				Value = false
			},
			LoopDeath = {
				Value = false
			}
		},
		Trolls = {
			LoudAll = {
				Value = false,
				SoundPart = {
					Value = nil
				}
			},
			Lag = {
				Value = false
			},
			Ping = {
				Value = false
			},
			ServerDestroyer = {
				Value = false,
				CFrame = CFrame.new(0, 0, 0)
			},
			ChaosLine = {
				Value = false
			}
		},
		Settings = {
			OnlyPlayer = {
				Value = false
			},
			IgnoreFriend = {
				Value = false
			},
			IgnoreIsInPlot = {
				Value = false
			},
			AuraRadius = {
				Value = 32
			},
			AimBotSpeed = {
				Value = 5
			},
			Lag = {
				Value = 32
			},
			Ping = {
				Value = 32
			},
			KickMethod = {
				"Void"
			},
			SpeedHackMethod = {
				"CFrame"
			},
			AutoSpeedHackMethod = {
				Value = false
			},
			FlyMethod = {
				"Velocity"
			},
			DebugMode = {
				Value = false
			}
		},
	}

	local __esp = {}
	local function updateESP()
		for i = #__esp, 1, -1 do
			local v = __esp[i]
			if (not config.Visuals.ESP.Value or not v or not v.Parent) then
				pcall(game.Destroy, v)
				table.remove(__esp, i)
			else
				v.FillColor = config.Visuals.ESP.FillColor
				v.OutlineColor = config.Visuals.ESP.OutlineColor
			end
		end
	end
	local function addESP(character)
		if (get(character, "__esp.voidnexus")) then return end
		local h = Instance.new("Highlight", character)
		h.FillColor = config.Visuals.ESP.FillColor
		h.OutlineColor = config.Visuals.ESP.OutlineColor
		h.Name = "__esp.voidnexus"
		table.insert(__esp, h)
	end

	--// CREATE UI
	local Window = VoidNexusLib:MakeWindow({
		Name = "Void Nexus",
		HidePremium = false,
		SaveConfig = true,
		ConfigFolder = "VoidNexusConfig"
	})

	--// TABS
	local MovementsTab = Window:MakeTab({
		Name = "Movements",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local PlayersTab = Window:MakeTab({
		Name = "Players",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local VisualsTab = Window:MakeTab({
		Name = "Visuals",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local CombatsTab = Window:MakeTab({
		Name = "Combats",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local AurasTab = Window:MakeTab({
		Name = "Auras",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local GrabsTab = Window:MakeTab({
		Name = "Grabs",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local MiscsTab = Window:MakeTab({
		Name = "Miscs",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local BlobmanTab = Window:MakeTab({
		Name = "Blobman",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local SnipesTab = Window:MakeTab({
		Name = "Snipes",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local TrollsTab = Window:MakeTab({
		Name = "Trolls",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	local SettingsTab = Window:MakeTab({
		Name = "Settings",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	--// MOVEMENTS TAB
	local MovementsSection = MovementsTab:AddSection({
		Name = "Movement Options"
	})

	MovementsTab:AddSlider({
		Name = "Speed (Crouching)",
		Min = 0,
		Max = 150,
		Default = getLocalHum().WalkSpeed,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Speed",
		Callback = function(Value)
			getLocalHum().WalkSpeed = Value
			config.Movements.CrouchSpeedHack.Value = Value
		end
	})

	MovementsTab:AddToggle({
		Name = "Loop Speed (Crouching)",
		Default = false,
		Callback = function(Value)
			config.Movements.CrouchSpeedHack.Loop = Value
		end
	})

	MovementsTab:AddSlider({
		Name = "Jump Power",
		Min = 0,
		Max = 150,
		Default = getLocalHum().JumpPower,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Power",
		Callback = function(Value)
			getLocalHum().JumpPower = Value
			config.Movements.JumpPower.Value = Value
		end
	})

	MovementsTab:AddToggle({
		Name = "Freeze",
		Default = false,
		Callback = function(Value)
			config.Movements.Freeze.Value = Value
			if Value then
				config.Movements.Freeze.CFrame = getLocalRoot().CFrame
			end
		end
	})

	MovementsTab:AddToggle({
		Name = "Infinite Jump",
		Default = false,
		Callback = function(Value)
			config.Movements.Infjump.Value = Value
		end
	})

	MovementsTab:AddToggle({
		Name = "Fly",
		Default = false,
		Callback = function(Value)
			config.Movements.Fly.Value = Value
		end
	})

	MovementsTab:AddToggle({
		Name = "Noclip",
		Default = false,
		Callback = function(Value)
			config.Movements.Noclip.Value = Value
		end
	})

	local TeleportsSection = MovementsTab:AddSection({
		Name = "Teleports"
	})

	MovementsTab:AddButton({
		Name = "Teleport to Barn",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.Barn.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Blue House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.BlueBouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Factory",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.Factory.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Glass House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.GlassHouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Japanese House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.JapaneseHouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Pink Roof House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.PinkRoofHouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Spooky House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.SpookyHouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Tudor House",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.TudorHouse.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Train Cave",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.TrainCave.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Small Secret Cave",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.SmallSecretCave.CFrame
		end
	})

	MovementsTab:AddButton({
		Name = "Teleport to Big Secret Cave",
		Callback = function()
			getLocalRoot().CFrame = config.Movements.Teleports.BigSecretCave.CFrame
		end
	})

	--// PLAYERS TAB
	local PlayersSection = PlayersTab:AddSection({
		Name = "Player Options"
	})

	PlayersTab:AddToggle({
		Name = "Anti-Detect",
		Default = false,
		Callback = function(Value)
			config.Players.AntiDetect.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Anti-Ragdoll",
		Default = false,
		Callback = function(Value)
			config.Players.AntiRagdoll.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Anti-Touch",
		Default = false,
		Callback = function(Value)
			config.Players.AntiTouch.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Anti-Banana",
		Default = false,
		Callback = function(Value)
			config.Players.AntiBanana.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Auto Slot",
		Default = false,
		Callback = function(Value)
			config.Players.AutoSlot.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Ragdoll",
		Default = false,
		Callback = function(Value)
			config.Players.Ragdoll.Value = Value
		end
	})

	PlayersTab:AddToggle({
		Name = "Anti-Gucci",
		Default = false,
		Callback = function(Value)
			config.Players.AntiGucci.Value = Value
		end
	})

	--// VISUALS TAB
	local VisualsSection = VisualsTab:AddSection({
		Name = "Visual Options"
	})

	VisualsTab:AddToggle({
		Name = "ESP",
		Default = false,
		Callback = function(Value)
			config.Visuals.ESP.Value = Value
		end
	})

	VisualsTab:AddSlider({
		Name = "FOV",
		Min = 1,
		Max = 120,
		Default = 70,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "FOV",
		Callback = function(Value)
			config.Visuals.FOV.Value = Value
		end
	})

	VisualsTab:AddToggle({
		Name = "Third Person (TPS)",
		Default = false,
		Callback = function(Value)
			config.Visuals.TPS.Value = Value
		end
	})

	VisualsTab:AddToggle({
		Name = "Spectate",
		Default = false,
		Callback = function(Value)
			config.Visuals.Spectate.Value = Value
		end
	})

	--// COMBATS TAB
	local CombatsSection = CombatsTab:AddSection({
		Name = "Combat Options"
	})

	CombatsTab:AddToggle({
		Name = "Anti-Grab",
		Default = false,
		Callback = function(Value)
			config.Combats.AntiGrab.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Anti-Void",
		Default = false,
		Callback = function(Value)
			config.Combats.AntiVoid.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Anti-Far",
		Default = false,
		Callback = function(Value)
			config.Combats.AntiFar.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Anti-Explode",
		Default = false,
		Callback = function(Value)
			config.Combats.AntiExplode.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Strong Anti-Grab",
		Default = false,
		Callback = function(Value)
			config.Combats.StrAntiGrab.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Auto Extinguisher",
		Default = false,
		Callback = function(Value)
			config.Combats.Extinguisher.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Invisible Line",
		Default = false,
		Callback = function(Value)
			config.Combats.InvisLine.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Super Strength",
		Default = false,
		Callback = function(Value)
			config.Combats.SuperStrength.Value = Value
		end
	})

	CombatsTab:AddSlider({
		Name = "Super Strength Power",
		Min = 0,
		Max = 1000,
		Default = 250,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 10,
		ValueName = "Power",
		Callback = function(Value)
			config.Combats.SuperStrength.Power.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Infinite Line",
		Default = false,
		Callback = function(Value)
			config.Combats.InfLine.Value = Value
		end
	})

	local RevengeSection = CombatsTab:AddSection({
		Name = "Revenge Options"
	})

	CombatsTab:AddToggle({
		Name = "Revenge: Void",
		Default = false,
		Callback = function(Value)
			config.Combats.Revenge.Void.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Revenge: Kill",
		Default = false,
		Callback = function(Value)
			config.Combats.Revenge.Kill.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Revenge: Poison",
		Default = false,
		Callback = function(Value)
			config.Combats.Revenge.Poison.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Revenge: Ragdoll",
		Default = false,
		Callback = function(Value)
			config.Combats.Revenge.Ragdoll.Value = Value
		end
	})

	CombatsTab:AddToggle({
		Name = "Revenge: Death",
		Default = false,
		Callback = function(Value)
			config.Combats.Revenge.Death.Value = Value
		end
	})

	local AimBotSection = CombatsTab:AddSection({
		Name = "AimBot"
	})

	CombatsTab:AddToggle({
		Name = "AimBot",
		Default = false,
		Callback = function(Value)
			config.Combats.AimBot.Value = Value
		end
	})

	CombatsTab:AddSlider({
		Name = "AimBot Radius",
		Min = 0,
		Max = 100,
		Default = 30,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Radius",
		Callback = function(Value)
			config.Combats.AimBot.Radius.Value = Value
		end
	})

	CombatsTab:AddDropdown({
		Name = "AimBot Part",
		Default = "Torso",
		Options = { "Head", "Torso", "HumanoidRootPart" },
		Callback = function(Value)
			config.Combats.AimBot.Part.Value = Value
		end
	})

	--// AURAS TAB
	local AurasSection = AurasTab:AddSection({
		Name = "Aura Options"
	})

	AurasTab:AddToggle({
		Name = "Void Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.VoidAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Kill Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.KillAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Poison Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.PoisonAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Ragdoll Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.RagdollAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Death Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.DeathAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Fire Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.FireAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Anchor Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.AnchorAura.Value = Value
		end
	})

	AurasTab:AddToggle({
		Name = "Noclip Aura",
		Default = false,
		Callback = function(Value)
			config.Auras.NoclipAura.Value = Value
		end
	})

	--// GRABS TAB
	local GrabsSection = GrabsTab:AddSection({
		Name = "Grab Options"
	})

	GrabsTab:AddToggle({
		Name = "Void Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.VoidGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Kill Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.KillGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Poison Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.PoisonGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Ragdoll Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.RagdollGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Death Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.DeathGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Anchor Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.AnchorGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Kick Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.KickGrab.Value = Value
		end
	})

	GrabsTab:AddToggle({
		Name = "Noclip Grab",
		Default = false,
		Callback = function(Value)
			config.Grabs.NoclipGrab.Value = Value
		end
	})

	--// MISCS TAB
	local MiscsSection = MiscsTab:AddSection({
		Name = "Miscellaneous Options"
	})

	MiscsTab:AddToggle({
		Name = "Control",
		Default = false,
		Callback = function(Value)
			config.Miscs.Control.Value = Value
			if Value then
				VoidNexusLib:MakeNotification({
					Name = "Void Nexus",
					Content = "Grab to select!",
					Image = "rbxassetid://4483345998",
					Time = 5
				})
			else
				workspace.CurrentCamera.CameraSubject = getLocalHum()
				config.Miscs.Control.Target.Value = nil
			end
		end
	})

	MiscsTab:AddToggle({
		Name = "Ocean Walk",
		Default = false,
		Callback = function(Value)
			local p = workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel
			for _, v in ipairs(p:GetChildren()) do
				if (v:IsA("BasePart")) then
					v.CanCollide = Value
				end
			end
		end
	})

	MiscsTab:AddButton({
		Name = "Safespot",
		Callback = function()
			Safespot()
		end
	})

	MiscsTab:AddToggle({
		Name = "Anti-Lag",
		Default = false,
		Callback = function(Value)
			local p = getLocalPlayer().PlayerScripts.CharacterAndBeamMove
			p.Enabled = not Value
		end
	})

	MiscsTab:AddToggle({
		Name = "Anti-Sticky (NetworkOwner)",
		Default = false,
		Callback = function(Value)
			local p = getLocalPlayer().PlayerScripts.StickyPartsTouchDetection
			p.Enabled = not Value
		end
	})

	MiscsTab:AddToggle({
		Name = "NetworkOwner-Aura",
		Default = false,
		Callback = function(Value)
			config.Miscs.NWOAura.Value = Value
		end
	})

	MiscsTab:AddToggle({
		Name = "No Typing",
		Default = false,
		Callback = function(Value)
			config.Miscs.NoTyping.Value = Value
		end
	})

	MiscsTab:AddToggle({
		Name = "Anti-Kick Disabler",
		Default = false,
		Callback = function(Value)
			config.Miscs.AntiKickDisabler.Value = Value
		end
	})

	--// BLOBMAN TAB
	local BlobmanSection = BlobmanTab:AddSection({
		Name = "Blobman Options"
	})

	BlobmanTab:AddTextbox({
		Name = "Target Player",
		Default = getLocalPlayer().Name,
		TextDisappear = false,
		Callback = function(Value)
			config.Blobman.Target.Value = Value
		end
	})

	BlobmanTab:AddDropdown({
		Name = "Arm Side",
		Default = "Left",
		Options = { "Left", "Right" },
		Callback = function(Value)
			config.Blobman.ArmSide.Value = Value
		end
	})

	BlobmanTab:AddButton({
		Name = "Spawn Blobman",
		Callback = function()
			spawnBlobman()
		end
	})

	BlobmanTab:AddButton({
		Name = "OP-Blobman",
		Callback = function()
			local blob = getBlobman()
			if (not blob) then
				blob = spawnBlobman()
			end
			if (not getLocalHum().Sit) then
				blob.VehicleSeat:Sit(getLocalHum())
			end
			local pos = getLocalRoot().CFrame
			task.wait()
			if (blob and getLocalHum()) then
				if (blob:IsDescendantOf(workspace.PlotItems)) then
					getLocalRoot().CFrame = CFrame.new(0, 0, 0)
					task.wait(.5)
				end
				local Toy = spawntoy("YouDecoy", getLocalRoot().CFrame)
				SetNetworkOwner(Toy.HumanoidRootPart)
				Toy.HumanoidRootPart.CFrame = blob.RightDetector.CFrame
				task.wait()
				blobGrab(blob, Toy.HumanoidRootPart, "Right")
				task.wait(1.25)
				destroyToy(Toy)
				task.wait(.1)

				local Toy = spawntoy("YouDecoy", getLocalRoot().CFrame)
				SetNetworkOwner(Toy.HumanoidRootPart)
				Toy.HumanoidRootPart.CFrame = blob.LeftDetector.CFrame
				task.wait()
				blobGrab(blob, Toy.HumanoidRootPart, "Left")
				task.wait(1.25)
				destroyToy(Toy)
				task.wait(.1)
			end
			getLocalRoot().CFrame = pos
		end
	})

	BlobmanTab:AddToggle({
		Name = "Noclip",
		Default = false,
		Callback = function(Value)
			config.Blobman.Noclip.Value = Value
		end
	})

	BlobmanTab:AddButton({
		Name = "Bring",
		Callback = function()
			local t = getPlayerFromName(config.Blobman.Target.Value)
			if (t) then
				task.spawn(function()
					local root = get(t.Character, "HumanoidRootPart")
					local b = getBlobman()
					if (not root or not b) then return end
					local pos = getLocalRoot().CFrame
					getLocalRoot().CFrame = root.CFrame
					blobBring(b, root, config.Blobman.ArmSide.Value)
					task.wait()
					getLocalRoot().CFrame = pos
					task.spawn(function()
						for _ = 1, 256 do
							task.wait()
							if (IsInRadius(root, getLocalRoot().Position, 12)) then
								task.wait(1)
								getLocalHum().Sit = false
								break
							end
						end
					end)
				end)
			end
		end
	})

	BlobmanTab:AddButton({
		Name = "Lock (OP Blobman)",
		Callback = function()
			task.spawn(function()
				local t = getPlayerFromName(config.Blobman.Target.Value)
				if (t) then
					local root = get(t.Character, "HumanoidRootPart")
					local b = getBlobman()
					local pos = getLocalRoot().CFrame
					blobBring(b, root, config.Blobman.ArmSide.Value)
					task.wait()
					getLocalRoot().CFrame = pos
				end
			end)
		end
	})

	BlobmanTab:AddToggle({
		Name = "Grab Aura",
		Default = false,
		Callback = function(Value)
			config.Blobman.GrabAura.Value = Value
		end
	})

	BlobmanTab:AddToggle({
		Name = "Kick Aura",
		Default = false,
		Callback = function(Value)
			config.Blobman.KickAura.Value = Value
		end
	})

	BlobmanTab:AddToggle({
		Name = "Loop Kick",
		Default = false,
		Callback = function(Value)
			config.Blobman.LoopKick.Value = Value
		end
	})

	BlobmanTab:AddToggle({
		Name = "Loop Kick All",
		Default = false,
		Callback = function(Value)
			config.Blobman.LoopKickAll.Value = Value
		end
	})

	--// SNIPES TAB
	local SnipesSection = SnipesTab:AddSection({
		Name = "Snipe Options"
	})

	SnipesTab:AddTextbox({
		Name = "Target Player",
		Default = "",
		TextDisappear = false,
		Callback = function(Value)
			config.Snipes.Target.Value = Value
		end
	})

	SnipesTab:AddToggle({
		Name = "Loop Void",
		Default = false,
		Callback = function(Value)
			config.Snipes.LoopVoid.Value = Value
		end
	})

	SnipesTab:AddToggle({
		Name = "Loop Kill",
		Default = false,
		Callback = function(Value)
			config.Snipes.LoopKill.Value = Value
		end
	})

	SnipesTab:AddToggle({
		Name = "Loop Poison",
		Default = false,
		Callback = function(Value)
			config.Snipes.LoopPoison.Value = Value
		end
	})

	SnipesTab:AddToggle({
		Name = "Loop Ragdoll",
		Default = false,
		Callback = function(Value)
			config.Snipes.LoopRagdoll.Value = Value
		end
	})

	SnipesTab:AddToggle({
		Name = "Loop Death",
		Default = false,
		Callback = function(Value)
			config.Snipes.LoopDeath.Value = Value
		end
	})

	--// TROLLS TAB
	local TrollsSection = TrollsTab:AddSection({
		Name = "Troll Options"
	})

	TrollsTab:AddToggle({
		Name = "Loud All",
		Default = false,
		Callback = function(Value)
			config.Trolls.LoudAll.Value = Value
		end
	})

	TrollsTab:AddToggle({
		Name = "Lag Server",
		Default = false,
		Callback = function(Value)
			config.Trolls.Lag.Value = Value
		end
	})

	TrollsTab:AddToggle({
		Name = "Ping Server",
		Default = false,
		Callback = function(Value)
			config.Trolls.Ping.Value = Value
		end
	})

	TrollsTab:AddToggle({
		Name = "Server Destroyer",
		Default = false,
		Callback = function(Value)
			config.Trolls.ServerDestroyer.Value = Value
			if Value then
				config.Trolls.ServerDestroyer.CFrame = getLocalRoot().CFrame
			end
		end
	})

	TrollsTab:AddToggle({
		Name = "Chaos Line",
		Default = false,
		Callback = function(Value)
			config.Trolls.ChaosLine.Value = Value
		end
	})

	--// SETTINGS TAB
	local SettingsSection = SettingsTab:AddSection({
		Name = "General Settings"
	})

	SettingsTab:AddToggle({
		Name = "Only Target Players",
		Default = false,
		Callback = function(Value)
			config.Settings.OnlyPlayer.Value = Value
		end
	})

	SettingsTab:AddToggle({
		Name = "Ignore Friends",
		Default = false,
		Callback = function(Value)
			config.Settings.IgnoreFriend.Value = Value
		end
	})

	SettingsTab:AddToggle({
		Name = "Ignore Players in Plot",
		Default = false,
		Callback = function(Value)
			config.Settings.IgnoreIsInPlot.Value = Value
		end
	})

	SettingsTab:AddSlider({
		Name = "Aura Radius",
		Min = 0,
		Max = 100,
		Default = 32,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Radius",
		Callback = function(Value)
			config.Settings.AuraRadius.Value = Value
		end
	})

	SettingsTab:AddSlider({
		Name = "AimBot Speed",
		Min = 1,
		Max = 20,
		Default = 5,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Speed",
		Callback = function(Value)
			config.Settings.AimBotSpeed.Value = Value
		end
	})

	SettingsTab:AddSlider({
		Name = "Lag Amount",
		Min = 1,
		Max = 100,
		Default = 32,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Amount",
		Callback = function(Value)
			config.Settings.Lag.Value = Value
		end
	})

	SettingsTab:AddSlider({
		Name = "Ping Amount",
		Min = 1,
		Max = 100,
		Default = 32,
		Color = Color3.fromRGB(255, 255, 255),
		Increment = 1,
		ValueName = "Amount",
		Callback = function(Value)
			config.Settings.Ping.Value = Value
		end
	})

	SettingsTab:AddDropdown({
		Name = "Speed Hack Method",
		Default = "CFrame",
		Options = { "CFrame", "Velocity" },
		Callback = function(Value)
			config.Settings.SpeedHackMethod = { Value }
		end
	})

	SettingsTab:AddDropdown({
		Name = "Fly Method",
		Default = "Velocity",
		Options = { "Velocity", "BodyVelocity" },
		Callback = function(Value)
			config.Settings.FlyMethod = { Value }
		end
	})

	SettingsTab:AddToggle({
		Name = "Auto Speed Hack Method",
		Default = false,
		Callback = function(Value)
			config.Settings.AutoSpeedHackMethod.Value = Value
		end
	})

	SettingsTab:AddToggle({
		Name = "Debug Mode",
		Default = false,
		Callback = function(Value)
			config.Settings.DebugMode.Value = Value
		end
	})

	--// MAIN LOOP
	local AuraTimer = 0
	local espTimer = 0
	local AntiDetectTimer = 0
	local ExtinguisherTimer = 0
	local AntiBananaTimer = 0
	local BlobmanTimer = 0
	local SnipeTimer = 0
	local TrollTimer = 0

	loop.Event:Connect(function(dt)
		AuraTimer += dt
		espTimer += dt
		AntiDetectTimer += dt
		ExtinguisherTimer += dt
		AntiBananaTimer += dt
		BlobmanTimer += dt
		SnipeTimer += dt
		TrollTimer += dt

		if (not getLocalChar() or not getLocalRoot() or not getLocalHum()) then return end

		--// MOVEMENTS
		if (config.Movements.CrouchSpeedHack.Loop) then
			getLocalHum().WalkSpeed = config.Movements.CrouchSpeedHack.Value
		end
		if (config.Movements.Freeze.Value) then
			getLocalRoot().CFrame = config.Movements.Freeze.CFrame
		end
		if (config.Movements.Infjump.Value) then
			service.UserInputService.JumpRequest:Connect(function()
				getLocalHum():ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end
		if (config.Movements.Fly.Value) then
			local flyVelocity = Vector3.new(0, 0, 0)
			if service.UserInputService:IsKeyDown(Enum.KeyCode.W) then
				flyVelocity += workspace.CurrentCamera.CFrame.LookVector * 50
			end
			if service.UserInputService:IsKeyDown(Enum.KeyCode.S) then
				flyVelocity -= workspace.CurrentCamera.CFrame.LookVector * 50
			end
			if service.UserInputService:IsKeyDown(Enum.KeyCode.A) then
				flyVelocity -= workspace.CurrentCamera.CFrame.RightVector * 50
			end
			if service.UserInputService:IsKeyDown(Enum.KeyCode.D) then
				flyVelocity += workspace.CurrentCamera.CFrame.RightVector * 50
			end
			if service.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				flyVelocity += Vector3.new(0, 50, 0)
			end
			if service.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				flyVelocity -= Vector3.new(0, 50, 0)
			end
			getLocalRoot().Velocity = flyVelocity
			getLocalRoot().Anchored = false
		end
		if (config.Movements.Noclip.Value) then
			for _, v in pairs(getLocalChar():GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end

		--// PLAYERS
		if (AntiDetectTimer >= 1) then
			if (config.Players.AntiDetect.Value) then
				AntiDetect()
			end
			AntiDetectTimer = 0
		end
		if (config.Players.AntiRagdoll.Value) then
			getLocalHum().PlatformStand = false
		end
		if (config.Players.AntiTouch.Value) then
			for _, v in pairs(getLocalChar():GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanTouch = false
				end
			end
		end
		if (AntiBananaTimer >= 1) then
			for _, v in ipairs(workspace:GetChildren()) do
				if (v:IsA("Folder") and v.Name:find("SpawnedInToys") and not v:IsDescendantOf(getInv())) then
					local banana = get(v, "FoodBanana")
					if (banana) then
						for _, v in ipairs(banana:GetDescendants()) do
							if (v:IsA("BasePart")) then
								v.CanQuery = config.Players.AntiBanana.Value
								v.CanTouch = config.Players.AntiBanana.Value
								if (config.Players.AntiBanana.Value) then
									if (IsInRadius(v, getLocalRoot().Position, 8)) then
										SetNetworkOwner(v)
									end
								end
							end
						end
					end
				end
			end
			AntiBananaTimer = 0
		end
		if (config.Players.Ragdoll.Value) then
			ragdoll()
			getLocalHum().PlatformStand = true
		end
		if (config.Players.AntiGucci.Value) then
			ragdoll()
		end

		--// VISUALS
		if (espTimer >= 1) then
			updateESP()
			if (config.Visuals.ESP.Value) then
				for _, p in ipairs(service.Players:GetPlayers()) do
					local c = p.Character
					if (c) then
						addESP(c)
					end
				end
			end
		end
		if (workspace.CurrentCamera) then
			workspace.CurrentCamera.FieldOfView = config.Visuals.FOV.Value
		end
		if (config.Visuals.TPS.Value) then
			getLocalPlayer().CameraMaxZoomDistance = 100000
			getLocalPlayer().CameraMode = Enum.CameraMode.Classic
			if ((workspace.CurrentCamera.CFrame.Position - workspace.CurrentCamera.Focus.Position).Magnitude > getLocalPlayer().CameraMinZoomDistance) then
				service.UserInputService.MouseIconEnabled = true
			else
				service.UserInputService.MouseIconEnabled = false
			end
		else
			getLocalPlayer().CameraMode = Enum.CameraMode.LockFirstPerson
		end

		--// COMBATS
		do
			if (getLocalChar()) then
				local head = get(getLocalChar(), "Head")
				if (head) then
					local owner = get(head, "PartOwner")
					local target
					if (owner and owner.Value) then
						target = get(service.Players, owner.Value)
					end
					task.spawn(function()
						while (owner and config.Combats.AntiGrab.Value) or (getLocalPlayer().IsHeld.Value and config.Combats.AntiGrab.Value) do
							if (getLocalRoot()) then
								getLocalRoot().Anchored = true
							end
							service.ReplicatedStorage.CharacterEvents.Struggle:FireServer(getLocalPlayer())
							service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
							task.wait()
						end
						if (getLocalRoot()) then
							getLocalRoot().Anchored = false
						end
					end)

					do
						if (target) then
							local character = target.Character
							if (character) then
								local root = get(character, "HumanoidRootPart")
								if (root) then
									if (config.Combats.Revenge.Void.Value) then
										for _ = 1, 3 do
											SetNetworkOwner(root)
											task.wait(.1)
											Velocity(root, Vector3.new(0, 1e4, 0))
											task.wait()
										end
									end
									if (config.Combats.Revenge.Kill.Value) then
										for _ = 1, 3 do
											SetNetworkOwner(root)
											task.wait(.1)
											MoveTo(root, CFrame.new(4096, -75, 4096))
											Velocity(root, Vector3.new(0, -1e3, 0))
											task.wait()
										end
									end
									if (config.Combats.Revenge.Poison.Value) then
										for _ = 1, 3 do
											SetNetworkOwner(root)
											task.wait(.1)
											MoveTo(root, CFrame.new(58, -70, 271))
											task.wait()
										end
									end
									if (config.Combats.Revenge.Ragdoll.Value) then
										for _ = 1, 3 do
											local pos = root.CFrame
											SetNetworkOwner(root)
											task.wait(.1)
											Velocity(root, Vector3.new(0, -64, 0))
											task.wait()
											MoveTo(root, pos)
											Velocity(root, Vector3.zero)
											task.wait()
										end
									end
									if (config.Combats.Revenge.Death.Value) then
										for _ = 1, 3 do
											SetNetworkOwner(root)
											task.wait(.1)
											cget(root.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
											task.wait(.5)
											ungrab(root)
											task.wait()
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if (config.Combats.StrAntiGrab.Value and getLocalHum() and getLocalHum().Sit) then
			service.ReplicatedStorage.CharacterEvents.Struggle:FireServer(getLocalPlayer())
			service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
			getLocalHum().Sit = false
			SetNetworkOwner(getLocalRoot())
		end

		if (ExtinguisherTimer >= 1) then
			if (config.Combats.Extinguisher.Value) then
				if (getLocalChar() and get(getLocalHum(), "FireDebounce").Value) then
					local FireExtinguisher = spawntoy("FireExtinguisher", getLocalRoot().CFrame)
					for _, v in ipairs(FireExtinguisher:GetDescendants()) do
						if (v:IsA("BasePart")) then
							v.CanCollide = false
						end
					end
					local pos = getLocalRoot().Position - Vector3.new(0, 3, 0)
					local look = getLocalRoot().CFrame.LookVector
					FireExtinguisher.PrimaryPart.CFrame = CFrame.new(pos, pos + look)
					task.delay(1, function()
						destroyToy(FireExtinguisher)
					end)
				end
			end
			ExtinguisherTimer = 0
		end

		if (AuraTimer >= .5) then
			if (not getLocalRoot()) then return end
			for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
				if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and (v.Name == "HumanoidRootPart" or v.Name == "Torso" or v.Name == "Head")) then
					local p = service.Players:GetPlayerFromCharacter(v.Parent)
					if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
					if (not p and config.Settings.OnlyPlayer.Value) then continue end
					if (config.Auras.VoidAura.Value) then
						task.spawn(function()
							SetNetworkOwner(v)
							v.CanCollide = false
							Velocity(v, Vector3.new(0, 1e4, 0))
						end)
					end
					if (config.Auras.KillAura.Value) then
						task.spawn(function()
							SetNetworkOwner(v)
							v.CanCollide = false
							MoveTo(v, CFrame.new(4096, -75, 4096))
							Velocity(v, Vector3.new(0, -1e3, 0))
						end)
					end
					if (config.Auras.PoisonAura.Value) then
						task.spawn(function()
							SetNetworkOwner(v)
							local pos = v.CFrame
							MoveTo(v, CFrame.new(58, -70, 271))
						end)
					end
					if (config.Auras.RagdollAura.Value) then
						task.spawn(function()
							local pos = v.CFrame
							SetNetworkOwner(v)
							Velocity(v, Vector3.new(0, -256, 0))
							task.wait()
							MoveTo(v, pos)
							Velocity(v, Vector3.zero)
						end)
					end
					if (config.Auras.DeathAura.Value) then
						task.spawn(function()
							SetNetworkOwner(v)
							task.wait(.1)
							cget(v.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							task.wait(.5)
							ungrab(v)
						end)
					end
					if (config.Auras.AnchorAura.Value) then
						task.spawn(function()
							anchor(v)
						end)
					end
					if (config.Auras.FireAura.Value) then
						task.spawn(function()
							local e = spawntoy("Campfire", getLocalRoot().CFrame).SoundPart
							SetNetworkOwner(e)
							task.wait(.1)
							e.CFrame = v.CFrame
							task.delay(.5, destroyToy, e.Parent)
						end)
					end
					if (config.Auras.NoclipAura.Value) then
						task.spawn(function()
							SetNetworkOwner(v)
							task.wait(.1)
							v.CanCollide = false
						end)
					end
				end
			end
			AuraTimer = 0
		end

		if (config.Combats.AntiVoid.Value) then
			workspace.FallenPartsDestroyHeight = 0 / 0
			local rad = math.huge
			if (getLocalRoot()) then
				local height = -87.5
				local Y = getLocalRoot().CFrame.Y
				if (height >= Y) then
					service.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
					service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
					local p = workspace.SpawnLocation
					local pos = (p.Position + Vector3.new(math.random(-p.Size.X * 0.5, p.Size.X * 0.5), math.random(0, p.Size.Y), math.random(-p.Size.Z * 0.5, p.Size.Z * 0.5)))
					getLocalRoot().CFrame = (CFrame.new(pos, getLocalRoot().CFrame.LookVector))
					getLocalRoot().AssemblyLinearVelocity = Vector3.zero
					getLocalRoot().AssemblyAngularVelocity = Vector3.zero
					VoidNexusLib:MakeNotification({
						Name = "Void Nexus",
						Content = "Saved you from the void!",
						Image = "rbxassetid://4483345998",
						Time = 5
					})
				end
			end
		end

		if (config.Combats.AntiFar.Value) then
			if (not IsInRadius(getLocalRoot(), Vector3.zero, 4096)) then
				service.ReplicatedStorage.CharacterEvents.Struggle:FireServer()
				service.ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
				local p = workspace.SpawnLocation
				local pos = (p.Position + Vector3.new(math.random(-p.Size.X * 0.5, p.Size.X * 0.5), math.random(0, p.Size.Y), math.random(-p.Size.Z * 0.5, p.Size.Z * 0.5)))
				getLocalRoot().CFrame = (CFrame.new(pos, getLocalRoot().CFrame.LookVector))
				getLocalRoot().AssemblyLinearVelocity = Vector3.zero
				getLocalRoot().AssemblyAngularVelocity = Vector3.zero
				VoidNexusLib:MakeNotification({
					Name = "Void Nexus",
					Content = "Saved you from being too far!",
					Image = "rbxassetid://4483345998",
					Time = 5
				})
			end
		end

		if (config.Combats.InvisLine.Value) then
			service.ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer()
		end

		if (config.Combats.AimBot.Value) then
			local nearestPlayer = nil
			local nearestDistance = config.Combats.AimBot.Radius.Value
			for _, player in ipairs(service.Players:GetPlayers()) do
				if player ~= getLocalPlayer() and player.Character then
					local targetPart = get(player.Character, config.Combats.AimBot.Part.Value)
					if targetPart then
						local distance = (targetPart.Position - getLocalRoot().Position).Magnitude
						if distance < nearestDistance then
							nearestDistance = distance
							nearestPlayer = targetPart
						end
					end
				end
			end
			if nearestPlayer then
				workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, nearestPlayer.Position)
			end
		end

		--// GRABS
		if getLocalPlayer().IsHolding.Value then
			local grabbed = nil
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and get(v, "PartOwner") and get(v, "PartOwner").Value == getLocalPlayer().Name then
					grabbed = v
					break
				end
			end
			if grabbed then
				if config.Grabs.VoidGrab.Value then
					SetNetworkOwner(grabbed)
					Velocity(grabbed, Vector3.new(0, 1e4, 0))
				end
				if config.Grabs.KillGrab.Value then
					SetNetworkOwner(grabbed)
					MoveTo(grabbed, CFrame.new(4096, -75, 4096))
					Velocity(grabbed, Vector3.new(0, -1e3, 0))
				end
				if config.Grabs.PoisonGrab.Value then
					SetNetworkOwner(grabbed)
					MoveTo(grabbed, CFrame.new(58, -70, 271))
				end
				if config.Grabs.RagdollGrab.Value then
					SetNetworkOwner(grabbed)
					Velocity(grabbed, Vector3.new(0, -256, 0))
				end
				if config.Grabs.DeathGrab.Value then
					SetNetworkOwner(grabbed)
					cget(grabbed.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
					ungrab(grabbed)
				end
				if config.Grabs.AnchorGrab.Value then
					anchor(grabbed)
				end
				if config.Grabs.KickGrab.Value then
					local player = service.Players:GetPlayerFromCharacter(grabbed.Parent)
					if player then
						kickGrab(player)
					end
				end
				if config.Grabs.NoclipGrab.Value then
					SetNetworkOwner(grabbed)
					grabbed.CanCollide = false
				end
			end
		end

		--// BLOBMAN
		if (BlobmanTimer >= 0.5) then
			local blob = getBlobman()
			if blob then
				if config.Blobman.Noclip.Value then
					for _, v in pairs(blob:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
				end
				if config.Blobman.GrabAura.Value then
					for _, v in ipairs(GetNearParts(blob.HumanoidRootPart.Position, config.Settings.AuraRadius.Value)) do
						if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and not v:IsDescendantOf(blob) and (v.Name == "HumanoidRootPart" or v.Name == "Torso" or v.Name == "Head")) then
							local p = service.Players:GetPlayerFromCharacter(v.Parent)
							if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
							if (not p and config.Settings.OnlyPlayer.Value) then continue end
							blobGrab(blob, v, config.Blobman.ArmSide.Value)
							break
						end
					end
				end
				if config.Blobman.KickAura.Value then
					for _, v in ipairs(GetNearParts(blob.HumanoidRootPart.Position, config.Settings.AuraRadius.Value)) do
						if (not v.Anchored and not v:IsDescendantOf(getLocalChar()) and not v:IsDescendantOf(blob) and (v.Name == "HumanoidRootPart" or v.Name == "Torso" or v.Name == "Head")) then
							local p = service.Players:GetPlayerFromCharacter(v.Parent)
							if (IsFriend(p) and config.Settings.IgnoreFriend.Value) then continue end
							if (not p and config.Settings.OnlyPlayer.Value) then continue end
							blobKick(blob, v, config.Blobman.ArmSide.Value)
							break
						end
					end
				end
				if config.Blobman.LoopKick.Value then
					local t = getPlayerFromName(config.Blobman.Target.Value)
					if t and t.Character then
						local root = get(t.Character, "HumanoidRootPart")
						if root then
							blobKick(blob, root, config.Blobman.ArmSide.Value)
						end
					end
				end
				if config.Blobman.LoopKickAll.Value then
					for _, player in ipairs(service.Players:GetPlayers()) do
						if player ~= getLocalPlayer() and player.Character then
							local root = get(player.Character, "HumanoidRootPart")
							if root then
								blobKick(blob, root, config.Blobman.ArmSide.Value)
							end
						end
					end
				end
			end
			BlobmanTimer = 0
		end

		--// SNIPES
		if (SnipeTimer >= 2) then
			local t = getPlayerFromName(config.Snipes.Target.Value)
			if t and t.Character then
				local root = get(t.Character, "HumanoidRootPart")
				if root then
					if config.Snipes.LoopVoid.Value then
						Snipefunc(root, function()
							SetNetworkOwner(root)
							Velocity(root, Vector3.new(0, 1e4, 0))
						end)
					end
					if config.Snipes.LoopKill.Value then
						Snipefunc(root, function()
							SetNetworkOwner(root)
							MoveTo(root, CFrame.new(4096, -75, 4096))
							Velocity(root, Vector3.new(0, -1e3, 0))
						end)
					end
					if config.Snipes.LoopPoison.Value then
						Snipefunc(root, function()
							SetNetworkOwner(root)
							MoveTo(root, CFrame.new(58, -70, 271))
						end)
					end
					if config.Snipes.LoopRagdoll.Value then
						Snipefunc(root, function()
							SetNetworkOwner(root)
							Velocity(root, Vector3.new(0, -256, 0))
						end)
					end
					if config.Snipes.LoopDeath.Value then
						Snipefunc(root, function()
							SetNetworkOwner(root)
							cget(root.Parent, "Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							ungrab(root)
						end)
					end
				end
			end
			SnipeTimer = 0
		end

		--// TROLLS
		if (TrollTimer >= 0.1) then
			if config.Trolls.Lag.Value then
				lag(config.Settings.Lag.Value)
			end
			if config.Trolls.Ping.Value then
				ping(config.Settings.Ping.Value)
			end
			TrollTimer = 0
		end

		if config.Trolls.ServerDestroyer.Value then
			for _, player in ipairs(service.Players:GetPlayers()) do
				if player ~= getLocalPlayer() and player.Character then
					local root = get(player.Character, "HumanoidRootPart")
					if root then
						SetNetworkOwner(root)
						root.CFrame = config.Trolls.ServerDestroyer.CFrame
					end
				end
			end
		end

		if config.Trolls.ChaosLine.Value then
			for _, player in ipairs(service.Players:GetPlayers()) do
				if player ~= getLocalPlayer() and player.Character then
					local root = get(player.Character, "HumanoidRootPart")
					if root then
						createLine(root)
					end
				end
			end
		end

		--// MISCS
		if config.Miscs.Control.Value then
			if getLocalPlayer().IsHolding.Value then
				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("BasePart") and get(v, "PartOwner") and get(v, "PartOwner").Value == getLocalPlayer().Name then
						local char = v.Parent
						if char and cget(char, "Humanoid") then
							config.Miscs.Control.Target.Value = char
							workspace.CurrentCamera.CameraSubject = cget(char, "Humanoid")
							break
						end
					end
				end
			end
		end

		if config.Miscs.NWOAura.Value then
			for _, v in ipairs(GetNearParts(getLocalRoot().Position, config.Settings.AuraRadius.Value)) do
				if (not v.Anchored and not v:IsDescendantOf(getLocalChar())) then
					SetNetworkOwner(v)
				end
			end
		end

		if config.Miscs.NoTyping.Value then
			local chatBar = getLocalPlayer().PlayerGui:FindFirstChild("Chat")
			if chatBar then
				chatBar.Enabled = false
			end
		end
	end)

	VoidNexusLib:Init()
	VoidNexusLib:MakeNotification({
		Name = "Void Nexus",
		Content = "Successfully loaded!",
		Image = "rbxassetid://4483345998",
		Time = 5
	})
end
