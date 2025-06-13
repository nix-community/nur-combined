{
  niri,
  fetchFromGitHub,
  replaceVars,
}:
niri.overrideAttrs (
  finalAttrs: oldAttrs: {
    version = "25.05.1-wrvsrx-patched.01";
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "niri";
      tag = "v${finalAttrs.version}";
      sha256 = "sha256-x32qRthAvr2LewwTjfb5D8/2XBiHVRz3HHymCLLhRsM=";
    };
    patches = [
      (replaceVars ./niri-version.patch { inherit (finalAttrs) version; })
    ];
  }
)
