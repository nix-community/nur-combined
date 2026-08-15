import strutils

type
  WireKind* = enum
    wkEmpty, wkFlag, wkInt, wkFloat, wkText, wkList, wkBag, wkFail

  Field* = object
    key*: string
    value*: Wire

  Wire* = object
    kind*: WireKind
    flag*: bool
    intVal*: int64
    floatVal*: float64
    text*: string
    items*: seq[Wire]
    fields*: seq[Field]

proc textWire*(value: string): Wire =
  Wire(kind: wkText, text: value)

proc failWire*(reason: string): Wire =
  Wire(kind: wkFail, text: reason)

proc voxelProbe*(name: string, edit: bool): Wire =
  Wire(
    kind: wkBag,
    fields: @[
      Field(key: "name", value: Wire(kind: wkText, text: name)),
      Field(key: "edit", value: Wire(kind: wkFlag, flag: edit)),
    ],
  )

proc asText*(w: Wire): tuple[ok: bool, value: string] =
  if w.kind == wkText:
    (true, w.text)
  else:
    (false, "")

proc bagText*(w: Wire, key: string): tuple[ok: bool, value: string] =
  if w.kind != wkBag:
    return (false, "")
  for field in w.fields:
    if field.key == key and field.value.kind == wkText:
      return (true, field.value.text)
  (false, "")

proc bagFlag*(w: Wire, key: string): bool =
  if w.kind != wkBag:
    return false
  for field in w.fields:
    if field.key != key:
      continue
    case field.value.kind
    of wkFlag:
      return field.value.flag
    of wkInt:
      return field.value.intVal == 1
    else:
      discard
  false

proc bagInt*(w: Wire, key: string): int64 =
  if w.kind != wkBag:
    return 0
  for field in w.fields:
    if field.key != key:
      continue
    case field.value.kind
    of wkInt:
      return field.value.intVal
    of wkText:
      try:
        return parseBiggestInt(field.value.text)
      except CatchableError:
        return 0
    else:
      discard
  0
