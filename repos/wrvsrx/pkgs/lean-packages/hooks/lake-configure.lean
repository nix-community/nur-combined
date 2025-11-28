import Lake.Load.Manifest
import Lean.Data.Json
import Lean.Data.Json.FromToJson

structure ManifestOverride where
  name: Lean.Name
  dir: System.FilePath
  deriving Lean.ToJson, Lean.FromJson, Inhabited

def overrideManifest (manifestOverrides : Array ManifestOverride) (manifest : Lake.Manifest) : Lake.Manifest :=
  let packagesOverrided :=
    manifest.packages.map (
      fun packageEntry =>
        let optionOverride := manifestOverrides.find? (fun manifestOverride => manifestOverride.name == packageEntry.name) 
        optionOverride.elim
          packageEntry
          fun override => {packageEntry with src := Lake.PackageEntrySrc.path override.dir}
    )
  {manifest with packages := packagesOverrided}

def patchManifest : IO Unit := do
  let manifestString ← IO.FS.readFile "lake-manifest.json"
  let manifest : Lake.Manifest ← IO.ofExcept do
    let x ← Lean.Json.parse manifestString
    Lean.FromJson.fromJson? x

  match (← IO.getEnv "NIX_LAKE_MANIFEST_OVERRIDE") with
  | some x => do
    let manifestOverrideString ← IO.FS.readFile x
    let manifestOverride : (Array ManifestOverride) ← IO.ofExcept do
      let x ← Lean.Json.parse manifestOverrideString
      Lean.FromJson.fromJson? x
    let manifestOverrided := overrideManifest manifestOverride manifest
    let manifestOverridedStr := toString (Lean.ToJson.toJson manifestOverrided) 
    IO.FS.writeFile "lake-manifest-overrided.json" manifestOverridedStr
  | none => pure ()

def main : IO Unit := do
  patchManifest
