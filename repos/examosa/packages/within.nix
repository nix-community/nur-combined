{
  fetchFromCodeberg,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "within";
  version = "1.1.4";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "sjmulder";
    repo = "within";
    tag = finalAttrs.version;
    hash = "sha256-UyOgEe07K1LW5IbB7ngxelp+9Njq/NPPkWw3sxAQyVY=";
  };

  makeFlags = ["PREFIX:=$(out)"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Run a command in other directories";
    homepage = "https://codeberg.org/sjmulder/within";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    mainProgram = "within";
  };
})
