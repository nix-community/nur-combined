{
  callPackage,
  writeScript,
}: let
  src = callPackage ./source.nix {};
  gradleDeps = callPackage ../../lib/gradleDeps.nix {};
in (gradleDeps {
  pname = "paper-deps";
  version = src.passthru.source.date;
  inherit src;
  sha256 = builtins.readFile ./deps.hash;
  passthru.updateScript = writeScript "update-paper-deps" ''
    ${../../scripts/update-gradle.sh} minecraft/papermc/deps.nix minecraft/papermc/deps.hash
  '';
})
