{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "scorecard";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ossf";
    repo = pname;
    rev = "v${version}";
    sha256 = "1br50c73crml2c6js3mkszk1canjm657mqhcyi1x66p27dqvwirf";
  };

  vendorSha256 = "0x03gcmzsshaxq5k0p6i6jbjkn7rn32hp1jp5q8nnk0agjs09a35";

  buildFlagsArray = [
    "-ldflags="
    "-w"
    "-s"
  ];

  meta = with lib; {
    description = "OSS Security Scorecards";
    homepage = src.meta.homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
