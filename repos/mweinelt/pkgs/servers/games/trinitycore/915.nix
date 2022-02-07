{ callPackage, pkgs, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // {
  version = "TDB915.22012";
  commit = "1761f72da7a0578475cf04019f6bc772f534b89b";
  sha256 = "sha256-uRn92R6r35/Osa/qdrRnE8bH0Y+tGq3NHHeRjYtTMnw=";
  extraPatches = [
    (fetchpatch {
      # Core/Misc: Fixed clang pch build on some distros
      # Fixes: https://github.com/TrinityCore/TrinityCore/issues/27343
      url = "https://github.com/TrinityCore/TrinityCore/commit/34024edcaa0c509545429f4f40ccfa80221d406f.patch";
      sha256 = "sha256-EqyexFwkG08BXHk1UAMJcymVq/vZnwgZfOzggcAPxeE=";
    })
  ];
})
