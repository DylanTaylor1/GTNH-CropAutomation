local database = require('database')
local gps = require('gps')
local posUtil = require('posUtil')
local scanner = require('scanner')
local action = require('action')
local config = require('config')
local emptySlot
local targetCrop

-- ================== HANDLING SPREAD ====================

local function findEmpty()
    local farm = database.getFarm()

    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]
        if crop.name == 'air' or crop.name == 'emptyCrop' then
            emptySlot = slot
            return true
        end
    end
    return false
end

-- ====================== SCANNING ======================

local function checkChild(slot, crop)
    if crop.isCrop and crop.name ~= 'emptyCrop' then

        if crop.name == 'air' then
            action.placeCropStick(2)

        elseif scanner.isWeed(crop) then
            action.deweed()
            action.placeCropStick()

        elseif crop.name == targetCrop then
            local stat = crop.gr + crop.ga - crop.re
            if stat >= config.autoSpreadThreshold then

                -- Make sure no parent on the working farm is empty
                if findEmpty() then
                    action.transplant(posUtil.workingSlotToPos(slot), posUtil.workingSlotToPos(emptySlot))
                    action.placeCropStick(2)
                    database.updateFarm(emptySlot, crop)

                -- No parent is empty, put in storage
                else
                    action.transplant(posUtil.workingSlotToPos(slot), posUtil.storageSlotToPos(database.nextStorageSlot()))
                    database.addToStorage(crop)
                    action.placeCropStick(2)
                end
            else
                action.deweed()
                action.placeCropStick()
            end

        elseif config.keepMutations and (not database.existInStorage(crop)) then
            action.transplant(posUtil.workingSlotToPos(slot), posUtil.storageSlotToPos(database.nextStorageSlot()))
            action.placeCropStick(2)
            database.addToStorage(crop)

        else
            action.deweed()
            action.placeCropStick()
        end
    end
end


local function checkParent(slot, crop)
    if crop.isCrop and crop.name ~= 'air' and crop.name ~= 'emptyCrop' then
        if scanner.isWeed(crop) then
            action.deweed()
            database.updateFarm(slot, {isCrop=true, name='emptyCrop'})
        end
    end
end

-- ====================== SPREADING ======================

local function spreadOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if #database.getStorage() >= config.storageFarmArea then
            print('autoSpread: Storage Full!')
            return false
        end

        -- Scan
        gps.go(posUtil.workingSlotToPos(slot))
        local crop = scanner.scan()

        if slot % 2 == 0 then
            checkChild(slot, crop)
        else
            checkParent(slot, crop)
        end

        if action.needCharge() then
            action.charge()
        end
    end
    return true
end

-- ======================== MAIN ========================

local function init()
    database.resetStorage()
    database.scanFarm()
    action.restockAll()

    targetCrop = database.getFarm()[1].name
    print(string.format('autoSpread: Target %s', targetCrop))
end


local function main()
    init()

    -- Loop
    while spreadOnce() do
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    print('autoSpread: Complete!')
end

main()
