{ lib, buildGoModule, fetchFromGitHub, moreutils }:

buildGoModule rec {
  pname = "stan-utils";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "stan.go";
    rev = "v${version}";
    sha256 = "0j02z4xgzfr9hkypiqyfidm14k1dlr2g4li1hih4rw3md3dm45b0";
  };

  vendorSha256 = "1gxwvx7jm30zp7mfj776k0s09sravhjjs70qzqw2iq3dygw5jwj3";
  # modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  postPatch = ''
    mv examples utils
  '';

  subPackages = [
    "utils/stan-bench"
    "utils/stan-pub"
    "utils/stan-sub"
  ];

  meta = with lib; {
    description = "NATS Streaming System command line utitilies provided by the stan.go library";
    homepage = "https://github.com/nats-io/stan.go";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.apsl20;
  };
}
