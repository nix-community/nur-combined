{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-protobuf";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "Arwalk";
    repo = "zig-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c5EVhghAC93j7W6Wa5JDkQJebi1Z0s/ieyVPKsFPIHk=";
  };

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail 'const include = if (try build_util.getProtocDependency(b)) |protoc| protoc.path("include") else b.path("");' \
      'const include = b.path("");'
  '';

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-r0xm3EUduf0lUXrCMBm0TFYnRn9uRK0maVGhMrs7rMk=";
    fetchAll = true;
  };

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  nativeBuildInputs = [
    zig.hook
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
