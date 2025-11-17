{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkgs,
  runtimeShell,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "nix-fix-hash";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-fix-hash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rQnjZ9bSU2qj9cJmwtHdMeok2BuRpo0eVCTXZ3TXJf0=";
  };

  dontBuild = true;

  nativeBuildInputs = with pkgs; [
    shellcheck-minimal
  ];

  runtimeInputs = with pkgs; [
    nix
    ncurses
  ];

  unpackPhase = ''
    cp "$src/nix-fix-hash.sh" .
  '';

  configurePhase = ''
    echo "#!${runtimeShell}" >> nix-fix-hash
    echo "${
      lib.concatMapStringsSep "\n" (option: "set -o ${option}") [
        "errexit"
        "nounset"
        "pipefail"
      ]
    }" >> nix-fix-hash
    echo 'export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> nix-fix-hash
    cat nix-fix-hash.sh >> nix-fix-hash
    chmod +x nix-fix-hash
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck ./nix-fix-hash
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nix-fix-hash $out/bin/nix-fix-hash
  '';

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
    platforms = pkgs.lib.platforms.all;
  };
})
