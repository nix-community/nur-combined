{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-protobuf";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "Arwalk";
    repo = "zig-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NuNiOx2Moupi23q1yX/aDIoleg0bGUvlcFYTqAPVkgU=";
  };

  zigDeps =
    (zig.fetchDeps {
      inherit (finalAttrs) src pname version;
      hash = "sha256-zqf9fK99IfmQ+UKzDxrUq1ocdpfI7kT3ijotx67OcO4=";
      fetchAll = true;
    }).overrideAttrs
      (oldAttrs: {
        buildCommand =
          lib.replaceStrings
            [ "export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)\n" ]
            [
              ''
                export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
                mkdir -p "$ZIG_GLOBAL_CACHE_DIR/tmp"
              ''
            ]
            oldAttrs.buildCommand;
      });

  nativeBuildInputs = [
    zig.hook
  ];

  zigBuildFlags = [
    "--system"
    "${finalAttrs.zigDeps}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "A protobuf 3 implementation for zig";
    mainProgram = "protoc-gen-zig";
    homepage = "https://github.com/Arwalk/zig-protobuf";
    changelog = "https://github.com/Arwalk/zig-protobuf/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
