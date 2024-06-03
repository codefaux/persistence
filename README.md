# persistence
Add some Lite to your Rogue


Better description to come.


Note: I'm going to attempt to take over this mod. If I run into problems which I cannot fix, I'll announce such. The original mod can be found here, and the vast majority of work on this mod is credited to the original author:
https://steamcommunity.com/sharedfiles/filedetails/?id=2144130266

Many thanks to the original author, this mod has inspired me to keep playing, as it provides *just* enough sense of progress, for me.

The original author wishes to thank the great modding community on the official Noita Discord server https://discord.com/invite/SZtrP2r. Without them they would not been able to create this mod.

I don't use Discord or other information sources which are ephemeral in nature, so my source is the Wiki, the API, and example/well-documented mods. My personal, deepest thanks to those willing to store their knowledge someplace it is public, persistent, and does not require live interaction to disseminate. I acknowledge the efforts of live support members on Discord, but their efforts help a few people, until the chat history isn't visible and they're offline. Finding written knowledge on this has been DIFFICULT.




This mod allows you to bank money for future uses including wand crafting and spell purchase. You can bank automatically on death (amount configurable, 10%~100%, default 25%) or manually mid-run at the Lobby area.

The 'Lobby' area is, by default, the area between the stones with key bindings on them where you spawn, just outside the cave.

The 'Lobby' area can be configured to move to your spawn location, for random runs, or left default for difficulty.



While in the 'Lobby area':

The Persistence GUI will appear. Click a left-edge tab label to open it, and click it again to close it. (I'm working on improving this.)

With your on-person money, you can Research both wands and spells, unlocking the ability to buy them for a single a future run.

Wand research costs vary depending on what each wand has to offer you. IE, a wand which can only improve one stat when researched will be the same cost regardless of its other stats.

Wand Buy costs vary depending on what you attempt to build. The available specs are limited by what you've researched. IE if you haven't researched a wand with 9 Spells Per Cast, you can't make one.

Research/Buy costs for Wands/Spells have a configurable multiplier, from 10% ~ 200%. At 100% the starter wands cost around $8k to research, which feels tough-but-acceptable for the power this mod gives you.

You can research a spell, and buy as many copies of it as you can afford. (I'm very tempted to make this scale when purchasing multiple spells, or multiple copies of the same spell. I'm open to feedback.)

The mod gives the option to edit wands while in the Lobby. This is disabled by default, as returning to the surface at any time is a bit too easy, but it helps with debugging and I assume many will enjoy it for a good, overpowered run.

The 'Reuse Holy Mountain' option might be fixed -- confirmation pending.


Link to the original mod: https://steamcommunity.com/sharedfiles/filedetails/?id=2144130266


I would appreciate Issues and Feature Requests be raised at my Github repo, as I can track them much more easily there. Also, the Github repo will be updated with beta patches prior to pushing the Steam Workshop version. I will TRY to keep the Steam Workshop version from causing any regressions. The Github version may unintentionally cause bugs, but I aim to test them semi-thoroughly before a Workshop commit.

Documentation in flux, check back for updates. I'm still figuring all this out.

My changes so far:
- In-game Mod Options menu support instead of manually finding/editing lua files

- Datastore
-- Fixed 'Wand Templates stick to each other' due to Lua always using by-ref assignment
<<<<<<< HEAD
-- Optimized safety checks; consolidated instead of spamming

- Research Wand GUI
-- Optimised for single data pass, sacrificing 'perfect' alignment
-- Optimised to avoid needless multiple duplication of largely unused data
=======
>>>>>>> c181d1d977031e27cf48b8a1b8d2de9da381403c

- Reworked Money GUI
-- Added as sub-tab as other menus
-- Can stay open with other menus
-- Colorized to indicate item availability
-- Added Player money display

- Buy Wand GUI
-- Added 'To Limit' buttons aka '|<<' to jump a value to its minimum/maximum. Display is still not ideal.
-- Move to loop-driven iteration instead of verbose static generation of GUI elements
-- New wand generation is no longer 0 spells per cast, 0 mana etc by default. Defaults are SANE, and start as an average of your available stats.
-- Added icon as GUI element instead of sprite (showed as faded/beneath GUI before)
-- Moved icon to top, added tilt angle for style
-- Added icon to Saved Template list
-- Added on-hover stats for saved templates

- Buy Spells GUI
-- Shifted positions
-- Colorized

- Stash/Take GUI
-- Rewording of Take/Stash instead of ^/V buttons
--- (English only -- options for translations are on TODO, prefer ingame strings)
-- Colorized unavailable options
-- Move to loop-driven iteration instead of verbose static generation of GUI elements

- ALL GUIs
-- Tabs lock controls while open. Click tab again to close. Pending fix. (Anyone know how to read user keybindings? I want my mod to match system keybinds to eg. close menus in case user rebinds tab/i for example.)
-- Background fixed so wands/text no longer appears 'on top of' darkness

TODO: (Help wanted -- If you have experience and are willing to help, please comment at Github or here.)
- Translations for strings
-- Prefer in-game strings to avoid need for mod translation mods, mostly just need to find which ones are best
- Rework GUI/tab behavior
-- Easier close function than 'click the label again'
<<<<<<< HEAD
- Confirm 'Reuse Holy Mountain' / 'Edit Wands at Lobby' bug squashed
=======
- Confirm 'Reuse Holy Mountain' / 'Edit Wands at Lobby' bug squashed
>>>>>>> c181d1d977031e27cf48b8a1b8d2de9da381403c
