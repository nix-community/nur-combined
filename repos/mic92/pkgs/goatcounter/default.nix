{ lib, buildGoModule, fetchFromGitHub, sqlite, postgresql }:

buildGoModule rec {
  pname = "goatcounter";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "zgoat";
    repo = "goatcounter";
    rev = "v${version}";
    sha256 = "sha256-XL16ryJmb0O+rvCP332fFSM0CrxoviBXwUKIwiFjG7Q=";
  };

  #LD_LIBRARY_PATH = lib.makeLibraryPath [ sqlite postgresql ] ;
  doCheck = false;

  vendorSha256 = "sha256-2qzdF4VpJB7lw/9+5zxmUJH58dWjPS9JeVVnxjJJqX0=";

  meta = with lib; {
    description = "Easy web analytics. No tracking of personal data.";
    homepage = "https://www.goatcounter.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
