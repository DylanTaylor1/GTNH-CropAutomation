local component = require('component')
local robot = require('robot')
local sides = require('sides')
local computer = require('computer')
local os = require('os')
local database = require('database')
local gps = require('gps')
local config = require('config')
local scanner = require('scanner')
local events = require('events')
local inventory_controller = component.inventory_controller
local redstone = component.redstone
local restockAll, cleanUp  -- Forward declaration

local function needCharge()
    return computer.energy() / computer.maxEnergy() < config.needChargeLevel
end


local function fullyCharged()
    return computer.energy() / computer.maxEnergy() > 0.99
end


local function fullInventory()
    for i=1, robot.inventorySize() do
        if robot.count(i) == 0 then
            return false
        end
    end
    return true
end

local function withSelectedSlot(fn, configTool, checkFullInventory)
    local selectedSlot = robot.select()
    if checkFullInventory == true then
        if fullInventory() then
            gps.save()
            dumpInventory()
            gps.resume()
        end
    end
    if configTool ~= nil then
        robot.select(robot.inventorySize() + configTool)
    end
    fn()
    robot.select(selectedSlot)
end

local function restockStick()
    withSelectedSlot(function()
        gps.go(config.stickContainerPos)
        for i=1, inventory_controller.getInventorySize(sides.down) do
            os.sleep(0)
            inventory_controller.suckFromSlot(sides.down, i, 64-robot.count())
            if robot.count() == 64 then
                break
            end
        end
    end, config.stickSlot)
end


local function dumpInventory()
    withSelectedSlot(function()
        gps.go(config.storagePos)

        for i=1, (robot.inventorySize() + config.storageStopSlot) do
            os.sleep(0)
            if robot.count(i) > 0 then
                robot.select(i)
                for e=1, inventory_controller.getInventorySize(sides.down) do
                    if inventory_controller.getStackInSlot(sides.down, e) == nil then
                        inventory_controller.dropIntoSlot(sides.down, e)
                        break
                    end
                end
            end
        end
    end)
end

local function placeCropStick(count)
    withSelectedSlot(function()
        local selectedSlot = robot.select()

        if count == nil then
            count = 1
        end

        if robot.count(robot.inventorySize() + config.stickSlot) < count + 1 then
            gps.save()
            restockStick()
            gps.resume()
        end

        robot.select(robot.inventorySize() + config.stickSlot)
        inventory_controller.equip()

        for _=1, count do
            robot.useDown()
        end

        inventory_controller.equip()
    end)
end

local function pulseDown()
    redstone.setOutput(sides.down, 15)
    os.sleep(0.1)
    redstone.setOutput(sides.down, 0)
end

local function deweed()
    withSelectedSlot(function()
        robot.select(robot.inventorySize() + config.spadeSlot)
        inventory_controller.equip()
        robot.useDown()
        robot.suckDown()

        inventory_controller.equip()
    end, config.spadeSlot, true)
end


local function harvest()
    withSelectedSlot(function()
        robot.swingDown()
        robot.suckDown()
    end, nil, true)
end


local function transplant(src, dest)
    withSelectedSlot(function()
        gps.save()
        inventory_controller.equip()

        -- Transfer to relay location
        gps.go(src)
        robot.useDown(sides.down, true)
        gps.go(config.dislocatorPos)
        pulseDown()

        -- Transfer crop to destination
        robot.useDown(sides.down, true)
        gps.go(dest)

        local crop = scanner.scan()
        if crop.name == 'air' then
            placeCropStick()

        elseif crop.isCrop == false then
            database.addToStorage(crop)
            gps.go(gps.storageSlotToPos(database.nextStorageSlot()))
            placeCropStick()
        end

        robot.useDown(sides.down, true)
        gps.go(config.dislocatorPos)
        pulseDown()

        -- Reprime binder
        robot.useDown(sides.down, true)

        -- Destroy original crop
        inventory_controller.equip()
        gps.go(config.relayFarmlandPos)
        robot.swingDown()
        robot.suckDown()

        gps.resume()
    end, config.binderSlot)
end


function cleanUp()
    for slot=1, config.workingFarmArea, 1 do
        -- Scan
        gps.go(gps.workingSlotToPos(slot))
        local crop = scanner.scan()

        -- Remove all children and empty parents
        if slot % 2 == 0 or crop.name == 'emptyCrop' then
            robot.swingDown()

        -- Remove bad parents
        elseif crop.isCrop and crop.name ~= 'air' then
            if scanner.isWeed(crop, 'working') then
                robot.swingDown()
            end
        end

        -- Pickup
        robot.suckDown()
    end
    events.setNeedCleanup(false)
    restockAll()
end


local function primeBinder()
    withSelectedSlot(function()
        inventory_controller.equip()

        -- Use binder at start to reset it, if already primed
        robot.useDown(sides.down, true)

        gps.go(config.dislocatorPos)
        robot.useDown(sides.down)

        inventory_controller.equip()
    end, config.binderSlot)
end


local function charge()
    gps.go(config.chargerPos)
    gps.turnTo(1)
    repeat
        os.sleep(0.5)
        if events.needExit() then
            if events.needCleanup() and config.cleanUp then
                events.setNeedCleanup(false)
                cleanUp()
            end
            os.exit() -- Exit here to leave robot in starting position
        end
    until fullyCharged()
end

local function clearDown()
    withSelectedSlot(function()
        inventory_controller.equip()
        robot.useDown()
        robot.swingDown()
        robot.suckDown()
        inventory_controller.equip()
    end, config.spadeSlot, true)
end

function restockAll()
    dumpInventory()
    restockStick()
    charge()
end


local function initWork()
    events.initEvents()
    events.hookEvents()
    charge()
    database.resetStorage()
    primeBinder()
    restockAll()
end


return {
    needCharge = needCharge,
    charge = charge,
    restockStick = restockStick,
    dumpInventory = dumpInventory,
    restockAll = restockAll,
    placeCropStick = placeCropStick,
    pulseDown = pulseDown,
    deweed = deweed,
    harvest = harvest,
    transplant = transplant,
    cleanUp = cleanUp,
    initWork = initWork,
    clearDown = clearDown
}