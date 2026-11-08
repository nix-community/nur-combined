{
  callPackage,
  fetchFromGitea,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  nix,
}:

let
  upstream = import ./upstream.nix { inherit fetchFromGitea; };
  updateScript = writeShellApplication {
    name = "update-brave-origin-bin";
    runtimeInputs = [
      coreutils
      git
      gnused
      nix
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="brave-origin-bin"
      exec ${./update.sh} "$@"
    '';
  };
  pkg = (callPackage (upstream + "/brave") { }).brave-origin;
in
pkg.overrideAttrs (prevAttrs: {
  passthru = (prevAttrs.passthru or { }) // {
    inherit updateScript;
  };
})
