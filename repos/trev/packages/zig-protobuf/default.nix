{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig_0_15,
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

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-zqf9fK99IfmQ+UKzDxrUq1ocdpfI7kT3ijotx67OcO4=";
    fetchAll = true;
  };

  nativeBuildInputs = [
    zig_0_15.hook
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
