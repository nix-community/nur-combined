{
  buildLakePackage,
  xdg,
  writeText,
  fetchFromGitHub,
}:
let
  self = buildLakePackage rec {
    pname = "lean4-xdg-user-dirs";
    version = "0.3.1";

    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "xdg-user-dirs";
      rev = version;
      hash = "sha256-JBmwDaBMn/2U20Ui8kPI/etB20armK5L4FK2yWYj8v8=";
    };
    leanPackageName = "«xdg-user-dirs»";
    leanDeps = [ xdg ];

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
