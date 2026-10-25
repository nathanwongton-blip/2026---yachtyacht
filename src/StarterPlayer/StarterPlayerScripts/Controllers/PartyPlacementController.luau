-- Grid placement on your plot's PartyFloor. Pick an item, move the mouse to aim the ghost,
-- R rotates, click places, right-click a placed item removes it. The server re-validates everything.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteEvents = require(ReplicatedStorage.Modules.Network.RemoteEvents)

local PARTY = GameConfig.Party
local UI = GameConfig.UI
local player = Players.LocalPlayer

local PartyPlacementController = {}

local function myFloor(): (BasePart?, Instance?)
	local plots = workspace:FindFirstChild("Plots")
	for _, plot in plots and plots:GetChildren() or {} do
		if plot:GetAttribute("Owner") == player.UserId then
			local floor = plot:FindFirstChild("PartyFloor", true)
			return if floor and floor:IsA("BasePart") then floor else nil, plot
		end
	end
	return nil, nil
end

-- Keep in sync with PartyModeService.cellCFrame.
local function cellCFrame(floor: BasePart, x: number, z: number, w: number, d: number, height: number, rotated: boolean)
	local cell = PARTY.CellSize
	local offset = Vector3.new(
		-floor.Size.X / 2 + (x + w / 2) * cell,
		floor.Size.Y / 2 + height / 2,
		-floor.Size.Z / 2 + (z + d / 2) * cell
	)
	return floor.CFrame * CFrame.new(offset) * CFrame.Angles(0, rotated and math.pi / 2 or 0, 0)
end

local function raycastMouse(include: { Instance }): RaycastResult?
	local mouse = UserInputService:GetMouseLocation()
	local ray = workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = include
	return workspace:Raycast(ray.Origin, ray.Direction * 500, params)
end

function PartyPlacementController.Start()
	local selectedId: string?, rotated = nil, false
	local cellX, cellZ = 0, 0
	local ghost = Instance.new("Part")
	ghost.Anchored = true
	ghost.CanCollide = false
	ghost.CanQuery = false
	ghost.CanTouch = false
	ghost.Transparency = 0.5
	ghost.Color = Color3.fromRGB(80, 200, 255)

	local gui = Instance.new("ScreenGui")
	gui.Name = "PartyPlacement"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local list = Instance.new("Frame")
	list.Size = UDim2.fromOffset(160, 0)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.Position = UDim2.new(1, -172, 0.3, 0)
	list.BackgroundTransparency = 1
	list.Visible = false
	list.Parent = gui
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = list

	local function select(id: string?)
		selectedId = id
		ghost.Parent = if id then workspace else nil
	end

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.fromOffset(120, 36)
	toggle.Position = UDim2.new(0, 144, 1, -48)
	toggle.Text = "Party Build"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 14
	toggle.TextColor3 = UI.Text
	toggle.BackgroundColor3 = UI.Party
	toggle.BorderSizePixel = 0
	toggle.Parent = gui
	toggle.Activated:Connect(function()
		list.Visible = not list.Visible
		if not list.Visible then
			select(nil)
		end
	end)

	for id, item in PARTY.Furniture do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(160, 32)
		b.Text = item.Name .. " ($" .. item.Price .. ")"
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.TextColor3 = UI.Text
		b.BackgroundColor3 = UI.Surface
		b.BorderSizePixel = 0
		b.Parent = list
		b.Activated:Connect(function()
			select(if selectedId == id then nil else id)
		end)
	end

	RunService.RenderStepped:Connect(function()
		local floor = myFloor()
		local item = selectedId and PARTY.Furniture[selectedId]
		if not floor or not item then
			ghost.Parent = nil
			return
		end
		local w, d = item.Size.X, item.Size.Y
		if rotated then
			w, d = d, w
		end
		ghost.Size = Vector3.new(item.Size.X * PARTY.CellSize, item.Height, item.Size.Y * PARTY.CellSize)
		local hit = raycastMouse({ floor })
		if hit then
			local localPos = floor.CFrame:PointToObjectSpace(hit.Position)
			local cols = math.floor(floor.Size.X / PARTY.CellSize)
			local rows = math.floor(floor.Size.Z / PARTY.CellSize)
			cellX = math.clamp(math.floor((localPos.X + floor.Size.X / 2) / PARTY.CellSize - w / 2 + 0.5), 0, math.max(cols - w, 0))
			cellZ = math.clamp(math.floor((localPos.Z + floor.Size.Z / 2) / PARTY.CellSize - d / 2 + 0.5), 0, math.max(rows - d, 0))
			ghost.CFrame = cellCFrame(floor, cellX, cellZ, w, d, item.Height, rotated)
			ghost.Parent = workspace
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not list.Visible then
			return
		end
		if input.KeyCode == Enum.KeyCode.R then
			rotated = not rotated
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 and selectedId then
			local ok, err = RemoteEvents.PlaceFurniture:InvokeServer(selectedId, cellX, cellZ, rotated)
			if not ok then
				ghost.Color = Color3.fromRGB(255, 80, 80)
				task.delay(0.5, function()
					ghost.Color = Color3.fromRGB(80, 200, 255)
				end)
				warn(err)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			local _, plot = myFloor()
			local built = plot and plot:FindFirstChild("Built")
			local furniture = built and built:FindFirstChild("Furniture")
			local hit = furniture and raycastMouse({ furniture })
			local placed = hit and hit.Instance
			while placed and placed.Parent ~= furniture do
				placed = placed.Parent
			end
			local index = placed and placed:GetAttribute("FurnitureIndex")
			if index then
				RemoteEvents.RemoveFurniture:FireServer(index)
			end
		end
	end)
end

return PartyPlacementController
