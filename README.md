Add some Lite to your Rogue

Credit to the original author; https://steamcommunity.com/sharedfiles/filedetails/?id=2144130266
The mod has undergone a near full rewrite, but without their work this wouldn't have existed.
The original author wishes to thank the great modding community on the official Noita Discord server https://discord.com/invite/SZtrP2r.
Without them they would not been able to create this mod.
I consider Discord an ephemeral information source, which is wasteful of the human resources supporting it. I used the wiki, github, and mods (example and otherwise) to acquire my knowledge.
Informational efforts would be better suited on a wiki or other quasi-permanent platform than a user-required chat which by necessity fades to history and is fully lost.

I'm happy to share any and all of my modding knowledge to anyone who asks.


Finally, my github repo can be found at https://github.com/codefaux/persistence

Now, on with the details:

Persistence has configurable options in the Mod Options menu. Browse this menu to tune difficulty to your tastes, but defaults are a good starting point.

There are five player profile slots. (Slot 5 is only accessible via Mod Options menu)

"Persistence areas" have been added. Persistence areas count as the player's spawn location and Holy Mountains. The Persistence features described below will only work inside a Persistence Area.

Money:
- An ingame money stash has been added. Each profile stores a separate money stash.
- Mod Options can lock the stash, only allow deposits, or allow deposits and withdrawals.
- Mod Options can assign a money payout from stash upon New Game, and upon reaching a Holy Mountain.
- Mod Options configure how much money is kept on death. Default is 25%.
- Persistence tracks your last known gold; polymorphed deaths still bank money properly.
- Transfers into stash or player exceeding a specific balance will be skipped. This is intentional, to avoid overflows.

Spells:
- Spells can be researched using gold, to be permanently added to your profile's spell list.
- Researched spells can be purchased for gold. Partially used spells with limited uses cannot be researched.
- Spells can be recycled if not needed anymore. Recycled spells are simply deleted, there is no cost or benefit.
- Mod Options can be used to scale spell research and purchase costs.
- Spell "Loadouts" can be stored from existing wands in your inventory, or cleared. Loadouts are shared across all profiles.
- Loadouts must be named. Names must be 1-32 characters. Names do not need to be unique.
- Stored Loadouts can be purchased. Purchased loadouts will fill your inventory.
- KNOWN ISSUE: Due to an in-game bug, it requires -extensive- checking to avoid spells overlapping occasionally in inventory. Occasionally, spells will overlap until moved. Nothing will be lost.
- KNOWN ISSUE: Due to limitations in string length, and how I must store spells, Spell Loadouts have a limited size which is difficult to predict.

Wands:
- Wands can be researched, storing the best stats you've researched in your profile.
- Spells on a wand are destroyed when the wand is researched. Unresearched spells will not be automatically researched.
- Wands can be created using researched stats from your profile.
- Wands can be recycled if not needed. Recycled wands are simply deleted, there is no cost or benefit.
- Unique wands cannot be fully researched. Their Type (special shape, name) will not be usable. Their stats will. This is intentional.
- Wand Templates can be stored or updated during wand creation, or cleared.
- Wand Templates can be purchased. Purchased wands drop at your location.
- Wands created using Persistence can be modified.
- KNOWN ISSUE: Sometimes when researching/recycling/purchasing a wand, the Inventory screen will show spells on the wrong wand, or on nothing at all. Close and re-open the Inventory window.


A scanner runs while you explore the world. The scanner is a quality of life feature for Persistence, which can be disabled in Mod Options.
- If you're standing on or immediately beside a spell or wand in the world, Persistence will indicate if it is unresearched.
- Wands will indicate wether researched or not.
- Spells will indicate wether researched or not.
- Spells ON wands will only show if NOT researched.
- Wands which only provide a new Type (graphic) will indicate separately.



Many thanks to everyone using the mod, and doubly so to anyone who reports an issue, suggests a feature, or just says thanks.
I'd like to thank people directly, but I don't want to violate anyone's privacy.
If you've made a suggestion I've implemented or reported an issue and would like credit, contact me and tell me how to address you.
