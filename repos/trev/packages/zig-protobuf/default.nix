{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-protobuf";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "Arwalk";
    repo = "zig-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9E8Lw9nn5OqOElhrimHMdYaZQ06ouwAweWvMxrEajQM=";
  };

  zigDeps =
    (zig.fetchDeps {
      inherit (finalAttrs) src pname version;
      hash = "sha256-zqf9fK99IfmQ+UKzDxrUq1ocdpfI7kT3ijotx67OcO4=";
    }).overrideAttrs
      {
        # waiting on https://github.com/NixOS/nixpkgs/pull/498646
        buildCommand = ''
          export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)

          runHook unpackPhase

          cd $sourceRoot
          zig build --fetch=all

          mv $ZIG_GLOBAL_CACHE_DIR/p $out
        '';
      };

  nativeBuildInputs = [
    zig.hook
  ];

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

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
