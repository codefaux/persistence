Add some Lite to your Rogue


Better description to come.


Note: I'm going to attempt to take over this mod. If I run into problems which I cannot fix, I'll announce such. The original mod can be found here, and the vast majority of work on this mod is credited to the original author:
https://steamcommunity.com/sharedfiles/filedetails/?id=2144130266

Many thanks to the original author, this mod has inspired me to keep playing, as it provides *just* enough sense of progress, for me.

The original author wishes to thank the great modding community on the official Noita Discord server https://discord.com/invite/SZtrP2r. Without them they would not been able to create this mod.

I don't use Discord or other information sources which are ephemeral in nature, so my source is the Wiki, the API, and example/well-documented mods. My personal, deepest thanks to those willing to store their knowledge someplace it is public, persistent, and does not require live interaction to disseminate. I acknowledge the efforts of live support members on Discord, but their efforts help a few people, until the chat history isn't visible and they're offline. Finding written knowledge on this has been DIFFICULT.


My Github repo can be found here: https://github.com/codefaux/persistence
Feel free to open issues for bugs, requests, or suggestions.


This mod allows you to save money into a stash for future uses including wand crafting and spell purchase. You will save automatically on death (amount configurable, 10%~100%, default 25%) or you can manually access the stash mid-run at the Lobby area.

The 'Lobby' area is, by default, the area between the stones with key bindings on them where you spawn, just outside the cave.

The 'Lobby' area can be configured to move to your spawn location, for random runs, or left default for difficulty.



While in the 'Lobby area':

The Persistence GUI will appear. Click a left-edge tab label to open it, and click it again to close it. Tab, I and Space close all open windows.

The 'Money' tab is for recovering your stashed money, or stashing more.

With your on-person money, you can Research both wands and spells, unlocking the ability to buy a copy or copies for a single future run.

Wand research costs vary depending on what each wand has to offer you. IE, a wand which can only improve one stat when researched will be the same cost regardless of its other stats.

Wand Buy costs vary depending on what you attempt to build. The available specs are limited by what you've researched. IE if you haven't researched a wand with 9 Spells Per Cast, you can't make one.

Research/Buy costs for Wands/Spells have a configurable multiplier, from 10% ~ 200%. At 100% the starter wands cost around $8k to research, which feels tough-but-acceptable for the power this mod gives you.

You can research a spell, and buy as many copies of it as you can afford. (I'm very tempted to make this scale when purchasing multiple spells, or multiple copies of the same spell. I'm open to feedback.)

The mod gives the option to edit wands while in the Lobby. This is disabled by default, as returning to the surface at any time is a bit too easy, but it helps with debugging and I assume many will enjoy it for a good, overpowered run.


Link to the original mod: https://steamcommunity.com/sharedfiles/filedetails/?id=2144130266


I would appreciate Issues and Feature Requests be raised at my Github repo, as I can track them much more easily there. Also, the Github repo will be updated with beta patches prior to pushing the Steam Workshop version. I will TRY to keep the Steam Workshop version from causing any regressions. The Github version may unintentionally cause bugs, but I aim to test them semi-thoroughly before a Workshop commit.

Documentation in flux, check back for updates. I'm still figuring all this out.

My changes so far:
- In-game Mod Options menu support instead of manually finding/editing lua files

- Tab and Space both close the Persistence menus if they are open.
-- Custom keybinds are going to take some work but they are coming.

- Teleport moved to BOTTOM of screen (more free space)

- Datastore
-- Fixed 'Wand Templates stick to each other' due to Lua always using by-ref assignment
-- Optimized safety checks; consolidated instead of spamming
-- Fixed New Save issue

- Select Save GUI
-- Moderate rework, preview stats

- Research Spell GUI
-- Complete rework with icons, names, descriptions, and cost
-- Refuse to research used spells with max quantities
-- Allow recycling known/spent spells

- Research Wand GUI
-- Optimised for single data pass, sacrificing 'perfect' alignment
-- Optimised to avoid needless multiple duplication of largely unused data
-- Complete rework with icons, names, stats, colored for improvement
-- Scrollable list w/ capacity and spells on each wand
-- Allow recycling known wands

- Reworked Money GUI
-- Added as sub-tab as other menus
-- Can stay open with other menus
-- Colorized to indicate item availability
-- Added Player money display
-- Rewording of Take/Stash instead of ^/V buttons
--- (English only -- options for translations are on TODO, prefer ingame strings)
-- Move to loop-driven iteration instead of verbose static generation of GUI elements

- Buy Wand GUI
-- Added 'To Limit' buttons aka '|<<' to jump a value to its minimum/maximum. Display is still not ideal.
-- Move to loop-driven iteration instead of verbose static generation of GUI elements
-- New wand generation is no longer 0 spells per cast, 0 mana etc by default. Defaults are SANE, and start as an average of your available stats.
-- Complete rework of Select Icon UI, Always Cast UI with icons, names, descriptions, costs
-- Added icon as GUI element instead of sprite (showed as faded/beneath GUI before)
-- Moved icon to top, added tilt angle for style
-- Added frame for wand icon
-- Added icon to Saved Template list
-- Added framed on-hover stats for saved templates
-- Added display of Always Cast spells to both tooltip and main window
-- Template 1 is now Default (used when loading UI), numbers changed accordingly

- Buy Spells GUI
-- Complete rework with icon, name, cast count, type, description, and cost
-- Filter by type
-- Search by name
-- Sort by name/cost

- ALL GUIs
-- Tabs lock controls while open. Click tab again to close. Pending fix. (Anyone know how to read user keybindings? I want my mod to match system keybinds to eg. close menus in case user rebinds tab for example.)
-- Background fixed so wands/text no longer appears 'on top of' darkness

- Optimizations
-- actions[] cloned to actions_by_id[] since near all lookups were by id
-- reworked most lookups to take advantage of actions_by_id[]
-- wands[] cloned to wands_by_type[] and reworked lookups to use

TODO/Known Issues: (Help wanted -- If you have experience and are willing to help, please comment at Github or here.)
- Translations for strings
-- Prefer in-game strings to avoid need for mod translation mods, mostly just need to find which ones are best

- Holding direction when opening UI causes movement to continue until UI is closed