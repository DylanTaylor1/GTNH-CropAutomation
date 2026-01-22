# Introduction

These OpenComputers (OC) scripts automatically tier-up, stat-up, and spread (duplicate) IC2 crops for you. This guide walks through every step of the process, from building the crop bot to debugging and troubleshooting. No prior knowledge of OC is necessary.

The general idea is that the crop bot runs one of three executable programs while regularly checking and maintaining a **working farm** of crops (placing crop sticks, removing weeds, etc.). When necessary, it moves crops around entirely on its own through the use of a Transvector Dislocator. The ultimate goal of the crop bot is to populate a **storage farm** full of high-stat crops to be used elsewhere for harvesting. There is no player intervention beyond supplying the crop bot with crop sticks, activating the crop bot, and collecting the final products.

Is this even worth it? Consider, for example, a field of 1/1/1 stickreed and another field of 21/31/0 stickreed. Keep every other variable constant and the high-stat field produces sticky resin **8x faster** than the low-stat one. That is a very significant difference for the time it takes to build and use the crop bot.

# Bare Minimum Components

The following requires access to EV circuits and epoxid (mid-late HV). It is possible to save some resources by not including the internet card, but that will require manually copying and pasting the code from GitHub which is NOT recommended for multiple reasons. Both inventory upgrades are necessary. Do not mix up central processing unit (CPU) with accelerated processing unit (APU).

- OC Electronics Assembler
- OC Charger
- Tier 2 Computer Case
- Tier 2 Memory
- Tier 1 Accelerated Processing Unit [1]
- Tier 1 Hard Disk Drive
- Tier 1 Screen
- Tier 1 Redstone Card
- Internet Card
- Geolyzer
- Keyboard
- Disk Drive (Block)
- Inventory Controller Upgrade
- Inventory Upgrade
- EEPROM (Lua BIOS) [2]
- OpenOS Floppy Disk [3]

![CropBot-Components](media/CropBot-Components.png?)

Lastly, you need a Transvector Binder and Transvector Dislocator which requires some progression in Thaumcraft. Neither are very difficult to craft even if you have yet to start Thaumcraft. In the thaumonomicon, Transvector Dislocator can be found under "Thaumic Tinkerer" which requires both Transvector Interface and Smokey Quartz on the same tab. You will also need to complete research on Mirror Magic under "Artifice." For more information, visit https://wiki.gtnewhorizons.com/wiki/Thaumcraft_Research_Cheatsheet.

[1]  In GTNH 2.7.0, the APU (yellow) was renamed from Tier 2 to Tier 1. Follow the image if you are unsure.
[2]  The EEPROM without Lua BIOS does not work.
[3]  Any other type of floppy disk does not work. The OpenOS one is green and says OpenOS in the tooltip.

# Building the Robot

1) Insert the computer case into the OC Electronics Assembler which can be powered directly by any GT cable.
2) Shift-click all the components into the computer case except the OpenOS floppy disk.
3) Click assemble and wait until it completes (~3 min).
4) Rename the robot in an anvil (optional).
5) Place the robot on the OC Charger which can also be powered directly by any GT cable. The OC Charger must be activated using some form of redstone such as a lever.
6) Insert the OpenOS floppy disk into the disk slot of the robot and press the power button.
7) Follow the commands on screen 'install' --> 'Y' --> 'Y' (The OpenOS floppy disk is no longer needed in the robot afterwards).
8) Install the required scripts by copying this line of code into the robot (middle-click to paste).

        wget https://raw.githubusercontent.com/DylanTaylor1/GTNH-CropAutomation/main/setup.lua && setup

9) Edit the config (not recommended, but check it out) by entering:

        edit config.lua

10) Place the Spade and Transvector Binder into the last and second to last slot of the robot, respectively. Crop sticks will go in the third, but it is not required to put them in yourself. An axe or mattock can also be placed into the tool slot of the robot to speed up destroying crops (optional). See the image below.

![CropBot-Inventory](media/CropBot-Inventory.png?)

# Building the Farms

**Find a location with good environmental stats**. It is recommended to set everything up in a Jungle or Swamp biome at Y=130 as that will give you the highest humidity and air quality stats. If not, crops run the risk of randomly dying and leaving the farms susceptible to weeds. This is most easily done in a personal dimension which you earn as a quest reward from reaching the moon. Do not place any solid blocks above the farm as that will reduce the air quality. All of the machines on the surface are waterproof so do not worry about the rain. Use vanilla dirt because that will allow you to grow crops that require a particular block underneath, and boost the nutrient stat of your crops. The whole farm can easily fit into a single chunk for easy chunk loading.

**You may change both the size of the working farm and the size of the storage farm** in the config (default is 6x6 and 9x9, respectively). Larger working farm sizes will extend left and up while larger storage farm sizes will extend down and to the right (see image below). The top row of the working farm will always align with the top row of the storage farm. There is no maximum or minimum size for either farm and it does not matter if the lengths are even or odd. However, larger storage farms leave the working farm more susceptible to weeds because the robot has to travel farther when transporting crops and less time is spent scanning the working farm. The transvector dislocator also has a maximum range of 16 blocks. Changing anything in the config requires you to restart your robot.

