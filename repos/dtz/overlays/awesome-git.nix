self: super: {
  awesome = super.awesome.overrideAttrs (o: rec {
    name = "awesome-4.2-git-${version}";
    version = "2018-10-07";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "7519c6966a50994c546a56c557a21f2a87e37108";
      sha256 = "1awiam1cf7kwyd8rlcx93cmlzf1z01dd0mm8cxdjvh3faz82xs4x";
    };
  });
}
