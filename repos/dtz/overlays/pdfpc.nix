self: super: {
  pdfpc = super.pdfpc.overrideAttrs(o: rec {
    name = "pdfpc-${version}";
    version = "2019-01-03";
    src = super.fetchFromGitHub {
      owner = "pdfpc";
      repo = "pdfpc";
      rev = "0d2a96b89a199f577bc729b6f55303db08fafd3e";
      sha256 = "1qb92gjan2hsin1pqki7pd24hwsfqqy96irzw9z2ngb5s1v6v9js";
    };
  });
}
