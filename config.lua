local config = {
    -- NOTE: EACH CONFIG SHOULD END WITH A COMMA

    -- Side Length of Working Farm
    workingFarmSize = 6,
    -- Side Length of Storage Farm
    storageFarmSize = 9,

    -- Once complete, remove all extra crop sticks to prevent the working farm from weeding
    cleanUp = true,
    -- Moves crops to the storage farm, otherwise dumps everything in the storage chest.
    useStorageFarm = true,
    -- Keep crops that are not the target crop during autoSpread and autoStat
    keepMutations = false,
    -- Stat-up crops during autoTier (Very Slow)
    statWhileTiering = false,

    -- Minimum tier for the working farm during autoTier
    autoTierThreshold = 13,
    -- Minimum Gr + Ga - Re for the working farm during autoStat (21 + 31 - 0 = 52)
    autoStatThreshold = 52,
    -- Minimum Gr + Ga - Re for the storage farm during autoSpread (23 + 31 - 0 = 54)
    autoSpreadThreshold = 50,

    -- Maximum Growth for crops on the working farm
    workingMaxGrowth = 21,
    -- Maximum Resistance for crops on the working farm
    workingMaxResistance = 2,
    -- Maximum Growth for crops on the storage farm
    storageMaxGrowth = 23,
    -- Maximum Resistance for crops on the storage farm
    storageMaxResistance = 2,

    -- Minimum Charge Level
    needChargeLevel = 0.2,
    -- Max breeding round before termination of autoSpread or autoTier
    maxBreedRound = 1000,

    -- Check existing crops on the storage farm before spreading or tiering
    checkStorageBefore = false,

    -- =========== DO NOT CHANGE ===========

    -- The coordinate for the charger
    chargerPos = {0, 0},
    -- The coordinate for the crop stick container
    stickContainerPos = {-1, 0},
    -- The coordinate for the storage chest / trash can
    storagePos = {-2, 0},
    -- The coordinate for the farmland that the dislocator is facing
    relayFarmlandPos = {1, 1},
    -- The coordinate for the transvector dislocator
    dislocatorPos = {1, 2},

    -- The slot for the spade
    spadeSlot = 0,
    -- The slot for the transvector binder
    binderSlot = -1,
    -- The slot for crop sticks
    stickSlot = -2,
    -- The slot which the robot will stop storing items
    storageStopSlot = -3
}

config.workingFarmArea = config.workingFarmSize^2
config.storageFarmArea = config.storageFarmSize^2

return config