{
  fetchFromGitHub,
  lib,
  mktemp,
  nix-update-script,
  runtimeShell,
  sd,
  shellcheck,
  stdenv,
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

  unpackPhase = ''
    cp "$src/nix-fix-hash.sh" nix-fix-hash.sh
  '';

  dontBuild = true;

  runtimeInputs = [
    mktemp
    sd
  ];
  configurePhase = ''
    sed -i '1c\#!${runtimeShell}' nix-fix-hash.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' nix-fix-hash.sh
  '';

  doCheck = true;
  nativeCheckInputs = [
    shellcheck
  ];
  checkPhase = ''
    shellcheck nix-fix-hash.sh
  '';

  installPhase = ''
    install -D nix-fix-hash.sh $out/bin/fix-hash
  '';

  dontFixup = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "fix-hash";
    description = "Nix hash fixer";
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/nix-fix-hash";
    changelog = "https://github.com/spotdemo4/nix-fix-hash/releases/tag/v${finalAttrs.version}";
  };
})
