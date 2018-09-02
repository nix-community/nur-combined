pkgs:

pkgs.wlc.overrideDerivation (old: {
  name = "wlc-0.0.10";
  src = pkgs.fetchFromGitHub {
    owner = "Cloudef";
    repo = "wlc";
    rev = "v0.0.10";
    fetchSubmodules = true;
    sha256 = "09kvwhrpgkxlagn9lgqxc80jbg56djn29a6z0n6h0dsm90ysyb2k";
  };
})
