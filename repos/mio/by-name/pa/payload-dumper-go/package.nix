{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  xz,
}:

buildGo127Module rec {
  pname = "payload-dumper-go";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = "2.1.0";
    hash = "sha256-aCrYngtUhjNvjlPplCGwbZVRKxsuFy+xuGVnb/ShGnQ=";
  };

  vendorHash = "sha256-RVY686QB9EdPMiu3+QiJeSSVFqpvEL2tREuwKKAjoQQ=";

  buildInputs = [
    xz
  ];

  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.27.0" "go 1.26" || true
  '';

  meta = with lib; {
    description = "An Android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "payload-dumper-go";
  };
}
