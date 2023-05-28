{ lib, stdenv, fetchFromGitHub, cmake, installShellFiles, openssl }:

stdenv.mkDerivation rec {
  pname = "flashmq";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "halfgaar";
    repo = "FlashMQ";
    rev = "v${version}";
    hash = "sha256-DcxwwUNpnMeK8A3LuyfrWAMCng0yIcX9bKxNGY0uDSo=";
  };

  postPatch = ''
    substituteInPlace mainapp.cpp --replace "/etc/flashmq" "$out/etc/flashmq"
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
