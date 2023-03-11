{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake, installShellFiles, openssl }:

stdenv.mkDerivation rec {
  pname = "flashmq";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "halfgaar";
    repo = "FlashMQ";
    rev = "v${version}";
    hash = "sha256-VikTaPczF1+Bk/K6D5lZgyLybNETtm0YTEwFgPmpiiw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/halfgaar/FlashMQ/commit/f33117351496143eb7bf8362697d40f4c74da5b8.patch";
      hash = "sha256-gEEzQm2g1/G3eh8z1Ao90Nzg8RmTLvRpw2jVWBMyM68=";
    })
  ];

  postPatch = ''
    substituteInPlace mainapp.cpp --replace "/etc/flashmq" "$out/etc/flashmq"
  '' + lib.optionalString (stdenv.isLinux && !stdenv.isx86_64) ''
    substituteInPlace CMakeLists.txt --replace "-msse4.2" ""
  '';

  nativeBuildInputs = [ cmake installShellFiles ];

  buildInputs = [ openssl ];

  installPhase = ''
    install -Dm755 flashmq -t $out/bin
    install -Dm644 $src/flashmq.conf -t $out/etc/flashmq
    installManPage $src/man/*.{1,5}
  '';

  meta = with lib; {
    description = "Fast light-weight MQTT broker/server";
    homepage = "https://www.flashmq.org/";
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
