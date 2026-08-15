module hangamod/test

import hangamod/kit
import hangamod/catalog
import hangamod/wire

fun demand(b: bool, msg: string): console ()
  if b then () else println("FAIL " ++ msg)

pub fun main(): console ()
  val fs = fields("a=1;mystery=nope\nb=2")
  val fields-a = match fs
    Cons((k, _v), _xs) -> k == "a"
    Nil -> False
  demand(fields-a, "fields a")
  demand(flag("1"), "flag 1")
  demand(flag("0") == False, "flag 0")
  demand(get("kind=none;jump=5", "kind") == Just("none"), "get kind")
  demand(int-val("walk=10", "walk", 0) == 10, "int-val")
  val names = parse("air, tile ,lamp")
  demand(names.length == 3, "catalog len")
  demand(catalog-name(names, 1) == "tile", "catalog name")
  demand(index-of(names, "lamp") == 2, "catalog index")
  val probe = voxel-probe("glass", True)
  demand(bag-text(probe, "name") == Just("glass"), "probe name")
  demand(bag-flag(probe, "edit"), "probe edit")
  val nested = WBag([ Field("parts", WList([ WBag([ Field("name", text-wire("hull")) ]) ])) ])
  val nested-ok = match nested
    WBag(Cons(Field(_k0, WList(Cons(inner, _rest0))), _rest1)) ->
      bag-text(inner, "name") == Just("hull")
    _ -> False
  demand(nested-ok, "nested")
  val fail-ok = match fail-wire("busy")
    WFail(t) -> t == "busy"
    _ -> False
  demand(fail-ok, "fail")
  println("hangamod ok")
