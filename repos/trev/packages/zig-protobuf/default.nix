{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-protobuf";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "Arwalk";
    repo = "zig-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zn+tMJv+yoA9ZEYTFL9wb+2ASkIqXV8GVVsq6pfyHW0=";
  };

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail 'const include = if (try build_util.getProtocDependency(b)) |protoc| protoc.path("include") else b.path("");' \
      'const include = b.path("");'
  '';

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-p0XV1SisVWCuRsZ1bpAPyMlG1qEGCUEyoKYa/ckCs2A=";
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
