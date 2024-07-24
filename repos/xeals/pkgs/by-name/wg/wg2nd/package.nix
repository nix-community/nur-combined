{ lib
, stdenv
, fetchFromGitHub
, libcap
}: stdenv.mkDerivation {
  pname = "wg2nd";
  version = "20240605.23a3710";
  src = fetchFromGitHub {
    owner = "flu0r1ne";
    repo = "wg2nd";
    rev = "23a37100f121edd0c1291c4a78901662eae5d58b";
    hash = "sha256-XY19Vicg8l/2stlWj1QqJt0pJOi/kueQpBufVlLJVxk=";
  };

  buildInputs = [ libcap ];

  installPhase = ''
    PREFIX=$out BINDIR=/bin make install
  '';

  meta = {
    description = "WireGuard to systemd-networkd Configuration Converter";
    homepage = "https://git.flu0r1ine.net/wg2nd/about";
    license = [ lib.licenses.gpl2Only lib.licenses.mit ];
    platforms = lib.platforms.linux;
  };
}
