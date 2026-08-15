module hangamod/catalog

pub fun parse(csv: string): list<string>
  csv.split(",").flatmap-maybe(fn(part)
    val voxel = part.trim
    if voxel == "" then Nothing else Just(voxel)
  )

pub fun catalog-name(entries: list<string>, index: int): string
  match entries.drop(index)
    Cons(name, _) -> name
    Nil -> "air"

pub fun index-of(entries: list<string>, voxel: string): int
  index-of-from(entries, voxel, 0)

fun index-of-from(entries: list<string>, voxel: string, i: int): int
  match entries
    Cons(name, _) | name == voxel -> i
    Cons(_, xs) -> index-of-from(xs, voxel, i + 1)
    Nil -> 0
