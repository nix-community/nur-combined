import strutils

type Pair* = tuple[key: string, value: string]

proc nextField*(text: string, start: int): tuple[ok: bool, pair: Pair, next: int] =
  var i = start
  while i < text.len:
    var recEnd = i
    while recEnd < text.len and text[recEnd] != ';' and text[recEnd] != '\n':
      inc recEnd
    let rec = strip(text[i ..< recEnd])
    var after = recEnd
    if recEnd < text.len:
      inc after
    i = after
    if rec.len == 0 or rec[0] == '#':
      continue
    let eq = rec.find('=')
    if eq < 0:
      continue
    return (true, (strip(rec[0 ..< eq]), strip(rec[eq + 1 .. ^1])), after)
  return (false, ("", ""), i)

proc get*(text, key: string): tuple[ok: bool, value: string] =
  var i = 0
  while true:
    let step = nextField(text, i)
    if not step.ok:
      return (false, "")
    if step.pair.key == key:
      return (true, step.pair.value)
    i = step.next

proc flag*(value: string): bool =
  case toLowerAscii(strip(value))
  of "1", "true", "yes", "on":
    true
  else:
    false

proc f32Val*(text, key: string, default: float32): float32 =
  let got = get(text, key)
  if not got.ok:
    return default
  try:
    float32(parseFloat(got.value))
  except CatchableError:
    default

proc boolVal*(text, key: string): bool =
  let got = get(text, key)
  flag(if got.ok and got.value.len > 0: got.value else: "0")
