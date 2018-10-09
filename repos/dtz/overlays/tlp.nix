self: super: {
  tlp = super.tlp.overrideAttrs (o: rec {
    name = "tlp-${version}";
    version = "2018-10-03";
    src = super.fetchFromGitHub {
      owner = "linrunner";
      repo = "tlp";
      rev = "b6dac68eb414a1f5cb38641893aa6fea8c2e4332";
      sha256 = "03sfbcs7050x0wgdhqqsw70by20299i4vzrm337j366mgx9mbxk4";
    };
  });
}
