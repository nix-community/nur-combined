{
  fetchFromGitLab,
  fprintd,
  fprintd-1_94_4 ? fprintd.overrideAttrs (finalAttrs: {
    version = "1.94.4";
    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "libfprint";
      repo = "fprintd";
      rev = "v${finalAttrs.version}";
      sha256 = "sha256-B2g2d29jSER30OUqCkdk3+Hv5T3DA4SUKoyiqHb8FeU=";
    };
  }),
  libfprint-fpcmoh,
}:
(fprintd-1_94_4.override { libfprint = libfprint-fpcmoh; }).overrideAttrs (
  _finalAttrs: previousAttrs: {
    pname = "fprintd-fpcmoh";
    meta = previousAttrs.meta // {
      description = "Fingerprint daemon for FPC match on host device";
      inherit (libfprint-fpcmoh.meta) platforms;
    };
  }
)
