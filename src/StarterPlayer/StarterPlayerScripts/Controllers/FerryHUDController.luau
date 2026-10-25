-- Destination waypoint, distance readout, and completion popup for ferry runs.
-- Boarding prompts are the ProximityPrompts FerryMissionService puts on each dock.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteEvents = require(ReplicatedStorage.Modules.Network.RemoteEvents)

local UI = GameConfig.UI

local player = Players.LocalPlayer

local FerryHUDController = {}

local function label(parent: Instance, position: UDim2, textSize: number): TextLabel
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0)
	text.Position = position
	text.Size = UDim2.fromOffset(360, textSize + 16)
	text.BackgroundColor3 = UI.Background
	text.BackgroundTransparency = UI.BackgroundTransparency
	text.BorderSizePixel = 0
	text.TextColor3 = UI.Text
	text.TextSize = textSize
	text.Font = Enum.Font.GothamBold
	text.Visible = false
	text.Parent = parent
	return text
end

function FerryHUDController.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FerryHUD"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local distanceLabel = label(gui, UDim2.new(0.5, 0, 0, 12), 18)
	local popup = label(gui, UDim2.new(0.5, 0, 0.3, 0), 28)

	-- Client-only marker floating above the destination dock.
	local marker = Instance.new("Part")
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Transparency = 1
	marker.Size = Vector3.one
	local billboard = Instance.new("BillboardGui")
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.Parent = marker
	local markerText = Instance.new("TextLabel")
	markerText.Size = UDim2.fromScale(1, 1)
	markerText.BackgroundTransparency = 1
	markerText.TextColor3 = UI.Highlight
	markerText.TextStrokeTransparency = 0
	markerText.TextScaled = true
	markerText.Font = Enum.Font.GothamBold
	markerText.Parent = billboard

	local destination: Vector3?, destinationName = nil, ""

	local function clear()
		destination = nil
		marker.Parent = nil
		distanceLabel.Visible = false
	end

	RemoteEvents.FerryUpdate.OnClientEvent:Connect(function(kind, info)
		if kind == "Started" then
			destination, destinationName = info.Position, info.Destination
			marker.Position = info.Position + Vector3.new(0, 15, 0)
			markerText.Text = "▼ " .. info.Destination
			marker.Parent = workspace
			distanceLabel.Visible = true
		elseif kind == "Completed" then
			clear()
			popup.Text = "Ferry complete! +$" .. info.Payout
			popup.Visible = true
			task.delay(3, function()
				popup.Visible = false
			end)
		else
			clear()
		end
	end)

	RunService.RenderStepped:Connect(function()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if destination and root then
			distanceLabel.Text = string.format("%s: %d studs", destinationName, math.floor((destination - root.Position).Magnitude))
		end
	end)
end

return FerryHUDController
