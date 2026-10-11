{
  lib,
  neovim-unwrapped,
  fetchFromGitHub,
}:

neovim-unwrapped.overrideAttrs (
  finalAttrs: oldAttrs:
  let
    versionSuffix = lib.removePrefix "0.12.6" finalAttrs.version;
  in
  {
    version = "0.12.6+editor-fixes.7";
    __intentionallyOverridingVersion = true;
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "neovim";
      tag = finalAttrs.version;
      hash = "sha256-t9fK+bA7Nv80GZVpCBiO4gE96lK64XXZiiyLbyCh4+k=";
    };

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
