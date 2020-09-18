{ lib, buildGoModule, fetchFromGitHub, moreutils }:

buildGoModule rec {
  pname = "nats-utils";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats.go";
    rev = "v${version}";
    sha256 = "1nfl44jc0wj48f6x6hsxbwb4hn7zah3vk7f2ilg322c432kwj6kg";
  };

  vendorSha256 = "13v3nzrxanhaf7la9h2m4p8yjqbypalj4d1qkq982l3wxrypq8c2";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  postPatch = ''
    mv examples utils
  '';

  # overrideModAttrs = _: {
  #   postBuild = ''
  #     [ -e vendor/modules.txt ] && sed -i '/## explicit/d' vendor/modules.txt
  #   '';
  # };

  goPackagePath = "github.com/nats-io/nats.go";
  subPackages = [
    "utils/nats-bench"
    "utils/nats-echo"
    "utils/nats-pub"
    "utils/nats-qsub"
    "utils/nats-req"
    "utils/nats-rply"
    "utils/nats-sub"
  ];

  meta = with lib; {
    description = "NATS command line utitilies provided by the nats.go library";
    homepage = "https://github.com/nats-io/nats.go";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.apsl20;
  };
}
