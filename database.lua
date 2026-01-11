local gps = require('gps')
local scanner = require('scanner')
local action = require('action')
local config = require('config')
local events = require('events')
local robot = require('robot')
local storage = {}
local reverseStorage = {}
local farm = {}

-- ======================== WORKING FARM ========================

local function getFarm()
    return farm
end


local function updateFarm(slot, crop)
    farm[slot] = crop
end

-- ======================== STORAGE FARM ========================

local function getStorage()
    return storage
end


local function resetStorage()
    storage = {}
end

local function updateStorage(slot, crop)
    storage[slot] = crop
    reverseStorage[crop.name] = slot
end


local function addToStorage(crop)
    storage[#storage+1] = crop
    reverseStorage[crop.name] = #storage
end


local function existInStorage(crop)
    if reverseStorage[crop.name] then
        return true
    else
        return false
    end
end


local function nextStorageSlot()
    return #storage + 1
end

local function analyzeStorage(existingTarget)
    if not config.checkStorageBefore then
        return
    end
    local targetCropName = getFarm()[1].name
    local storage = getStorage()
    for slot=1, config.storageFarmArea, 1 do
        gps.go(gps.storageSlotToPos(slot))
        local crop = scanner.scan()
        if crop.name ~= 'air' then
            if (existingTarget == true and crop.name ~= targetCropName) then
                action.clearDown()
            elseif scanner.isWeed(crop, 'storage') then
                action.clearDown()
            else
                updateStorage(slot, crop)
            end
        end
    end
end


return {
    getFarm = getFarm,
    updateFarm = updateFarm,
    updateStorage = updateStorage,
    getStorage = getStorage,
    resetStorage = resetStorage,
    addToStorage = addToStorage,
    existInStorage = existInStorage,
    nextStorageSlot = nextStorageSlot,
    analyzeStorage = analyzeStorage
}