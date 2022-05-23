{ lib, bluez, fetchFromGitHub, makeWrapper, rofi, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "rofi-bluetooth";
  version = "unstable-2021-10-15";

  src = fetchFromGitHub {
    owner = "nickclyde";
    repo = "rofi-bluetooth";
    rev = "893db1f2b549e7bc0e9c62e7670314349a29cdf2";
    sha256 = "sha256-3oROJKEQCuSnLfbJ+JSSc9hcmJTPrLHRQJsrUcaOMss=";
  };

  buildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/rofi-bluetooth $out/bin/
    chmod a+x $out/bin/rofi-bluetooth
  '';

  wrapperPath = lib.makeBinPath [
    rofi
    bluez
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "A rofi menu for managing bluetooth connections";
    homepage = "https://github.com/nickclyde/rofi-bluetooth/commit/";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
