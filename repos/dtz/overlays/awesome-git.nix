self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-10-05";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM"; # "dtzWill";
      repo = "awesome";
      rev = "9533d97b9b0731fcaf26e0e70f2c2f1c82372f96";
      sha256 = "0wcqxrc4xj3xnfx3908ns6vj8kj02xzz7cwj0di8dpj6kvxfsfcf";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
