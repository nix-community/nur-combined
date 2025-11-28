def main : IO UInt32 := do
  let targets ← match (← IO.getEnv "NIX_LAKE_TARGETS") with
    | some x => pure (x.splitOn " ")
    | none => pure []
  let optionOverride ← if (← (System.FilePath.pathExists "lake-manifest-overrided.json"))
    then pure #["--packages=lake-manifest-overrided.json"]
    else pure #[]
  (← IO.Process.spawn {
    cmd := "lake",
    args := #["build"] ++ optionOverride ++ targets
  }).wait
