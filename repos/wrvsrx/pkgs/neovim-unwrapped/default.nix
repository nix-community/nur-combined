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
    version = "0.12.5+editor-fixes.6";
    __intentionallyOverridingVersion = true;
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "neovim";
      tag = finalAttrs.version;
      hash = "sha256-8U3OKaqEABX05BC9wI/nhvnFItvxKNSezRddU/BYOqY=";
    };

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
