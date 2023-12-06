{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "jsonfmt";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "jsonfmt";
    rev = "v${version}";
    sha256 = "rVv7Dv4vQmss4eiiy+KaO9tZ5U58WlRlsOz4QO0gdfM=";
  };

  vendorHash = "sha256-xtwN+TemiiyXOxZ2DNys4G6w4KA3BjLSWAmzox+boMY=";

  ldflags =
    [ "-s" "-w" "-X=main.version=${version}" "-X=main.builtBy=nixpkgs" ];

  meta = with lib; {
    description = "Like gofmt, but for JSON files";
    homepage = "https://github.com/caarlos0/jsonfmt";
    license = licenses.mit;
  };
}
