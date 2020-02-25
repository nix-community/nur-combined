{ callPackage, fetchFromGitHub, just, rustPlatform
, buildFHSUserEnv
}:

just.overrideAttrs (o: rec {
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "casey";
    repo = o.pname;
    rev = "v${version}";
    sha256 = "0r454g2l1b79f488jxl3rxzgqr4ns47cdzib1xgj65f1c8y23yd4";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    cargoUpdateHook = "";
    copyLockfile = false;
    name = "${o.pname}-${version}";
    patches = o.cargoDeps.patches;
    sha256 = "1rzji0ivzvf0w8vga6dpmhgqh9x2bx9zk92hcn2g6wj6yzis8ki8";
    sourceRoot = null;
    src = src;
    unpackPhase = o.cargoDeps.unpackPhase;
  };

  checkFHSUserEnv = buildFHSUserEnv {
    name = "just-check-env";
    runScript = "env";
    targetPkgs = p: [
      (p.callPackage passthru.check-wrapper-farm { })
    ];
  };

  checkPhase = ''
    runHook preCheck
    echo "Running cargo cargo test -- ''${checkFlags} ''${checkFlagsArray+''${checkFlagsArray[@]}}"
    "$checkFHSUserEnv/bin/just-check-env" -- \
    cargo test -- ''${checkFlags} ''${checkFlagsArray+"''${checkFlagsArray[@]}"}
    runHook postCheck
  '';

  preCheck = ''
    # USER must not be empty
    export USER=just-user
    export USERNAME=just-user
  '';

  passthru = o.passthru or { } // {
    # just symlinks certain programs under different names while testing.
    # When this happens with argv[0]-dependent executables like the GNU
    # coreutils suite, functionality via the new links changes and tests
    # break. Creating wrappers in the middle prevents this.
    check-wrapper-farm = { lib, runCommand, makeWrapper
    , coreutils
    }: let
      sh = lib.escapeShellArg;
      cu = coreutils;
    in runCommand "just-check-wrapper-farm" {
      buildInputs = [ makeWrapper ];
    } ''
      makeWrapper ${sh "${cu}/bin/cat"} "$out/bin/cat"
    '';
  };
})
