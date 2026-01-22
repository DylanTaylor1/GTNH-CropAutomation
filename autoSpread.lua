local action = require('action')
local database = require('database')
local gps = require('gps')
local scanner = require('scanner')
local config = require('config')
local events = require('events')
local breedRound = 0
local emptySlot
local targetCrop

-- ===================== FUNCTIONS ======================

local function findEmpty()
    local farm = database.getFarm()

    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]
        if crop ~= nil and (crop.name == 'air' or crop.name == 'emptyCrop') then
            emptySlot = slot
            return true
        end
    end
    return false
end


local function checkChild(slot, crop)
    if crop.isCrop and crop.name ~= 'emptyCrop' then

        if crop.name == 'air' then
            action.placeCropStick(2)

        elseif scanner.isWeed(crop, 'storage') then
            action.deweed()
            action.placeCropStick()

        elseif crop.name == targetCrop then
            local stat = crop.gr + crop.ga - crop.re

            -- Make sure no parent on the working farm is empty
            if stat >= config.autoStatThreshold and findEmpty() and crop.gr <= config.workingMaxGrowth and crop.re <= config.workingMaxResistance then
                action.transplant(gps.workingSlotToPos(slot), gps.workingSlotToPos(emptySlot))
                action.placeCropStick(2)
                database.updateFarm(emptySlot, crop)

            -- No parent is empty, put in storage
            elseif stat >= config.autoSpreadThreshold then

                if config.useStorageFarm then
                    action.transplant(gps.workingSlotToPos(slot), gps.storageSlotToPos(database.nextStorageSlot()))
                    database.addToStorage(crop)
                    action.placeCropStick(2)

                elseif crop.size >= crop.max - 1 then
                    action.harvest()
                    action.placeCropStick(2)
                end

            -- Stats are not high enough
            else
                action.deweed()
                action.placeCropStick()
            end

        elseif config.keepMutations and (not database.existInStorage(crop)) then
            action.transplant(gps.workingSlotToPos(slot), gps.storageSlotToPos(database.nextStorageSlot()))
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
        if scanner.isWeed(crop, 'working') then
            action.deweed()
            database.updateFarm(slot, {isCrop=true, name='emptyCrop'})
        end
    end
end

-- ====================== THE LOOP ======================

local function spreadOnce(firstRun)
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if breedRound > config.maxBreedRound then
            print('autoSpread: Max Breeding Round Reached!')
            return false
        end

        -- Terminal Condition
        if #database.getStorage() >= config.storageFarmArea then
            print('autoSpread: Storage Full!')
            return false
        end

        -- Terminal Condition
        if events.needExit() then
            print('autoSpread: Received Exit Command!')
            return false
        end

        os.sleep(0)

        -- Scan
        gps.go(gps.workingSlotToPos(slot))
        local crop = scanner.scan()

        if firstRun then
            database.updateFarm(slot, crop)
            if slot == 1 then
                targetCrop = database.getFarm()[1].name
                print(string.format('autoSpread: Target %s', targetCrop))
            end
        end

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

local function main()
    action.initWork()
    print('autoSpread: Scanning Farm')

    -- First Run
    spreadOnce(true)
    action.analyzeStorage(true)
    action.restockAll()

    -- Loop
    while spreadOnce(false) do
        breedRound = breedRound + 1
        action.restockAll()
    end

    -- Terminated Early
    if events.needExit() then
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    events.unhookEvents()
    print('autoSpread: Complete!')
end

main()