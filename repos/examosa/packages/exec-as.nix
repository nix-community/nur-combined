{
  fetchFromCodeberg,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "exec-as";
  version = "1.2.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "maandree";
    repo = "exec-as";
    tag = finalAttrs.version;
    hash = "sha256-tsga9+MCVjMOLAATAUYbJ/vCCT5tzxwsopx3mbmr1QI=";
  };

  makeFlags = ["CC:=$(CC)" "PREFIX:=$(out)"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A command that lets you start another command with any argv[0]";
    homepage = "https://codeberg.org/maandree/exec-as";
    license = lib.licenses.isc;
    mainProgram = "exec-as";
    platforms = lib.platforms.all;
  };
})
