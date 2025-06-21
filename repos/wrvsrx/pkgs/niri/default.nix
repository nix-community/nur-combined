{
  niri,
  fetchFromGitHub,
}:
niri.overrideAttrs (
  finalAttrs: oldAttrs: {
    version = "25.05.1-wrvsrx-patched.01";
    env = oldAttrs.env // {
      NIRI_BUILD_VERSION_STRING = finalAttrs.version;
    };
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "niri";
      tag = "v${finalAttrs.version}";
      sha256 = "sha256-x32qRthAvr2LewwTjfb5D8/2XBiHVRz3HHymCLLhRsM=";
    };
  }
)
