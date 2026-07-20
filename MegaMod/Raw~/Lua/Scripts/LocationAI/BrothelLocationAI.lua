--[[------------------------------------------------------------------------------
Brothel Roles
--------------------------------------------------------------------------------]]

_namespace = "LOCATION_AI_ROLES"
_id = "BROTHEL_WORKER"

_goal = "BrothelWorker"
_actorConfigs =
{
    -- Female Variants
    "NPC.BROTHEL_WORKER_1", -- White, short black hair
    "NPC.BROTHEL_WORKER_2", -- Black, short curley hair
    "NPC.BROTHEL_WORKER_3", -- White, medium length blonde hair
    --"NPC.BROTHEL_WORKER_4", -- White, medium length blonde hair (Appears the same as NPC.BROTHEL_WORKER_3)
    --"NPC.BROTHEL_WORKER_5", -- White, short black hair (Appears the same as NPC.BROTHEL_WORKER_1)
    -- Male Variants
    -- "NPC.BROTHEL_WORKER_6", -- Black, shirtless, bow-tie
    -- "NPC.BROTHEL_WORKER_7", -- Black, shirtless, bow-tie, jacket
    -- "NPC.BROTHEL_WORKER_8", -- Black, shirtless, bow-tie (Appears the same as NPC.BROTHEL_WORKER_6)
    -- "NPC.BROTHEL_WORKER_9", -- Black, shirtless, bow-tie, jacket (Appears the same as NPC.BROTHEL_WORKER_7)
}
_stationKey = "BROTHEL_WORKER"


--[[------------------------------------------------------------------------------
Brothel CommonArea
--------------------------------------------------------------------------------]]

_namespace = "LOCATION_AI_FEATURES"
_id = "COMMON_AREA_BROTHEL"
_includes = "COMMON_AREA"
roles =
{
    "BARKEEP",
    "PATRON",
    "BROTHEL_WORKER",
    "MANAGER",
    "GUARD",
}
tags =
{
    "SOCIALIZE",
    "IDLE",
    "EXIT",
    "ENTRANCE",
    "SPAWN_PLAYER_COMBAT",
    "COLLECTIBLE",
    "PLAY_CARDS",
    "MEET_CLIENT",
    "MEET_WORKER",
    "BEAUTY_SHOT",
    "SIT_FRONT",
    "SIT_BACK",
}
linkTypes =
{
    "meetsClient"
}


--[[------------------------------------------------------------------------------
Base Room Feature
--------------------------------------------------------------------------------]]

_id = "BROTHEL_ROOM_BASE_FEATURE"
_editorIcon = "PrivateRoom"
_featureType = "BrothelRoom"
_abstract = true
roles =
{
    "BROTHEL_WORKER",
    "PATRON",
}
tags =
{
    "PRIVATE_ROOM",
}

--[[------------------------------------------------------------------------------
STANDARD BROTHEL ROOM Feature
--------------------------------------------------------------------------------]]

_id = "STANDARD_BROTHEL_ROOM"
_includes = "BROTHEL_ROOM_BASE_FEATURE"

featureRoles =
{
    ["LOCATION_AI_ROLES.BROTHEL_WORKER"] = { count = 1 },
}
