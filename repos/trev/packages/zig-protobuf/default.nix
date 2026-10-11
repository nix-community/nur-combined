{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-protobuf";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "Arwalk";
    repo = "zig-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D3xTXCqxM/Hpcx/9ZLFHciLjpguZlvv18x7rU9Ssds4=";
  };

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail 'const include = if (try build_util.getProtocDependency(b)) |protoc| protoc.path("include") else b.path("");' \
      'const include = b.path("");'
  '';

  zigDeps =
    (zig.fetchDeps {
      inherit (finalAttrs) src pname version;
      hash = "sha256-r0xm3EUduf0lUXrCMBm0TFYnRn9uRK0maVGhMrs7rMk=";
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
