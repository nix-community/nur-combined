{
  lib,
  buildGoModule,
  fetchFromGitHub,
  xz,
}:

buildGoModule rec {
  pname = "payload-dumper-go";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = "1.3.0";
    hash = "sha256-TFnBWylOoyleuBx3yYfHl1kWO6jVBiqsi8AMYLMuuk0=";
  };

  vendorHash = "sha256-XeD47PsFjDT9777SNE8f2LbKZ1cnL5HNPr3Eg7UIpJ0=";

  buildInputs = [
    xz
  ];

  meta = with lib; {
    description = "An Android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "payload-dumper-go";
  };
}
