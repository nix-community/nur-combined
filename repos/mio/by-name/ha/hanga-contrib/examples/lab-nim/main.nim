# Compile with Nim C backend + wit-bindgen C (nlvm wasm32 currently SIGSEGVs).
import catalog

type
  PluginString {.importc: "plugin_string_t", header: "plugin.h", bycopy.} = object
    `ptr`: pointer
    len: csize_t
  HostValue {.importc: "hanga_engine_host_value_t", header: "plugin.h".} = object
  PluginListString {.importc: "plugin_list_string_t", header: "plugin.h".} = object

proc payload_text(ret: ptr HostValue; value: cstring) {.importc, cdecl.}
proc payload_flag(ret: ptr HostValue; value: bool) {.importc, cdecl.}
proc payload_empty(ret: ptr HostValue) {.importc, cdecl.}
proc payload_fail(ret: ptr HostValue; reason: cstring) {.importc, cdecl.}
proc payload_gravity(ret: ptr HostValue) {.importc, cdecl.}
proc payload_fracture(ret: ptr HostValue) {.importc, cdecl.}
proc payload_methods(ret: ptr HostValue; topics: ptr cstring; n: csize_t) {.importc, cdecl.}
proc payload_catalog(ret: ptr PluginListString; parts: ptr cstring; n: csize_t) {.importc, cdecl.}
proc bag_int(payload: ptr HostValue; key: cstring): int64 {.importc, cdecl.}
proc bag_text_eq(payload: ptr HostValue; key, want: cstring): cint {.importc, cdecl.}
proc bus_has(payload: ptr HostValue; topics: ptr cstring; n: csize_t): cint {.importc, cdecl.}
proc host_log_info(message: cstring) {.importc, cdecl.}
proc greet_peers() {.importc, cdecl.}
proc topic_eq(topic: ptr PluginString; want: cstring): cint {.importc, cdecl.}

const
  catalogParts: array[3, cstring] = [cstring"air", "nim", "knot"]
  busTopics: array[10, cstring] = [
    cstring"ping", "name", "catalog", "gravity", "has", "methods", "voxel", "fracture-kit", "loot-item",
    "refuse"
  ]

proc queryVoxel(x, y, z: int32): int32 =
  checkerFloor(x, y, z)

proc voxelName(index: int32): cstring =
  if index >= 0 and index < catalogParts.len:
    catalogParts[index]
  else:
    cstring"air"

proc exports_hanga_engine_guest_abi(): int32 {.exportc: "exports_hanga_engine_guest_abi", cdecl, dynlib.} =
  6

proc exports_hanga_engine_guest_ready() {.exportc: "exports_hanga_engine_guest_ready", cdecl, dynlib.} =
  host_log_info("lab_nim ready")
  greet_peers()

proc exports_hanga_engine_guest_voxel_catalog(ret: ptr PluginListString) {.
    exportc: "exports_hanga_engine_guest_voxel_catalog", cdecl, dynlib.} =
  payload_catalog(ret, unsafeAddr catalogParts[0], csize_t(catalogParts.len))

proc exports_hanga_engine_guest_query_voxel(x, y, z: int32): int32 {.
    exportc: "exports_hanga_engine_guest_query_voxel", cdecl, dynlib.} =
  queryVoxel(x, y, z)

proc exports_hanga_engine_guest_invoke(
    caller: ptr PluginString;
    topic: ptr PluginString;
    payload: ptr HostValue;
    ret: ptr HostValue
) {.exportc: "exports_hanga_engine_guest_invoke", cdecl, dynlib.} =
  discard caller
  if topic_eq(topic, "ping") != 0:
    payload_text(ret, "pong")
  elif topic_eq(topic, "name") != 0:
    payload_text(ret, "lab_nim")
  elif topic_eq(topic, "catalog") != 0:
    payload_text(ret, "air,nim,knot")
  elif topic_eq(topic, "gravity") != 0:
    payload_gravity(ret)
  elif topic_eq(topic, "has") != 0:
    payload_flag(ret, bus_has(payload, unsafeAddr busTopics[0], csize_t(busTopics.len)) != 0)
  elif topic_eq(topic, "methods") != 0:
    payload_methods(ret, unsafeAddr busTopics[0], csize_t(busTopics.len))
  elif topic_eq(topic, "voxel") != 0:
    let x = int32(bag_int(payload, "x"))
    let y = int32(bag_int(payload, "y"))
    let z = int32(bag_int(payload, "z"))
    payload_text(ret, voxelName(queryVoxel(x, y, z)))
  elif topic_eq(topic, "fracture-kit") != 0:
    if bag_text_eq(payload, "action", "break") == 0 and bag_text_eq(payload, "action", "explode") == 0:
      payload_empty(ret)
    elif bag_text_eq(payload, "voxel", "nim") != 0 or bag_text_eq(payload, "voxel", "knot") != 0:
      payload_fracture(ret)
    else:
      payload_empty(ret)
  elif topic_eq(topic, "loot-item") != 0:
    if bag_text_eq(payload, "voxel", "knot") != 0:
      payload_text(ret, "knot")
    else:
      payload_empty(ret)
  elif topic_eq(topic, "refuse") != 0:
    payload_fail(ret, "busy")
  else:
    payload_empty(ret)
