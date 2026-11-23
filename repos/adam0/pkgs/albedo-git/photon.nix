{
  # keep-sorted start
  buildNpmPackage,
  lib,
  python3,
  src,
  stdenv,
  # keep-sorted end
}:
buildNpmPackage {
  pname = "albedo-photon";
  version = "1.0.0";

  src = "${src}/tools/photon";

  npmDepsHash = "sha256-aRRaX7EHc4p37hlj2dlZlFfdLo4eVEAEwBY/ekYGT9A=";
  dontNpmBuild = true;

  # HEIC photos are normalized by Python with pillow-heif on Linux.
  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace bridge.mjs --replace-fail "'python3'" "'${python3.withPackages (ps: [ps.pillow-heif])}/bin/python3'"
  '';

  # The executable stays beside the SDK it loads.
  postInstall = ''
    ln -sfn ../lib/node_modules/albedo-photon/albedo-photon "$out/bin/albedo-photon"
  '';

  meta = {
    license = import ./license.nix {inherit lib;};
    mainProgram = "albedo-photon";
  };
}