![CropBot-FarmTop](media/CropBot-FarmTop.png?)

![CropBot-FarmSide](media/CropBot-FarmSide.png?)

First note the orientation of the robot sitting atop the OC charger. It must face towards the right-most column of the working farm. Adjacent to the OC charger is the crop stick chest which can be a few things: any sort of large chest, a JABBA barrel, or storage drawer (orientation does not matter). If the crop stick chest is ever empty, bad things will happen. Next to that is a Trash Can for any random drops that the robot picks up such as weeds, seed bags, and crop sticks but this can be swapped with another chest to recycle some of the materials. The transvector dislocator sits facing the top of the blank farmland (where a crop would go). You can tell which direction the transvector dislocator is facing by the side that is animated. The blank farmland itself acts as a buffer between the working and storage farms. Optionally, place a crop manager nearby (with harvesting disabled) to hydrate and/or fertilize the crops to help them grow faster.

**The location of the water is completely flexible**. They do not have to be in the same locations as in the photo (underneath all five grates) and you can have as many as you would like on both the working farm and storage farm. However, there MUST be a block on top of each water and no two can be next to each other. The block can be literally anything, even a lily pad will work, so long as there is something. It is also possible to use garden soil or fertilized dirt and have absolutely no water on the farms at all, but that sacrifices a few nutrient stats and prevents you from growing crops that require a particular block underneath.

**The starting crops must be placed manually in the checkerboard pattern** seen in the photo. This layout goes for all three programs. If you cannot fill the entire checkerboard to start, the absolute minimum required is two (one as the target crop and the other next to it for crossbreeding). Even worse, if you have just a single seed of your target crop, it is possible to start with a different crop next to it for crossbreeding (ie. Stickreed). It is not necessary to place empty crop sticks to fill the rest of the checkerboard. The target crop is used by autoStat and autoSpread to identify the crop you want to stat-up or spread to the storage farm, respectively.

![CropBot-FarmBottom](media/CropBot-FarmBottom.png?)

**Underneath the farm**, you can see that there are three additional dirt blocks below each farmland, each of which add to the nutrient stat of the crop above it. For crops requiring a block underneath, that should be placed at the bottom. In the example above, there is diareed planted on top with one farmland --> two dirt --> one diamond block underneath each one. Diamond blocks are not underneath the working farm because the diareed does not need to be fully grown in order to spread.

**For power**, there is a single HV gas turbine and a super tank with some benzene (no transformer needed). This is a little overkill, but the important part is that the charger is always at 100% charging speed which you can see by hovering over it. A set-up such as this will last forever with a few hundred thousand benzene since both machines require very little EU/t.

# Running the Programs

The first program **autoTier** automatically tiers-up your crops until the max breeding round is reached (configurable), the storage farm is full, or ALL crops meet the specified tier threshold which defaults to 13. This is the best program for discovering new crops because unrecognized crops are first moved to the storage farm before replacing any of the lower tier crops on the working farm. Statting-up crops during this program is an option that can be enabled in the config, but that will slow down the process significantly. To run, simply enter:

    autoTier

The second program **autoStat** automatically stats-up the target crop until the Gr + Ga - Re is at least 52 (configurable) for ALL crops on the working farm. The maximum growth and resistance stats for parent crops are also configurable parameters which default to 21 and 2, respectively. Any crops with stats higher than these are interpreted as weeds and removed. To run, simply enter:

    autoStat

The third program **autoSpread** automatically spreads (duplicates) the target crop until the storage farm is full. New crops are only moved to the storage farm if their Gr + Ga - Re is at least 50 (configurable). The maximum growth and resistance stats for child crops are also configurable parameters which default to 23 and 2, respectively. To run, simply enter:

    autoSpread

(Optional) Disable useStorageFarm in the config to harvest child crops on the working farm during autoSpread instead of moving them to the storage farm. They are only harvested once they reach their maximum growth stage - 1 for the best chances at dropping seeds. Everything is deposited in the storage chest, including other types of seeds and those that do not meet the autoSpreadThreshold. This setting also causes autoSpread to run until the maximum breeding round is reached which means a single iteration can collect hundreds of seeds. It is recommended to use a full-block ME interface as the storage chest if using this method.

Lastly, these programs can be chained together. This may be helpful if you have brand new crops (ie. 1/1/1 spruce saplings) and want them to immediately start spreading once fully statted-up. No crops are added to the storage farm until autoStat is complete. Note that keepMutations in the config should probably be set to false (default) otherwise the storage farm will be overwritten once the second program begins. To run autoSpread after autoStat, simply enter:

    autoStat && autoSpread

Turn off the OC Charger to **pause** the robot during any of these programs. The robot will not resume until fully charged. Press 'Q' while in the interface of the robot to terminate the program immediately, or press 'C' to terminate the program immediately AND cleanup. One last reminder that changing anything in the config requires you to restart your robot.

