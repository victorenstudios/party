Config["AutoTimeFlag"] = true
Config["TimeFlag"] = {"03:00", "9:00", "14:00", "19:00", "13:48"}
Config["TimeToPlayFlag"] = 5 * min
Config["TimeToHoldFlag"] = 1 * min

Config["TimeToPickUPFlag"] = 10 * sec

Config["Flag"] = {
    [1] = {
        Label = "Flag 1",
        MaxPlayer = 100,
        Dimension = 79991,
        Coords = { x = -1737.010009765625, y= 159.57000732421875, z= 64.37000274658203, d = 100.0 },
        SpawnPlayer = { x = -1732.6099853515625, y= 154.5, z=64.37000274658203 },
        HealCoords = { x = -1740.469970703125, y=152.72000122070312, z=64.37000274658203 },
        Item = {
            -- [[{
            --     BlackMoney = {1500, 2000},
            --     Percent = 100
            -- },
            -- {
            --     Money = {1500, 2000},
            --     Percent = 100
            -- },]]
            {
                Item = "water",
                Count = {3, 3},
                Percent = 100
            },
        }
    },
}