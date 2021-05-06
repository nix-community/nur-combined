{ lib, buildGo116Module, fetchFromGitHub }:

# Pin on Go 1.16 because in stable (20.09, Go 1.15) the vendorSha256 is
# different.
buildGo116Module rec {
  pname = "natscli";
  version = "0.0.23";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = pname;
    rev = version;
    sha256 = "0sl3k2nd4m2x05qc8wsmxcdk41g3fql7bgzvfswmkjd0px1gv707";
  };

  vendorSha256 = "10ml5wpybrxf7p2lfwvvbbcnv486vhc2plxxzja3w2kvprxq220c";
  modSha256 = vendorSha256;

  doCheck = false;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "The NATS Command Line Interface";
    homepage = "https://github.com/nats-io/natscli";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