# Troubleshooting

1) **The Transvector Dislocator is randomly moved to somewhere on the working farm.** Cover your water sources. Otherwise the order of the transvector binder will get messed up and teleport the dislocator instead of a crop.

2) **The Robot is randomly moved to somewhere on the working farm.** Check the orientation of the transvector dislocator. This can only happen if the dislocator is facing up instead of forward.

3) **The Robot is destroying all of the crops that were manually placed.** Either the resistance or growth stats of the parent crops are too high. By default, anything above 2 resistance or 21 growth is treated like a weed and will be removed. These values, including the maximum stats of child crops, are all easily changed in the config.

4) **Crops are randomly dying OR the farms are being overrun with weeds OR there are single crop sticks where there should be double.** Possibly change location. Crops have minimum environmental stat requirements (nutrients, humidity, air quality) and going below this threshold will kill the crop and leave an empty crop stick behind that is susceptible to growing weeds and overtaking the farms.

5) **There is a PKIX path building error when downloading the files from GitHub.** Try updating your java (to 21), but be prepared to install the files by manually copy-pasting the code from GitHub (only 256 characters can be pasted at a time). The Other Helpful Commands section below can help with that.

6) **There is an "execute_complex" error when downloading the files from GitHub or trying to run autoStat && autoSpread.** The execute complex refers to using the && operator. Double check that you installed at least Tier 2 memory. Anything less prevents you from joining commands together. If you do have Tier 2 memory, try adding in a second Tier 2 memory or even upgrading to a higher tier.

7) **The robot crashes when it reaches the crop stick chest.** This is likely due to a permissions issue with Server Utilities. Enter the "My Team" menu through the button in the top left corner of your inventory and then open up settings. Set the required level for block editing, block interactions, and using items to None.

8) **Config changes are not saving.** Any changes made to config.lua must be saved before restarting the robot. Save changes by pressing CTRL+S and exit with CTRL+W.

9) **The robot fails to properly teleport crops to the storage farm.** Ensure that the entire storage farm is within the 16 block range of the Transvector Dislocator.

## Recommended Crops

For starters, it is recommend to use the following crops because their outputs are useful and not completely overshadowed by bees. Note that every crop has a higher chance of being discovered with specific parent combinations, but it is often easier to discover a crop from crossbreeding at the same tier. For example, diareed has the highest chance of being discovered when the parents are oilberry and bobsyeruncleranks, BUT it is much easier to just run autoTier with all Tier 12 crops (or autoSpread with keepMutations on in the config). Crops that require a particular block underneath do not need to be fully grown in order to spread. For a full list of crops and their requirements, visit https://wiki.gtnewhorizons.com/wiki/IC2_Crops_List.

- **Stickreed** for sticky resin and discovering/breeding with other crops
- **Spruce Bonsai** for all of your benzene and power needs
- **Black Stonelilly** for black granite dust (fluorine, potassium, magnesium, aluminium, silicon)
- **Nether Stonelilly** for netherrack dust (coal, sulfur, redstone, gold)
- **Yellow Stonelilly** for endstone dust (helium, tungstate, platinum metallic powder)
- **Sugarbeet** for sugar (oxygen)
- **Salty root** OR **Tearstalks** for salt (sodium and chlorine)
- **Enderbloom** for enderpearls and endereyes
- **Glowing Earth Coral** for sunnarium and glowstone (gold and redstone)
- **Rape** for seed oil
- **Goldfish Plant** for fish oil
- **Diareed** for diamonds
- **Bobsyeruncleranks** for emeralds
- **Transformium** for UU-Matter

## Other Helpful Commands

To list all of the files installed on the robot, enter

    ls

To edit (or create) a new file, enter

    edit <filename>.lua

To remove any one file installed on the robot, enter

    rm <filename>

To uninstall all of the files from this repo, enter

    uninstall

To view an entire error message regardless of how long it may be, enter

    <program> 2>/errors.log

    edit /errors.log

Both NEI and AE2 are compatible with regular expressions, which may be helpful for filtering seed bags based on their stats. See below for two examples. The quotes are required in both instances and do not forget to double click the NEI search bar to highlight everything that matches. This also works with gain (Ga) and resistance (Re).

To search for seed bags with growth 21, enter

    "Gr 21"

To search for seed bags with growth 0-21, enter

    "Gr ([0-9]|1[0-9]|2[0-1])\n"

## Current Limitations
- The crop bot cannot create 31/31/0 seed bags for the Extreme Industrial Greenhouse since any crop with >23 growth acts as a weed.
- The crop bot does not till any grass or dirt even if a farm is overtaken by weeds.
- The crop bot does not detect when it runs out of crop sticks.

## Thanks
I (Fox) put a lot of time into this project, but I would like to give a huge thanks to huchenlei and xyqyear for their initial implementations and letting me take this project even further! Shoutout to Mozzg and Mderoulou for contributing to the repo and Sargates for helping with the RegEx!