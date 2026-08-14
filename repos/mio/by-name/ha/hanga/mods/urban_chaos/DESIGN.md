# Urban Chaos

Voxel city, subway, GTA wanted level, Teardown buildings, street crafting.
**Cars belong here**, not in the engine. The host only knows a rideable vehicle
(kit boxes + occupants). This game's `vehicle-kit` is a street car: hull, cabin,
lamps, wheels, player red vs traffic colors. Street metal is soft (`stiffness=32`);
`tire=wheel` lets the host squash the wheels when the car is on the ground.
`beam=hull,cabin` / `beam=cabin,lamp` / `beam=hull,wheel` / `beam=hull,lamp` are
rest-length links. The host shortens them on crumple and relaxes the chain a few
times so lamps follow the cabin.
The testbed pack in Sandbox adds a stiffer cart that uses that pack's crash/fire kits.

**Gravity belongs here.** Streets use Earth (`kind=constant;y=-9.81;jump=5;walk=10`).
The host only applies the field; a later heist in orbit would ship a different kit.

Cars are **soft street metal** in the BeamNG sense: they fold, shed parts, and
can become wrecks. The host only measures impact and moves meshes; this mod
owns how cheap the steel is. A hard wreck can **ignite** (`ignites=1` on `crash-kit`); the host hangs a light
and then ticks `fire-kit`. Glass / tile / workbench / grass can be consumed.
Flame jumps to nearby rideables; after eight seconds the tank can burst; after
twelve the fire goes out.

## Crash (BeamNG-related, not a full node-beam solver)

BeamNG.drive uses a node-beam soft body. Hanga does not solve that. Urban Chaos
still wants the *feel*: speed-dependent crumple, parts flying off, a wreck that
tumbles and will not drive, and a high-speed hit that is treated as an explosion.

The engine reports impact `speed` (m/s) and `into-solid` (voxel or sudden stop).
This mod returns severity 0–100 and named outcomes. The host folds remaining
parts along the travel axis, slides them toward the hit, shortens named `beam=`
links (pinned lattice), and squashes `tire=` parts on the local up axis. That is
not BeamNG's solver.

| Impact speed | Severity | Visual | Heat |
| --- | --- | --- | --- |
| below 8 | 0 | none | none |
| 8–14 | 25 | lamps detach, hull crumples | none (fender tap) |
| 14–20 | 50 | wheels detach | `crash` (+2 wanted) |
| 20–28 | 75 | cabin shears, wrecked, engine fire | `crash` |
| 28+ | 100 | full wreck, Teardown burst, fire | `explode` |

Parts the host may detach: `lamp`, `wheel`, `cabin`. `hull` stays as the wreck
body. Wrecked cars are undriveable; the engine unlocks pitch/roll so they can
flip like a BeamNG pile-up.

`into-solid` uses the same thresholds (hitting a building at 12 is a crash, not
a tap). Grazing another car without a hard stop stays at 0 unless speed drops
hard.

## Heists

The host only paints a mark and reports whether you are near it, in a vehicle,
and what you are holding. This game owns the jobs.

| Wanted | Job | Site | Cash-out |
| --- | --- | --- | --- |
| 0 | smash-and-grab | glass storefront (531, 3, 550) | hold glass or tile |
| 1 | subway pinch | metro hall (400, -6, 400) | be underground at the mark |
| 2 | chop-shop | sidewalk bench (504, 2, 520) | hold brick, concrete, or a workbench |
| 3+ | armored-truck | road (510, 2, 495) | be in a vehicle at the mark |

Accept is J, cash-out is K, fence is L (when wanted is 0). Completing smash or
chop-shop takes the selected item.

## Out of scope (later)

- A real node-beam lattice / solver
