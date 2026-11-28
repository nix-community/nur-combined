{
  lib,
  inputs,
  writeShellApplication,
  nix,
  nixpkgs_pkgs,
}:

let
  zenFlake = inputs.zen-browser-flake.packages.${nixpkgs_pkgs.stdenv.hostPlatform.system};
  updateScript = writeShellApplication {
    name = "update-zen-browser-bin";
    runtimeInputs = [ nix ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="zen-browser-bin"
      exec ${./update.sh} "$@"
    '';
  };
in
zenFlake.default.overrideAttrs (prevAttrs: {
  pname = "zen-browser-bin";
  meta = (prevAttrs.meta or { }) // {
    license = lib.licenses.mpl20;
  };
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
