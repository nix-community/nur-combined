import strutils

proc parse*(csv: string): seq[string] =
  result = @[]
  for part in csv.split(','):
    let voxel = strip(part)
    if voxel.len > 0:
      result.add(voxel)

proc catalogName*(entries: openArray[string], index: int): string =
  if index >= 0 and index < entries.len:
    entries[index]
  else:
    "air"

proc indexOf*(entries: openArray[string], voxel: string): int =
  for i, entry in entries:
    if entry == voxel:
      return i
  0
