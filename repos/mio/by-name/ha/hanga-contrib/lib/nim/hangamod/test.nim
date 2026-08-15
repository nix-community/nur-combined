import kit, catalog, wire

let fields = nextField("a=1;mystery=nope\nb=2", 0)
doAssert fields.ok
doAssert fields.pair.key == "a"
doAssert fields.pair.value == "1"
let mystery = nextField("a=1;mystery=nope\nb=2", fields.next)
doAssert mystery.pair.key == "mystery"
let b = nextField("a=1;mystery=nope\nb=2", mystery.next)
doAssert b.pair.key == "b"
doAssert flag("1")
doAssert not flag("0")
doAssert get("kind=none;jump=5", "kind").value == "none"
doAssert f32Val("walk=10", "walk", 0) == 10

let names = parse("air, tile ,lamp")
doAssert names.len == 3
doAssert catalogName(names, 1) == "tile"
doAssert indexOf(names, "lamp") == 2
doAssert checkerFloor(0, -1, 0) == 2
doAssert checkerFloor(0, 0, 0) == 1
doAssert checkerFloor(1, 0, 0) == 2
doAssert checkerFloor(0, 1, 0) == 0

let probe = voxelProbe("glass", true)
doAssert bagText(probe, "name").value == "glass"
doAssert bagFlag(probe, "edit")

let nested = Wire(
  kind: wkBag,
  fields: @[
    Field(
      key: "parts",
      value: Wire(
        kind: wkList,
        items: @[
          Wire(
            kind: wkBag,
            fields: @[Field(key: "name", value: textWire("hull"))],
          )
        ],
      ),
    )
  ],
)
doAssert nested.fields[0].value.items[0].bagText("name").value == "hull"
doAssert failWire("busy").kind == wkFail
doAssert failWire("busy").text == "busy"
doAssert bagInt(voxelProbe("glass", true), "missing") == 0
let xyz = Wire(
  kind: wkBag,
  fields: @[
    Field(key: "x", value: Wire(kind: wkInt, intVal: 4)),
    Field(key: "z", value: textWire("-2")),
  ],
)
doAssert bagInt(xyz, "x") == 4
doAssert bagInt(xyz, "z") == -2
echo "hangamod ok"
