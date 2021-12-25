{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "pigo";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "esimov";
    repo = pname;
    rev = "v${version}";
    sha256 = "0pwyv7ys7w7d3dz22xs8ddxi3kj7yj2k2wxj8z5pg87vfmx8lhl4";
  };

  vendorSha256 = "1yaiiiamk6wvacsyv04m5gar3rskb0hqa54rrxag8x5lz2rmahij";

  deleteVendor = true;

  postInstall = ''
     # this generic name might conflict with other packages
     rm -f $out/bin/http
  '';

  meta = with lib; {
    description = "Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go";
    homepage = "https://github.com/esimov/pico";
    license = with licenses; [ mit ];
  };
}
