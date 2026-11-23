{
  # keep-sorted start
  buildNpmPackage,
  lib,
  src,
  # keep-sorted end
}:
# The static browser client `albedo web` serves.
buildNpmPackage {
  pname = "albedo-web";
  version = "1.0.0";

  src = "${src}/web";

  npmDepsHash = "sha256-5Itp6k2TUvIcXBzZELdivWbPq/te8srjmJMy40s4YXo=";

  installPhase = ''
    runHook preInstall
    cp -R dist $out
    runHook postInstall
  '';

  meta.license = import ./license.nix {inherit lib;};
}
