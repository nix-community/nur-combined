{
  pkgs,
  fprintd,
  fprintd-1_94_4 ? fprintd.overrideAttrs (finalAttrs: {
    pname = "fprintd-fpcmoh";
    version = "1.94.4";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "libfprint";
      repo = "fprintd";
      rev = "v${finalAttrs.version}";
      sha256 = "sha256-B2g2d29jSER30OUqCkdk3+Hv5T3DA4SUKoyiqHb8FeU=";
    };
  }),
  libfprint-fpcmoh,
}:
fprintd-1_94_4.override { libfprint = libfprint-fpcmoh; }
