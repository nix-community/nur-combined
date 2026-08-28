{
  lib,
  neovim-unwrapped,
  fetchpatch,
}:

neovim-unwrapped.overrideAttrs (
  finalAttrs: oldAttrs:
  let
    versionSuffix = lib.removePrefix "0.12.4" finalAttrs.version;
  in
  {
    version = "0.12.4+fold-improvement.3";
    __intentionallyOverridingVersion = true;
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/wrvsrx/neovim/compare/v0.12.4..${finalAttrs.version}.diff";
        hash = "sha256-ibaz0Ciq3Br+11RylDR2gDs4xIycWIGhBEq7VyfeLVU=";
      })
    ];

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
