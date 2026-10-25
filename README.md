# Kitsune Server Side Starter Kit

**Every Kitsune mod that runs on the server only, in one download. Players don't install anything.**

For 7 Days to Die 3.x dedicated servers. Single player works too.

## What's in it

Core mods go in `Mods/`. Copy them all in, or delete the ones you don't want: each one works on its own.

| Mod | What it does |
|---|---|
| [Kitsune Server Perf](https://github.com/Kitsune-Den/KitsuneServerPerf) | Server CPU fixes, plus `kperf` to see which mods eat your server's time |
| [Kitsune Fuel Saver](https://github.com/Kitsune-Den/KitsuneFuelSaver) | Forges, campfires and other fueled workstations switch off when there's nothing left to do |
| [Kitsune Terrain Fit](https://github.com/Kitsune-Den/KitsuneTerrainFit) | Terrain meets the blocks you build on it, instead of dipping away around them |
| [Kitsune Trap XP](https://github.com/Kitsune-Den/KitsuneTrapXP) | Trap and turret kills give the owner XP, no perk needed |
| [Kitsune Zombie Reach](https://github.com/Kitsune-Den/KitsuneZombieReach) | Zombie and animal hits land closer to where they actually are |
| [Kitsune Power](https://github.com/Kitsune-Den/KitsunePower) | Lenient power: solar, generator and battery banks each put out up to 4500W, gas goes twice as far, and batteries hold twice the charge |
| [Kitsune Vehicle Overhaul](https://github.com/Kitsune-Den/KitsuneVehicleOverhaul) | Vehicles take less damage from cacti, bushes and crashes |
| [Kitsune Kitchen](https://github.com/Kitsune-Den/KitsuneKitchen7D) | New dishes and drinks with their own buffs, and Sham Sandwiches sell to traders |
| [Kitsune Foxacary](https://github.com/Kitsune-Den/KitsuneFoxacary) | Nine new medical items you unlock from medical journals: braces, salves, sutures, shots and a transfusion kit. Some buy you time in biome storms |
| [Kitsune Stacks](https://github.com/Kitsune-Den/KitsuneStacks) | Bigger stacks: resources, ammo, food, drinks, medical items and more |
| [Kitsune Better Farming](https://github.com/Kitsune-Den/KitsuneBetterFarming) | Harvested crops go back to an early growing stage instead of disappearing, so there's no replanting. Each harvest has a 25% chance of a bonus seed |
| [Kitsune Auger Reach](https://github.com/Kitsune-Den/KitsuneAugerReach) | The auger reaches about a meter further, for digging and for hitting things |
| [Kitsune Backpack](https://github.com/AdaInTheLab/KitsuneBackpack) | A 136-slot backpack that keeps vanilla's locked slots: 32 free at spawn, and Pack Mule unlocks the rest. The death bag grows to fit it all |
| [Kitsune Spikes Extended](https://github.com/Kitsune-Den/KitsuneSpikesExtended) | Steel spike traps, and cone spikes you upgrade from wood to iron-tipped, then soak in gas and set on fire. Trap XP pays for their kills |
| [Kitsune Appliances](https://github.com/Kitsune-Den/KitsuneAppliances) | Working appliances: stoves cook like campfires, fridges are lockable 120-slot cold storage, sinks fill empty jars. Pick up the real ones out in the world or craft your own |

Trap XP, Zombie Reach, Power, Vehicle Overhaul, Kitchen, Foxacary, Stacks, Better Farming, Auger Reach, Backpack, Spikes Extended and Appliances change gameplay, not just performance. Have a look before you install all of it.

Backpack is safe to add to an existing save, but removing it later shrinks bags back to vanilla, and anything in the extra slots can be lost. Don't run it alongside another bag-size mod.

Optional mods go in `Optional/`:

| Mod | What it does |
|---|---|
| [Kitsune PvP Extended](https://github.com/Kitsune-Den/KitsunePvPExtended) | Scales player-against-player damage only, with presets. PvE stays vanilla. For PvP servers |
| [Kitsune Crafting Times](https://github.com/Kitsune-Den/KitsuneCraftingTimes) | Faster crafting everywhere. Comes in four speeds (25%, 50%, 75%, 90% faster). Install one |

The exact versions are in [kit.json](kit.json), and in `README.txt` inside the zip.

## Install

1. Download the zip from [Releases](https://github.com/Kitsune-Den/KitsuneServerSideStarterKit/releases).
2. Copy everything in `Mods/` into your server's `Mods` folder, plus any optional mods you want.
3. Turn EAC off on the server. Server Perf, Fuel Saver, Terrain Fit, Trap XP and PvP Extended use Harmony. Players can keep EAC on.
4. Restart the server.

## Not in the kit

These need installing on every player's game too, so they don't belong in a server-only kit:

- **Kitsune Server Perf's settings page** (`KitsuneServerPerf_UI`). Get it from the [Server Perf releases](https://github.com/Kitsune-Den/KitsuneServerPerf/releases) if you want it.
- **Kitsune Storage**: the server sets the sizes, but the bigger windows are client-side.
- **Kitsune Trader Unlock**: it patches the player's game.

## Building it

The kit is built from each mod's GitHub release, pinned by tag in `kit.json`. You need the [GitHub CLI](https://cli.github.com/), signed in.

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

The zip lands in `dist/`. The build fails if a release or asset is missing, or if a mod's `ModInfo.xml` version doesn't match `kit.json`. It also adds each mod's `LICENSE` and `NOTICE.md` from its repo, since the mods' own release zips don't include them.

To update a mod in the kit, change its `tag`, `asset` and `version` in `kit.json`, then bump the kit's own `version`. A mod whose repo isn't under Kitsune-Den names its GitHub account in `owner`.

## License

[CC BY-NC-SA 4.0](LICENSE), with an extra permission for servers that make money: see [NOTICE.md](NOTICE.md). Every mod in the kit is under the same license. In short: run it, change it and share it, with credit, not for sale, and with changed versions under the same license.

Made by AdaInTheLab.
