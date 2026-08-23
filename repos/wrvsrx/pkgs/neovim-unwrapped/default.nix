{
  lib,
  neovim-unwrapped,
  fetchFromGitHub,
}:

neovim-unwrapped.overrideAttrs (
  finalAttrs: oldAttrs:
  let
    versionSuffix = lib.removePrefix "0.12.4" finalAttrs.version;
  in
  {
    version = "0.12.4+fold-improvement.2";

    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "neovim";
      rev = finalAttrs.version;
      hash = "sha256-ZhHv6tTdRw7VXQPw8ZMsvSNKgGkqOOxq9v0m0+uc3TQ=";
    };

    patches = oldAttrs.patches or [ ];

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'set(NVIM_VERSION_PRERELEASE "")' \
        'set(NVIM_VERSION_PRERELEASE "${versionSuffix}")'
    '';
  }
)
