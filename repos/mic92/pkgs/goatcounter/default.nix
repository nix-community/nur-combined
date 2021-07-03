{ lib, buildGoModule, fetchFromGitHub, sqlite, postgresql }:

buildGoModule rec {
  pname = "goatcounter";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "zgoat";
    repo = "goatcounter";
    rev = "v${version}";
    sha256 = "sha256-Le0ZQ9iYrCEcYko1i6ETyi+SFOUMuWOoEJDd6nNxiuQ=";
  };

  subPackages = [ "cmd/goatcounter" ];

  buildFlagsArray = [
    "-ldflags="
    "-X=main.Version=${version}"
  ];

  #LD_LIBRARY_PATH = lib.makeLibraryPath [ sqlite postgresql ] ;
  doCheck = false;

  vendorSha256 = "sha256-z9SoAASihdTo2Q23hwo78SU76jVD4jvA0UVhredidOQ=";

  meta = with lib; {
    description = "Easy web analytics. No tracking of personal data.";
    homepage = "https://www.goatcounter.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
