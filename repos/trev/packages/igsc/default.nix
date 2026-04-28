{
  cmake,
  fetchFromGitHub,
  lib,
  metee,
  nix-update-script,
  stdenv,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "igsc";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "igsc";
    tag = "V${finalAttrs.version}";
    hash = "sha256-y50DZjE0ZpiDZanDjRotarbFweSbrN/WXrKMNmNFWus=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    metee
    udev
  ];

  cmakeFlags = [
    "-DMETEE_LIB_PATH=${metee}/lib"
    "-DMETEE_HEADER_PATH=${metee}/include"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex='V(.*)'"
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "igsc";
    description = "Intel graphics system controller firmware update library";
    homepage = "https://github.com/intel/igsc";
    changelog = "https://github.com/intel/igsc/releases/tag/V${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
})
