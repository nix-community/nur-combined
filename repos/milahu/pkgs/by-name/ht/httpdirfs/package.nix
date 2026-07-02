{
  curl,
  expat,
  fetchFromGitHub,
  fuse3,
  gumbo,
  lib,
  libuuid,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  stdenv,
  testers,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "httpdirfs";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "fangfufu";
    repo = "httpdirfs";
    rev = finalAttrs.version;
    hash = "sha256-HMcb23Rk7MD4qsdXXFaOqOenb87BDB1N1ov4wWPOq58=";
  };

  # https://github.com/fangfufu/httpdirfs/blob/master/subprojects/unity.wrap
  # https://github.com/ThrowTheSwitch/Unity
  src-unity = fetchFromGitHub {
    owner = "ThrowTheSwitch";
    repo = "Unity";
    rev = "bbf8f3728a937c7627b8094de7ae13559d220ed5"; # 2026-05-29
    hash = "sha256-esQVS+3pFeeKfIce2UkYcb3Aluw/9qo3CPxxwBfxQwk=";
  };

  postUnpack = ''
    cp -r --no-preserve=mode,owner ${finalAttrs.src-unity} source/subprojects/unity
  '';

  postPatch = ''
    chmod +x subprojects/unity/auto/extract_version.py
    patchShebangs subprojects/unity/auto/extract_version.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    # for extract_version.py
    python3
  ];

  buildInputs = [
    curl
    expat
    fuse3
    gumbo
    libuuid
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "${lib.getExe finalAttrs.finalPackage} --version";
      package = finalAttrs.finalPackage;
    };
    updateScript = nix-update-script { };
  };

  meta = {
    changelog = "https://github.com/fangfufu/httpdirfs/releases/tag/${finalAttrs.version}";
    description = "FUSE filesystem for HTTP directory listings";
    homepage = "https://github.com/fangfufu/httpdirfs";
    license = lib.licenses.gpl3Only;
    mainProgram = "httpdirfs";
    maintainers = with lib.maintainers; [
      schnusch
      anthonyroussel
    ];
    platforms = lib.platforms.linux;
  };
})
