# Urban Chaos

Voxel city, subway, GTA wanted level, Teardown buildings, street crafting.
**Cars belong here**, not in the engine. The host only knows a rideable vehicle
(kit boxes + occupants). This game's `vehicle-kit` is a street car: hull, cabin,
lamps, wheels, player red vs traffic colors. Street metal is soft (`stiffness` 32);
`tires: ["wheel"]` builds pressure wheels (hub + rim, ground load) on the host.
`beams` are rest-length `{a,b}` braces (`hull`–`cabin`, `cabin`–`lamp`,
`hull`–`wheel`, …). The host builds a BeamNG-style soft body: mass lattices per
part, pressure tires on `tires`, spring–damper beams with plastic deform and
break strength. The first kit part stays pinned so lamps follow the cabin
through impacts.
The testbed pack in Sandbox adds a stiffer cart that uses that pack's crash/fire
kits (lab plate: high impact threshold, no ignition; fire kit always out).

**Gravity belongs here.** Streets use Earth (`kind` constant, `y` -9.81, `jump` 5,
`walk` 10, `auto-jump`). The host only applies the field; a later heist in orbit
would ship a different kit. Cops and pedestrians set `jump` on `steer` when the
host reports the path ahead is blocked so they hop curbs instead of freezing.

Cars are **soft street metal** in the BeamNG sense: they fold, shed parts, and
can become wrecks. The host only measures impact and moves meshes; this mod
owns how cheap the steel is. A hard wreck can **ignite** (`ignites` on `crash-kit`); the host hangs a light
and then ticks `fire-kit`. Glass / tile / workbench / grass can be consumed.
Flame jumps to nearby rideables; after eight seconds the tank can burst; after
twelve the fire goes out.

## Crash (BeamNG soft body)

BeamNG.drive uses a node-beam soft body. Hanga runs the same idea on the kit:
chassis lattices with mass nodes, pressure tires, spring–damper beams with
plastic deform and break strength, pinned hull. Urban Chaos still owns the
*steel*: speed-dependent severity, parts flying off, a wreck that tumbles and
will not drive, and a high-speed hit treated as an explosion.

The engine reports impact `speed` (m/s) and `into-solid` (voxel or sudden stop).
This mod returns severity 0–100 and named outcomes. The host kicks the soft
body (soften / snap braces), folds remaining parts along the travel axis, and
detaches named parts. Tire squash comes from the pressure-wheel solver.

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

Accept is J, cash-out is K, fence is L (when wanted is 0 and you are holding
loot). Completing smash or chop-shop takes the selected item, and fencing takes
the loot you sell.

## Soft-body fidelity

Chassis parts are box lattices (denser on the hull); each `tires` part is a
hub + rim pressure wheel. Not a multi-thousand-node JBeam authoring pipeline —
the host synthesizes the mesh from the kit boxes.
