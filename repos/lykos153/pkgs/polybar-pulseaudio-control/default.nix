{ stdenv
, lib
, fetchFromGitHub
, coreutils
, gawk
, gnugrep
, gnused
, libnotify
, pulseaudio
}:

stdenv.mkDerivation rec {
  name = "polybar-pulseaudio-control";
  version = "3.1.1";
  src = fetchFromGitHub
  {
    owner = "marioortizmanero";
    repo = name;
    rev = "v${version}";
    hash = "sha256-egCBCnhnmHHKFeDkpaF9Upv/oZ0K3XGyutnp4slq9Vc=";
  } + "/pulseaudio-control.bash";

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/pulseaudio-control
    substituteInPlace $out/bin/pulseaudio-control \
      --replace pactl ${pulseaudio}/bin/pactl \
      --replace grep ${gnugrep}/bin/grep \
      --replace sed ${gnused}/bin/sed \
      --replace seq ${coreutils}/bin/seq \
      --replace tr ${coreutils}/bin/tr \
      --replace awk ${gawk}/bin/awk \
      --replace notify-send ${libnotify}/bin/notify-send
  '';

  meta = with lib; {
    description = "A feature-full Polybar module to control PulseAudio ";
    homepage = https://github.com/marioortizmanero/polybar-pulseaudio-control;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
