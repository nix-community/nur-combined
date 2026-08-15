module hangamod/wire

pub type field
  Field(key: string, value: wire)

pub type wire
  WEmpty
  WFlag(flag: bool)
  WInt(int-val: int)
  WFloat(float-val: float64)
  WText(text: string)
  WList(items: list<wire>)
  WBag(fields: list<field>)
  WFail(text: string)

pub fun text-wire(value: string): wire
  WText(value)

pub fun fail-wire(reason: string): wire
  WFail(reason)

pub fun voxel-probe(name: string, edit: bool): wire
  WBag([ Field("name", WText(name)), Field("edit", WFlag(edit)) ])

pub fun as-text(w: wire): maybe<string>
  match w
    WText(t) -> Just(t)
    _ -> Nothing

pub fun bag-text(w: wire, key: string): maybe<string>
  match w
    WBag(fs) -> bag-text-from(fs, key)
    _ -> Nothing

fun bag-text-from(fs: list<field>, key: string): maybe<string>
  match fs
    Cons(Field(k, WText(t)), _) | k == key -> Just(t)
    Cons(_, xs) -> bag-text-from(xs, key)
    Nil -> Nothing

pub fun bag-flag(w: wire, key: string): bool
  match w
    WBag(fs) -> bag-flag-from(fs, key)
    _ -> False

fun bag-flag-from(fs: list<field>, key: string): bool
  match fs
    Cons(Field(k, WFlag(b)), _) | k == key -> b
    Cons(Field(k, WInt(n)), _) | k == key -> n == 1
    Cons(_, xs) -> bag-flag-from(xs, key)
    Nil -> False
