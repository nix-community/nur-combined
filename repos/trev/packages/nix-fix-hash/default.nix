{
  lib,
  mktemp,
  runtimeShell,
  sd,
  shellcheck,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nix-fix-hash";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-fix-hash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tFW10OaXCAPiLjvAnMC6hkU9/BkQxB7cKLaoZWv9smU=";
  };

  nativeBuildInputs = [
    shellcheck
  ];

  runtimeInputs = [
    mktemp
    sd
  ];

  unpackPhase = ''
    cp "$src/nix-fix-hash.sh" nix-fix-hash.sh
  '';

  dontBuild = true;

  configurePhase = ''
    sed -i '1c\#!${runtimeShell}' nix-fix-hash.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' nix-fix-hash.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck nix-fix-hash.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nix-fix-hash.sh $out/bin/nix-fix-hash
  '';

  dontFixup = true;

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "${finalAttrs.pname}"
      ];
    });
  };

  meta = {
    description = "Nix hash fixer";
    mainProgram = "nix-fix-hash";
    homepage = "https://github.com/spotdemo4/nix-fix-hash";
    changelog = "https://github.com/spotdemo4/nix-fix-hash/releases/tag/v${finalAttrs.version}";
    platforms = lib.platforms.all;
  };
})
