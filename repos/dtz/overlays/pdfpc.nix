self: super: {
  pdfpc = super.pdfpc.overrideAttrs(o: rec {
    name = "pdfpc-${version}";
    version = "4.3.0";
    src = super.fetchFromGitHub {
      owner = "pdfpc";
      repo = "pdfpc";
      rev = "refs/tags/v${version}";
      sha256 = "1ild2p2lv89yj74fbbdsg3jb8dxpzdamsw0l0xs5h20fd2lsrwcd";
    };
  });
}
