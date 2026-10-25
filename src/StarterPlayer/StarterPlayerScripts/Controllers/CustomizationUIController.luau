-- Panel for hull color, LED toggle/color, interior theme, and flag image id. Applies to the active boat.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteEvents = require(ReplicatedStorage.Modules.Network.RemoteEvents)

local PALETTE = GameConfig.Customization.Palette
local THEMES = GameConfig.Customization.InteriorThemes
local UI = GameConfig.UI
local player = Players.LocalPlayer

local CustomizationUIController = {}

local function button(parent: Instance, text: string, size: UDim2): TextButton
	local b = Instance.new("TextButton")
	b.Size = size
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = UI.Text
	b.BackgroundColor3 = UI.Surface
	b.BorderColor3 = UI.Text
	b.BorderSizePixel = 0
	b.Parent = parent
	return b
end

local function row(parent: Instance, order: number): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = order
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 4)
	layout.Parent = frame
	frame.Parent = parent
	return frame
end

local function swatches(parent: Instance, onPick: (number) -> ())
	local buttons = {}
	for index, color in PALETTE do
		local swatch = button(parent, "", UDim2.fromOffset(28, 28))
		swatch.BackgroundColor3 = color
		swatch.Activated:Connect(function()
			for _, other in buttons do
				other.BorderSizePixel = 0
			end
			swatch.BorderSizePixel = 3
			onPick(index)
		end)
		table.insert(buttons, swatch)
	end
end

function CustomizationUIController.Start()
	local state = { LedEnabled = false, Interior = THEMES[1] }

	local gui = Instance.new("ScreenGui")
	gui.Name = "CustomizationUI"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local toggle = button(gui, "Customize", UDim2.fromOffset(120, 36))
	toggle.Position = UDim2.new(0, 12, 1, -48)

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromOffset(300, 260)
	panel.Position = UDim2.new(0, 12, 1, -320)
	panel.BackgroundColor3 = UI.Background
	panel.BackgroundTransparency = UI.BackgroundTransparency
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingTop, padding.PaddingLeft = UDim.new(0, 8), UDim.new(0, 8)
	padding.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = panel

	toggle.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)

	swatches(row(panel, 1), function(index)
		state.Color = index
	end)

	local ledRow = row(panel, 2)
	local ledToggle = button(ledRow, "LED: Off", UDim2.fromOffset(80, 28))
	ledToggle.Activated:Connect(function()
		state.LedEnabled = not state.LedEnabled
		ledToggle.Text = state.LedEnabled and "LED: On" or "LED: Off"
	end)
	swatches(row(panel, 3), function(index)
		state.LedColor = index
	end)

	local themeIndex = 1
	local theme = button(row(panel, 4), "Interior: " .. THEMES[1], UDim2.fromOffset(200, 28))
	theme.Activated:Connect(function()
		themeIndex = themeIndex % #THEMES + 1
		state.Interior = THEMES[themeIndex]
		theme.Text = "Interior: " .. state.Interior
	end)

	local flag = Instance.new("TextBox")
	flag.Size = UDim2.fromOffset(200, 28)
	flag.PlaceholderText = "Flag image asset id"
	flag.Text = ""
	flag.ClearTextOnFocus = false
	flag.Font = Enum.Font.Gotham
	flag.TextSize = 14
	flag.TextColor3 = UI.Text
	flag.PlaceholderColor3 = UI.TextMuted
	flag.BackgroundColor3 = UI.Surface
	flag.BorderSizePixel = 0
	flag.LayoutOrder = 5
	flag.Parent = panel

	local apply = button(panel, "Apply to active boat", UDim2.fromOffset(200, 32))
	apply.LayoutOrder = 6
	apply.BackgroundColor3 = UI.Success
	apply.Activated:Connect(function()
		local boatId = player:GetAttribute("ActiveBoat")
		if not boatId then
			apply.Text = "Spawn a boat first"
			task.delay(2, function()
				apply.Text = "Apply to active boat"
			end)
			return
		end
		local digits = flag.Text:match("%d+")
		state.Flag = digits and tonumber(digits)
		RemoteEvents.ApplyCustomization:FireServer(boatId, state)
	end)
end

return CustomizationUIController
