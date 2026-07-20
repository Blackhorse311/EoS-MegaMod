--$$ Empire

local ConfigBuilder = require("Libs.ConfigBuilder")

ConfigBuilder.define("STORES",
{
    SLAB_STORE =
    {
        name = "$Black_Market", --$ Black Market
        lootDropGenerateStockFn = "generateBlackMarketStock",
        resupplyFrequency = 15,

    --[[---------------------------------------------
    HANDGUNS
    -----------------------------------------------]]

	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_HANDGUN_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_HANDGUN_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_HANDGUN_06",
        stock = 2,
		persistingStock = true,
    },

	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_HANDGUN_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_HANDGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_HANDGUN_02",
        stock = 2,
		persistingStock = true,
    },

    --[[---------------------------------------------
    SHOTGUN
    -----------------------------------------------]]
    
	{
        item = "ITEM.WEAPON.COMMON_SHOTGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SHOTGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SHOTGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SHOTGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SHOTGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SHOTGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SHOTGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SHOTGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SHOTGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SHOTGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SHOTGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SHOTGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SHOTGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SHOTGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SHOTGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SHOTGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SHOTGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SHOTGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SHOTGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SHOTGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_SHOTGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_SHOTGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
    --[[---------------------------------------------
    RIFLES
    -----------------------------------------------]]
    {
        item = "ITEM.WEAPON.COMMON_RIFLE_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_RIFLE_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_RIFLE_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_RIFLE_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_RIFLE_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_RIFLE_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_RIFLE_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_RIFLE_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_RIFLE_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_RIFLE_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_RIFLE_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_RIFLE_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_RIFLE_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_RIFLE_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_RIFLE_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_RIFLE_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_RIFLE_01",
        stock = 2,
		persistingStock = true,
    },

    --[[---------------------------------------------
    SNIPER RIFLES
    -----------------------------------------------]]

	{
        item = "ITEM.WEAPON.COMMON_SNIPER_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SNIPER_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SNIPER_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SNIPER_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SNIPER_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SNIPER_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SNIPER_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SNIPER_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SNIPER_06",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_SNIPER_01",
        stock = 2,
		persistingStock = true,
    },

    --[[---------------------------------------------
    SUBMACHINE GUNS
    -----------------------------------------------]]

	{
        item = "ITEM.WEAPON.COMMON_SUBGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SUBGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SUBGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SUBGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.COMMON_SUBGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SUBGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SUBGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SUBGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SUBGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.UNCOMMON_SUBGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SUBGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SUBGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SUBGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SUBGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.RARE_SUBGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SUBGUN_01",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SUBGUN_02",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SUBGUN_03",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SUBGUN_04",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.EPIC_SUBGUN_05",
        stock = 2,
		persistingStock = true,
    },
	
	{
        item = "ITEM.WEAPON.LAW_SUBGUN_01",
        stock = 2,
		persistingStock = true,
    },

    --[[---------------------------------------------
    MACHINEGUNS
    -----------------------------------------------]]
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MACHINEGUN_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MACHINEGUN_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MACHINEGUN_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MACHINEGUN_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MACHINEGUN_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MACHINEGUN_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MACHINEGUN_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MACHINEGUN_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MACHINEGUN_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MACHINEGUN_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MACHINEGUN_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MACHINEGUN_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MACHINEGUN_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MACHINEGUN_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MACHINEGUN_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MACHINEGUN_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.LAW_MACHINEGUN_01",
	  stock = 2,
	  persistingStock = true,
	
	},

    --[[---------------------------------------------
    MELEE WEAPONS
    -----------------------------------------------]]
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_STILETTO",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_BRASS_KNUCKLES",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_CROWBAR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_POLICE_BATON",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_RAZOR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_LEAD_PIPE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_BOWIE_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_MEAT_CLEAVER",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_SLEDGEHAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_MACHETE",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_BASEBALL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_HAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_TRENCH_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_AXE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.COMMON_MELEE_NAIL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},

{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_STILETTO",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_BRASS_KNUCKLES",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_CROWBAR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_POLICE_BATON",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_RAZOR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_LEAD_PIPE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_BOWIE_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_MEAT_CLEAVER",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_SLEDGEHAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_MACHETE",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_BASEBALL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_HAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_TRENCH_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_AXE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.UNCOMMON_MELEE_NAIL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_STILETTO",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_BRASS_KNUCKLES",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_CROWBAR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_POLICE_BATON",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_RAZOR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_LEAD_PIPE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_BOWIE_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_MEAT_CLEAVER",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_SLEDGEHAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_MACHETE",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_BASEBALL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_HAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_TRENCH_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_AXE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.RARE_MELEE_NAIL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_STILETTO",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_BRASS_KNUCKLES",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_CROWBAR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_POLICE_BATON",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_RAZOR",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_LEAD_PIPE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_BOWIE_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_MEAT_CLEAVER",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_SLEDGEHAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_MACHETE",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_BASEBALL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_HAMMER",
	  stock = 2,
	  persistingStock = true,
	
	},

	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_TRENCH_KNIFE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_AXE",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EPIC_MELEE_NAIL_BAT",
	  stock = 2,
	  persistingStock = true,
	
	},

    --[[---------------------------------------------
    EXPLOSIVES
    -----------------------------------------------]]

	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_05",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_06",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_07",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_08",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.WEAPON.EXPLOSIVE_09",
	  stock = 2,
	  persistingStock = true,
	
	},

    --[[---------------------------------------------
    HEALING ITEMS
    -----------------------------------------------]]
        {
            item = "ITEM.UTILITY.HEALING_ITEM_01",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_02",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_03",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_04",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_05",
            stock = 2,
            persistingStock = true,
        },
		
		{
            item = "ITEM.UTILITY.HEALING_ITEM_06",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_07",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_08",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_09",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_10",
            stock = 2,
            persistingStock = true,
        },
		{
            item = "ITEM.UTILITY.HEALING_ITEM_11",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_12",
            stock = 2,
            persistingStock = true,
        },
        {
            item = "ITEM.UTILITY.HEALING_ITEM_13",
            stock = 2,
            persistingStock = true,
        },

    --[[---------------------------------------------
    ARMOR ITEMS
    -----------------------------------------------]]
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_05",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_06",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.ARMOR.ARMOR_07",
	  stock = 2,
	  persistingStock = true,
	
	},
	
    --[[---------------------------------------------
    MISSION ITEMS
    -----------------------------------------------]]

    --[[---------------------------------------------
    S+ AMMO
    -----------------------------------------------]]
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_05",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_06",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_07",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_08",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.AMMO.SPECIAL_AMMO_09",
	  stock = 2,
	  persistingStock = true,
	
	},
    --[[---------------------------------------------
    TRINKETS
    -----------------------------------------------]]
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_01",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_02",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_03",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_04",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_05",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_06",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_07",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_08",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_09",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_10",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_11",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_12",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_13",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_14",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_15",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_16",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_17",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_18",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_19",
	  stock = 2,
	  persistingStock = true,
	
	},
	
	{
	  
	  item = "ITEM.EQUIPMENT.TRINKET_20",
	  stock = 2,
	  persistingStock = true,
	
	},
    --[[------------------------------------------------------------------------------
    <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    LEGENDARY WEAPONS

    <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    --------------------------------------------------------------------------------]]
        {
            item = "ITEM.WEAPON.LEGENDARY_SUBGUN_01",
            stock = 3,
            persistingStock = true,
        },
		
		{
			item = "ITEM.WEAPON.LEGENDARY_RIFLE_04",
			stock = 3,
			persistingStock = true,
		},
		
		{
            item = "ITEM.WEAPON.LEGENDARY_SNIPER_06",
            stock = 3,
            persistingStock = true,
        },
		
		{
			item = "ITEM.WEAPON.LEGENDARY_SHOTGUN_03",
			stock = 3,
			persistingStock = true,
		},
		
		{
			item = "ITEM.WEAPON.LEGENDARY_HANDGUN_06",
			stock = 3,
			persistingStock = true,
		},

		-- MegaMod: Named Legendary Weapons (rare, don't restock)
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_UNDERTAKER", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_LIGHTNING", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_LASTWORD", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_WHISPER", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_NEGOTIATOR", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_SWEEPER", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_TYPEWRITER", stock = 1, persistingStock = false },
		{ item = "ITEM.WEAPON.MEGAMOD_LEGENDARY_DEVILSHAND", stock = 1, persistingStock = false },

		-- MegaMod: Exotic Weapons
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_SAWEDOFF", stock = 2, persistingStock = true },
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_DERRINGER", stock = 2, persistingStock = true },
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_HOWITZER", stock = 2, persistingStock = true },
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_WHIPPET", stock = 2, persistingStock = true },
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_MARESLEG", stock = 2, persistingStock = true },
		{ item = "ITEM.WEAPON.MEGAMOD_EXOTIC_TRENCHRAIDER", stock = 2, persistingStock = true },
    },

})
