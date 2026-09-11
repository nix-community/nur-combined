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
    version = "0.12.5+editor-fixes.5";
    __intentionallyOverridingVersion = true;
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "neovim";
      tag = finalAttrs.version;
      hash = "sha256-tyVNHA7Qk8//puoW3gBIXxUToa3z+jfoA0kMlouGZng=";
    };

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
