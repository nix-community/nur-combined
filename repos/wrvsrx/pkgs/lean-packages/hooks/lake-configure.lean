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

  let manifestOverridePath ← do
    let x ← IO.getEnv "NIX_LAKE_MANIFEST_OVERRIDE"
    x.elim (throw (IO.Error.userError "no such environment variable")) pure
  let manifestOverrideString ← IO.FS.readFile manifestOverridePath
  let manifestOverride : (Array ManifestOverride) ← IO.ofExcept do
    let x ← Lean.Json.parse manifestOverrideString
    Lean.FromJson.fromJson? x
  let manifestOverrided := overrideManifest manifestOverride manifest

  let manifestOverridedStr := toString (Lean.ToJson.toJson manifestOverrided) 
  IO.print manifestOverridedStr

def main : IO Unit := do
  patchManifest
