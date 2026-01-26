{
  fetchFromGitHub,
  jq,
  lib,
  makeWrapper,
  ncurses,
  nix-update-script,
  nix,
  pcre2,
  runtimeShell,
  shellcheck,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nix-scan";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-scan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xyy0gUaf7WIY7QsT38zfksGf9oYf4f3glIEJSxaJqpk=";
  };

  nativeBuildInputs = [
    makeWrapper
    shellcheck
  ];

  runtimeInputs = [
    jq
    ncurses
    nix
    pcre2
  ];

  unpackPhase = ''
    cp -a "$src/nix-scan.sh" nix-scan.sh
  '';

  dontBuild = true;

  configurePhase = ''
    sed -i '1c\#!${runtimeShell}' nix-scan.sh
    sed -i '2c\export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' nix-scan.sh
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck nix-scan.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nix-scan.sh "$out/bin/nix-scan"
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
    description = "Nix vulnerability scanner";
    mainProgram = "nix-scan";
    homepage = "https://github.com/spotdemo4/nix-scan";
    changelog = "https://github.com/spotdemo4/nix-scan/releases/tag/v${finalAttrs.version}";
    platforms = lib.platforms.all;
  };
})
