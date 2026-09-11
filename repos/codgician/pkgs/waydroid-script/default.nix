{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
  # Runtime dependencies
  gnutar,
  lzip,
  util-linux,
  e2fsprogs,
  nix-update-script,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      tqdm
      requests
      inquirerpy
    ]
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "waydroid-script";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "waydroid_script";
    rev = "48dbfaf34a6ddbe78688c530f9ba1c26522aafb2";
    hash = "sha256-UBbnYhiRCf4sMwpEDMlpJuTEsN66B2hZ8BPz6cCGXAc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/waydroid-script
    cp -r . $out/libexec/waydroid-script

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/waydroid-script \
      --add-flags "$out/libexec/waydroid-script/main.py" \
      --prefix PATH : ${
        lib.makeBinPath [
          gnutar
          lzip
          util-linux
          e2fsprogs
        ]
      }

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
    ];
  };

  meta = {
    description = "Python script to add GApps, Magisk, libhoudini translation library and libndk translation library to Waydroid";
    homepage = "https://github.com/casualsnek/waydroid_script";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "waydroid-script";
    maintainers = with lib.maintainers; [ codgician ];
  };
})
