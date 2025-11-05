{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkgs,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "bumper";
  version = "0.1.23";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C0Fr1wrejZhS+z3cC1rkLHn7ZTUAJ5Apo3zccOoE3Fs=";
  };

  nativeBuildInputs = with pkgs; [
    shellcheck
  ];

  runtimeInputs = with pkgs; [
    git
    nodejs_24
    nix-update
  ];

  unpackPhase = ''
    cp "$src/bumper.sh" .
  '';

  dontBuild = true;

  configurePhase = ''
    echo "#!${pkgs.runtimeShell}" >> bumper
    echo "${pkgs.lib.concatMapStringsSep "\n" (option: "set -o ${option}") [
      "errexit"
      "nounset"
      "pipefail"
    ]}" >> bumper
    echo 'export PATH="${pkgs.lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> bumper
    tail -n +2 bumper.sh >> bumper
    chmod +x bumper
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck ./bumper
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bumper $out/bin/bumper
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
    description = "git semantic version bumper";
    mainProgram = "bumper";
    homepage = "https://github.com/spotdemo4/bumper";
    platforms = pkgs.lib.platforms.all;
  };
})
