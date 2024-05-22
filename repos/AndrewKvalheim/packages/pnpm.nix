# Adapted from https://github.com/NixOS/nixpkgs/pull/305026#issuecomment-2115237332
{ fetchurl
, lib
, stdenv

  # Dependencies
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "pnpm";
  version = "9.1.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/pnpm/-/pnpm-${version}.tgz";
    hash = "sha256-lVHoA9y3oYOf31QWFTqEQGDHvOATIYzoI0EFMlBKwQs=";
  };

  buildInputs = [ nodejs ];

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/{bin,libexec}
    cp --recursive . $out/libexec/pnpm
    ln --symbolic $out/libexec/pnpm/bin/pnpm.cjs $out/bin/pnpm

    runHook postInstall
  '';

  meta = {
    description = "Fast, disk space efficient package manager";
    homepage = "https://pnpm.io/";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
