module hangamod/kit

pub fun fields(text: string): list<(string, string)>
  text.split(";").flatmap(fn(part)
    part.split("\n").flatmap-maybe(fn(chunk)
      val rec = chunk.trim
      if rec == "" then Nothing
      else match rec.list
        Cons('#', _) -> Nothing
        _ ->
          match rec.split("=")
            Cons(k, rest) | rest != Nil -> Just((k.trim, rest.join("=").trim))
            _ -> Nothing
    )
  )

pub fun get(text: string, key: string): maybe<string>
  get-from(fields(text), key)

fun get-from(xs: list<(string, string)>, key: string): maybe<string>
  match xs
    Cons((k, v), _) | k == key -> Just(v)
    Cons(_, ys) -> get-from(ys, key)
    Nil -> Nothing

pub fun flag(value: string): bool
  val v = value.trim
  v == "1" || v == "true" || v == "yes" || v == "on" ||
  v == "True" || v == "TRUE" || v == "Yes" || v == "On"

pub fun int-val(text: string, key: string, default: int): int
  match get(text, key)
    Nothing -> default
    Just(got) ->
      match parse-int(got)
        Just(n) -> n
        Nothing -> default

pub fun bool-val(text: string, key: string): bool
  match get(text, key)
    Just(v) | v != "" -> flag(v)
    _ -> flag("0")
