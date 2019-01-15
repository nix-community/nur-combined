self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2019-01-15";
    nativeBuildInputs = o.nativeBuildInputs or [] ++ [ self.asciidoctor ];
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "8fe06f95d08ddecc133cc2ad1deaa86928031518";
      sha256 = "09h8zwqr5i5axgybykjb76xk3jk69b5cxq89366wj7v97vb53260";
    };
  });
}
