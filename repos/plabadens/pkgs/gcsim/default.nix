{ stdenv, lib, buildGo121Module, fetchFromGitHub, protobuf}: 

buildGo121Module rec {
  pname = "gcsim";
  version = "2.18.1";

  src = fetchFromGitHub {
    owner = "genshinsim";
    repo = "gcsim";
    rev = "v${version}";
    hash = "sha256-Dq/Fdr0OEArCAN/cFT0kNIkZWqfCWBOHxTxZa4pbMXc=";
  };

  buildInputs = [ protobuf ];

  vendorHash = "sha256-XncI2IKdOS6vqE/S+NJeF/gEaMhOYGSsAeTjWyFntjU=";

  subPackages = [ "cmd/gcsim" ];

  meta = with lib; {
    description = "Monte Carlo combat simulation for genshin impact";
    homepage = "https://gcsim.app";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ plabadens ];
  };
}
