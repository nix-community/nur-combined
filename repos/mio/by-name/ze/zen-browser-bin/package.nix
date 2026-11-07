{
  fetchFromGitHub,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  nix,
  nixpkgs_pkgs,
}:

let
  upstream = import ./upstream.nix { inherit fetchFromGitHub; };
  zenFlake = import (upstream + "/default.nix") { pkgs = nixpkgs_pkgs; };
  updateScript = writeShellApplication {
    name = "update-zen-browser-bin";
    runtimeInputs = [
      coreutils
      git
      gnused
      nix
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="zen-browser-bin"
      exec ${./update.sh} "$@"
    '';
  };
in
zenFlake.default.overrideAttrs (prevAttrs: {
  pname = "zen-browser-bin";
  buildCommand =
    (prevAttrs.buildCommand or "")
    + (
      if prevAttrs ? buildCommand then
        ''
          ln -s zen-beta $out/bin/zen
          ln -s zen-beta $out/bin/zen-browser
          ln -s zen-beta $out/bin/zen-browser-bin
        ''
      else
        ""
    );
  postInstall =
    (prevAttrs.postInstall or "")
    + (
      if !(prevAttrs ? buildCommand) then
        ''
          ln -s zen-beta $out/bin/zen
          ln -s zen-beta $out/bin/zen-browser
          ln -s zen-beta $out/bin/zen-browser-bin
        ''
      else
        ""
    );
  passthru = (prevAttrs.passthru or { }) // {
    inherit updateScript;
    inherit (zenFlake)
      beta
      beta-unwrapped
      twilight
      twilight-official
      twilight-official-unwrapped
      twilight-unwrapped
      ;
  };
})
