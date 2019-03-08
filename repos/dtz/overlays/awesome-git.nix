self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-03-07";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "795c792d118e29621c59d0664318f199c80caf93";
      sha256 = "1p4p4v7f9rd6hqmzvq8ba6xz45i5a5z66ghmmx28j1jxhmq56bg9";
    };
    buildInputs = (o.buildInputs or []) ++ [ self.xorg.xcbutilerrors ];
  });
}
