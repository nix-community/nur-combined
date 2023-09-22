{ lib, stdenv, fetchFromGitHub, pkg-config, autoreconfHook, libite, libuev, libconfuse }:

stdenv.mkDerivation rec {
  pname = "watchdogd";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "watchdogd";
    rev = "${version}";
    hash = "sha256-DnXIOGZQK16jn20ASwrKIih/61zUuTTgeq7Gv9WLxxU=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ libite libuev libconfuse ];

  meta = with lib; {
    description = "Advanced system & process supervisor for Linux";
    homepage = "https://troglobit.com/watchdogd.html";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = with maintainers; [vifino];
  };
}
