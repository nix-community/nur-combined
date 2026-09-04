{
  lib,
  melpaBuild,
  fetchFromGitHub,
  nix-mode,
  pkgs,
  # Path to the NixOS options JSON.  Defaults to the JSON from a
  # minimal NixOS evaluation (empty config).  Pass
  # "/etc/nixos-options.json" to skip the eval and keep the runtime
  # /etc/ fallback instead.
  nixosOptionsJson ? null,
  # Path to the nixpkgs source tree for building the package search
  # JSON offline.  Defaults to <nixpkgs>.
  nixpkgsPath ? pkgs.path,
}:

let
  nixosOptionsJsonFinal =
    if nixosOptionsJson != null
    then nixosOptionsJson
    else
      let
        emptyEval = import "${pkgs.path}/nixos/lib/eval-config.nix" {
          modules = [{ system.stateVersion = "25.05"; }];
        };
      in
        "${emptyEval.config.system.build.manual.optionsJSON}/share/doc/nixos/options.json";

  nixosSearchJson =
    pkgs.runCommandLocal "nix-search.json"
      {
        nativeBuildInputs = [
          pkgs.nixVersions.latest
          pkgs.writableTmpDirAsHomeHook
          pkgs.jq
        ];
      }
      ''
        echo '{"flakes":[],"version":2}' > empty-registry.json
        nix --offline --store ./. \
          --extra-experimental-features 'nix-command flakes' \
          --option flake-registry $PWD/empty-registry.json \
          search path:${nixpkgsPath} --json "" | jq --sort-keys > $out
      '';
in
melpaBuild {
  pname = "nixos";
  version = "0-unstable-2026-09-02";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "nixos.el";
    rev = "fb56906bbaf099021ce8a8fca96dc35c893aff82";
    hash = "sha256-6CBLEQU4kHVywUVpisLR0jbhRM347afAEqQ5nGsrL1c=";
  };

  packageRequires = [ nix-mode ];

  postPatch = ''
    substituteInPlace nixos.el \
      --replace-fail '/etc/nixos-options.json' ${nixosOptionsJsonFinal}
    substituteInPlace nixos.el \
      --replace-fail '/etc/nixos-search.json' ${nixosSearchJson}
  '';

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck
    emacs --batch -L . --eval '(setq byte-compile-error-on-warn t)' \
      -f batch-byte-compile nixos-tests.el
    emacs --batch -L . \
      -l nixos-tests.elc \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/nixos.el";
    description = "Browse NixOS options and packages from Emacs";
    longDescription = ''
      Provides interactive completing-read interfaces for browsing
      NixOS options and Nix packages.  Data sources are baked in at
      build time via Nix store paths, so no runtime configuration is
      needed.
    '';
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
