{
  lib,
  neovim-unwrapped,
  fetchFromGitHub,
}:

neovim-unwrapped.overrideAttrs (
  finalAttrs: oldAttrs:
  let
    versionSuffix = lib.removePrefix "0.12.5" finalAttrs.version;
  in
  {
    version = "0.12.5+editor-fixes.4";
    __intentionallyOverridingVersion = true;
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "neovim";
      rev = finalAttrs.version;
      hash = "sha256-p/CuO/MMz57H1OSMHc22v/qwr2uM7/74wiSdnkicytU=";
    };

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
