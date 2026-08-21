{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  xz,
}:

buildGo127Module rec {
  pname = "payload-dumper-go";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = "2.0.2";
    hash = "sha256-k/goQi79CwqO8GWBa5BgzdS0L1ASHjUl/268Q4WLzTY=";
  };

  vendorHash = "sha256-hjVgIVOwci1IXaV+0AHgB36pMSgQsYi3A+9NIMsSz54=";

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
