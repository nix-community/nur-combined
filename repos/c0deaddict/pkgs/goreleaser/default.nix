{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goreleaser";
  version = "0.134.0";

  src = fetchFromGitHub {
    owner = "goreleaser";
    repo = pname;
    rev = "v${version}";
    sha256 = "18gcf79bncz90934plyrk4lqfqny3wzjxwi2jf8jir4984vx720w";
  };

  modSha256 = "0xf6bczkzvmh6f9nsdas0dhm8xzshc23nw0b34r33igdvzs2xk3h";

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Deliver Go binaries as fast and easily as possible";
    homepage = "https://goreleaser.com";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.mit;
  };
}
