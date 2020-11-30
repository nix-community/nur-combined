{ lib, buildGoModule, fetchFromGitHub, moreutils }:

buildGoModule rec {
  pname = "nats-utils";
  version = "master";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "nats.go";
    rev = "93be3c8e717bc8d9b7cb4208c273ccd82748a38e";
    sha256 = "1h10khcgwcqafgsc7cb818qpcnn4ra2nb0ik8vlvirdds64kfbv5";
  };

  vendorSha256 = "09jhqhvji2zsp37cqljgdmg4slriri9f38w6ys3wzci7x2xrdpjv";
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
