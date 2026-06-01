{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  perl,
  python3,
  yasm,
  gitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "avm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "AOMediaCodec";
    repo = "avm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dmMQfOP71DdjHZw6DpbiiOB5a9khIu6QnZ0F5WsMuM8=";
  };

  patches = [ ./outputs.patch ];

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    perl
    python3
  ]
  ++ lib.optional stdenv.hostPlatform.isx86 yasm;

  strictDeps = true;
  __structuredAttrs = true;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
  ];

  passthru.updateScript = gitUpdater {
    url = "https://github.com/AOMediaCodec/avm";
    rev-prefix = "v";
    ignoredVersions = "(alpha|beta|rc).*";
  };

  meta = {
    description = "Reference software for AV2 codec from AOM";
    homepage = "https://github.com/AOMediaCodec/avm";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.bsd3Clear;
  };
})
