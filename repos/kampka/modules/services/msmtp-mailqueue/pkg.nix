{ pkgs, stdenv, buildPackages, fetchFromGitHub, makeWrapper, bash }:

stdenv.mkDerivation rec {
  version = "0.1";
  name = "msmtp-mailqueue-${version}";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "kampka";
    repo = "msmtp-mailqueue";
    rev = "42a6304e27d544bd6b6d5f9c3f7d120de7187dd0";
    sha256 = "1s44h2d9n0681fz5i241mz0a8anrgzimbq5bnlv3gyp6rj6b0myn";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 src/msmtpq $out/bin/msmtpq
    install -m 755 src/msmtpq-flush $out/bin/msmtpq-flush
    wrapProgram $out/bin/msmtpq --prefix PATH : "${pkgs.stdenv.lib.makeBinPath [ pkgs.coreutils pkgs.utillinux pkgs.nettools pkgs.bash ]}"
    wrapProgram $out/bin/msmtpq-flush --prefix PATH : "${pkgs.stdenv.lib.makeBinPath [ pkgs.msmtp pkgs.gnupg pkgs.coreutils pkgs.utillinux pkgs.nettools pkgs.bash ]}"
  '';

  fixupPhase = ''
    substituteInPlace $out/bin/msmtpq --replace "${buildPackages.bash}" "${bash}"
    substituteInPlace $out/bin/msmtpq-flush --replace "${buildPackages.bash}" "${bash}"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kampka/msmtp-mailqueue;
    license = licenses.mit;
    description = "sendmail msmtp drop-in that enqueues mail and sends them at a later time using msmtp and a scheduler";
    platforms = platforms.unix;
  };
}
