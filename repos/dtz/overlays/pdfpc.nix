self: super: {
  pdfpc = super.pdfpc.overrideAttrs(o: rec {
    name = "pdfpc-${version}";
    version = "2018-11-12";
    src = super.fetchFromGitHub {
      owner = "pdfpc";
      repo = "pdfpc";
      rev = "63dac987d334d5352066408d35e75ed453aed1c6";
      sha256 = "0wmif4xnp2ld9c3wnpya2ji0zb3nnvpbnz5bd1dc0nv5fx3fn4sz";
    };
  });
}
