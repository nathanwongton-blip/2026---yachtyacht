-- Shared constants. Lives in ReplicatedStorage so clients can read prices and gacha odds.
local GameConfig = {}

GameConfig.Currency = { Cash = "Cash" }
GameConfig.StartingCash = 100
GameConfig.StartingBoat = "Rowboat"
GameConfig.IncomeTickSeconds = 1
GameConfig.AutosaveSeconds = 120

-- Keys match the "Location" attribute on FerryDock / BoatSpawn parts in the world.
GameConfig.Locations = {
	RobloxiaPort = { Name = "Robloxia Port" },
	CoralRiviera = { Name = "Coral Riviera" },
	LagoonAtoll = { Name = "Lagoon Atoll" },
	ClassicIslands = { Name = "Classic Islands" },
}

-- MaxSpeed in studs/s, TurnSpeed in rad/s, RentalIncome in cash per rental tick.
GameConfig.Boats = {
	Rowboat = { Name = "Rowboat", Tier = 1, MaxSpeed = 25, TurnSpeed = 1.2, Capacity = 2, RentalIncome = 0 },
	Speedboat = { Name = "Speedboat", Tier = 2, MaxSpeed = 60, TurnSpeed = 1.6, Capacity = 4, RentalIncome = 10 },
	Cruiser = { Name = "Cruiser", Tier = 3, MaxSpeed = 50, TurnSpeed = 1.0, Capacity = 8, RentalIncome = 30 },
	Yacht = { Name = "Yacht", Tier = 4, MaxSpeed = 45, TurnSpeed = 0.8, Capacity = 16, RentalIncome = 80 },
	MegaYacht = { Name = "Mega Yacht", Tier = 5, MaxSpeed = 40, TurnSpeed = 0.5, Capacity = 32, RentalIncome = 250 },
}

-- Pricing tiers: bought in this order. Income is cash per second. Boat is granted on purchase.
GameConfig.DockUnlocks = {
	{ Id = "WoodenDock", Name = "Wooden Dock", Price = 50, Income = 2 },
	{ Id = "BaitShop", Name = "Bait Shop", Price = 250, Income = 5, Boat = "Speedboat" },
	{ Id = "FuelStation", Name = "Fuel Station", Price = 1000, Income = 15 },
	{ Id = "Marina", Name = "Marina", Price = 5000, Income = 40, Boat = "Cruiser" },
	{ Id = "YachtClub", Name = "Yacht Club", Price = 25000, Income = 120, Boat = "Yacht" },
	{ Id = "PrivateIsland", Name = "Private Island", Price = 150000, Income = 500, Boat = "MegaYacht" },
}

GameConfig.Ferry = {
	PayPerStudPerPassenger = 0.02,
	-- Trips faster than distance / (MaxSpeed * this) are rejected as teleports.
	MinTripSpeedFactor = 1.5,
}

-- Multipliers from hired NPCs.
GameConfig.NPC = {
	BookingManager = { Cost = 2000, RentalBonus = 0.25, Max = 5 },
}

GameConfig.Rental = {
	TickSeconds = 60,
	CustomizationBonusPerField = 0.05,
}

GameConfig.Secrets = {
	SunkenChest = { Name = "Sunken Chest", Cash = 500 },
	CaveIdol = { Name = "Cave Idol", Cash = 1500 },
	LighthouseKey = { Name = "Lighthouse Key", Cash = 5000 },
}

GameConfig.Customization = {
	Palette = {
		Color3.fromRGB(245, 245, 245),
		Color3.fromRGB(20, 20, 20),
		Color3.fromRGB(200, 30, 30),
		Color3.fromRGB(30, 90, 200),
		Color3.fromRGB(40, 170, 80),
		Color3.fromRGB(240, 200, 30),
		Color3.fromRGB(255, 105, 180),
		Color3.fromRGB(0, 230, 230),
	},
	InteriorThemes = { "Classic", "Modern", "Tropical", "Neon" },
}

-- Weights are relative. Every pool must have at least one item of every rarity.
GameConfig.Gacha = {
	MaxEquipped = 3,
	MaxInventory = 200,
	Rarities = { Common = 60, Rare = 25, Epic = 10, Legendary = 4, Mythic = 1 },
	Pools = {
		Crew = {
			Cost = 500,
			Items = {
				DeckHand = { Name = "Deck Hand", Rarity = "Common", IncomeBonus = 0.05 },
				Cook = { Name = "Cook", Rarity = "Common", IncomeBonus = 0.05 },
				Navigator = { Name = "Navigator", Rarity = "Rare", IncomeBonus = 0.1 },
				MasterMechanic = { Name = "Master Mechanic", Rarity = "Epic", IncomeBonus = 0.2 },
				CelebrityDJ = { Name = "Celebrity DJ", Rarity = "Legendary", IncomeBonus = 0.35 },
				LegendaryCaptain = { Name = "Legendary Captain", Rarity = "Mythic", IncomeBonus = 0.6 },
			},
		},
		Pets = {
			Cost = 300,
			Items = {
				Seagull = { Name = "Seagull", Rarity = "Common", IncomeBonus = 0.03 },
				Crab = { Name = "Crab", Rarity = "Common", IncomeBonus = 0.03 },
				PartyMonkey = { Name = "Party Monkey", Rarity = "Rare", IncomeBonus = 0.08 },
				GoldenDolphin = { Name = "Golden Dolphin", Rarity = "Epic", IncomeBonus = 0.15 },
				CaptainDoge = { Name = "Captain Doge", Rarity = "Legendary", IncomeBonus = 0.3 },
				BabyKraken = { Name = "Baby Kraken", Rarity = "Mythic", IncomeBonus = 0.5 },
			},
		},
	},
}

GameConfig.Party = {
	AccessModes = { "Public", "Friends", "Private" },
	DefaultAccess = "Friends",
	CellSize = 4,
	MaxFurniture = 50,
	-- Size is in grid cells (X by Z), Height in studs.
	Furniture = {
		DJBooth = { Name = "DJ Booth", Price = 1000, Size = Vector2.new(2, 1), Height = 4 },
		DanceFloor = { Name = "Dance Floor", Price = 2500, Size = Vector2.new(3, 3), Height = 0.5 },
		DiscoLight = { Name = "Disco Light", Price = 400, Size = Vector2.new(1, 1), Height = 6 },
		Couch = { Name = "Couch", Price = 300, Size = Vector2.new(2, 1), Height = 2 },
	},
}

-- Dark UI theme shared by every client controller.
GameConfig.UI = {
	Background = Color3.fromRGB(18, 18, 22),
	BackgroundTransparency = 0.1,
	Surface = Color3.fromRGB(38, 39, 46),
	Text = Color3.fromRGB(235, 235, 240),
	TextMuted = Color3.fromRGB(140, 142, 150),
	Highlight = Color3.fromRGB(255, 220, 60),
	Success = Color3.fromRGB(34, 110, 60),
	Party = Color3.fromRGB(95, 40, 110),
}

return GameConfig
