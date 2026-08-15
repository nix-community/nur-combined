module labkoka

import std/num/int32
import hangamod/catalog

extern import
  c file "kk-hanga-decl.h"

extern payload-text(ret: intptr_t, value: string): ()
  c "kk_hanga_payload_text"

extern payload-flag(ret: intptr_t, value: bool): ()
  c "kk_hanga_payload_flag"

extern payload-empty(ret: intptr_t): ()
  c "kk_hanga_payload_empty"

extern payload-gravity(ret: intptr_t): ()
  c "kk_hanga_payload_gravity"

extern payload-fracture(ret: intptr_t): ()
  c "kk_hanga_payload_fracture"

extern payload-methods(ret: intptr_t): ()
  c "kk_hanga_payload_methods"

extern bag-int32(payload: intptr_t, key: string): int32
  c "kk_hanga_bag_int32"

extern bag-text-eq(payload: intptr_t, key: string, want: string): bool
  c "kk_hanga_bag_text_eq"

extern bus-has(payload: intptr_t): bool
  c "kk_hanga_bus_has"

pub fun query-voxel(x: int32, y: int32, z: int32): int32
  checker-floor(x, y, z)

fun voxel-name(index: int32): string
  if index == 1.int32 then "koka"
  elif index == 2.int32 then "effect"
  else "air"

pub fun invoke(topic: string, payload: intptr_t, ret: intptr_t): ()
  if topic == "ping" then payload-text(ret, "pong")
  elif topic == "name" then payload-text(ret, "lab_koka")
  elif topic == "catalog" then payload-text(ret, "air,koka,effect")
  elif topic == "gravity" then payload-gravity(ret)
  elif topic == "has" then payload-flag(ret, bus-has(payload))
  elif topic == "methods" then payload-methods(ret)
  elif topic == "voxel" then
    val x = bag-int32(payload, "x")
    val y = bag-int32(payload, "y")
    val z = bag-int32(payload, "z")
    payload-text(ret, voxel-name(query-voxel(x, y, z)))
  elif topic == "fracture-kit" then
    if bag-text-eq(payload, "action", "break") == False && bag-text-eq(payload, "action", "explode") == False then
      payload-empty(ret)
    elif bag-text-eq(payload, "voxel", "koka") || bag-text-eq(payload, "voxel", "effect") then
      payload-fracture(ret)
    else
      payload-empty(ret)
  elif topic == "loot-item" then
    if bag-text-eq(payload, "voxel", "effect") then payload-text(ret, "effect")
    else payload-empty(ret)
  else
    payload-empty(ret)
