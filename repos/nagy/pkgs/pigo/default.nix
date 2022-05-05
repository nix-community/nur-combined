{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "pigo";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "esimov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-46/zUdLCcYS0+sVM1HZTfnCHgIJ39p+mjpDPvvq0+UA=";
  };

  vendorSha256 = "1yaiiiamk6wvacsyv04m5gar3rskb0hqa54rrxag8x5lz2rmahij";

  deleteVendor = true;

  postInstall = ''
    mv $out/bin/http $out/bin/pigo-http
  '';

  meta = with lib; {
    description =
      "Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go";
    homepage = "https://github.com/esimov/pigo";
    license = with licenses; [ mit ];
  };
}
