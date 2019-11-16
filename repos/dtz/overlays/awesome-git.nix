self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-11-09";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "9bc6d4aa40547a295e73f37bc8e4184e6238a827";
      sha256 = "0jfs6ka1rp2ba2qwdci5j7j97n8fgzhasd1ym1n2v41vcf5f45v2";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];

    #doCheck = true;
  });
}
