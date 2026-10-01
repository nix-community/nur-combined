{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  python3,
  makeWrapper,
}:
let
  py = python3.withPackages (
    p: with p; [
      pytest
      pytest-asyncio
      python-dateutil
      requests
      verboselogs
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "decluttarr";
  version = "2.2.0";
  src = fetchFromGitHub {
    owner = "ManiMatter";
    repo = "decluttarr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-36XOEnNE5aJg9QkVK2nI8xK3RiugNH3Xjhswt3dhj+s=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${lib.getExe py} $out/bin/decluttarr \
      --add-flags $src/main.py

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed";
    homepage = "https://github.com/ManiMatter/decluttarr";
    license = with lib.licenses; [ gpl3Only ];
    mainProgram = "decluttarr";
  };
})
