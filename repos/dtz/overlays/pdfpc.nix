self: super: {
  pdfpc = super.pdfpc.overrideAttrs(o: rec {
    name = "pdfpc-${version}";
    version = "4.3.0";
    src = super.fetchFromGitHub {
      owner = "pdfpc";
      repo = "pdfpc";
      rev = "v${version}";
      sha256 = "1d29ybasqj68cyhvjvzynbcfdi2kc48wkkd3cwfff760dx2brigf";
    };
  });
}
