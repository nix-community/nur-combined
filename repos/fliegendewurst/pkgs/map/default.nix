{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "map";
  version = "2020-06-30";

  src = fetchFromGitHub {
    owner = "soveran";
    repo = "map";
    rev = "4296fd49930c32d7ae1e90a74008e8c58e219cda";
    sha256 = "1qxx3871aa1wrcsk0v8iy4cmvymd7pqv2h5m0xpcnwcj42nh5q0f";
  };

  installPhase = ''
    install -D -m755 map $out/bin/map
    install -D -m644 map.1 $out/share/man/man1/map.1
  '';

  meta = with lib; {
    description = "Map lines from stdin to commands";
    homepage = "https://github.com/soveran/map";
    license = licenses.bsd2;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
