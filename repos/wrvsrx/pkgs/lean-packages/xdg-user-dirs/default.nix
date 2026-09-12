{
  buildLakePackage,
  xdg,
  writeText,
  fetchFromGitHub,
}:
let
  self = buildLakePackage rec {
    pname = "lean4-xdg-user-dirs";
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "xdg-user-dirs";
      rev = version;
      hash = "sha256-s62/B5MUn5Dk6gjYbE6UN3H1+bnEF3iwjQxsPkm/me8=";
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
