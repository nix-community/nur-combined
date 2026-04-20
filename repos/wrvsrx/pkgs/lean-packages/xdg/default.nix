{
  buildLakePackage,
  get-environment,
  writeText,
  source,
}:
let
  self = buildLakePackage {
    pname = "lean4-${source.pname}";
    inherit (source) src version;
    leanPackageName = source.pname;
    leanDeps = [ get-environment ];

    doCheck = true;
    checkPhase = ''
      lake test --no-ansi --packages=${overridesFile}
    '';
  };
  overridesFile = writeText "lake-overrides.json" (
    builtins.toJSON {
      schemaVersion = "1.2.0";
      packages = map (dep: {
        type = "path";
        name = dep.passthru.lakePackageName or dep.pname;
        inherited = false;
        dir = "${dep}";
      }) self.allLeanDeps;
    }
  );
in
self
