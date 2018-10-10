self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-10-08";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "7020a9707fa897373c176daf6ec77ed9b688300c";
      sha256 = "0ljzphl71bvh4jad3zvzvcbjz66f72y9i2a5ycqp6janwzzgy8r0";
    };
  });
}
