{ lib
, stdenv
, fetchFromGitHub
, cmake
, sway
, iio-sensor-proxy
, offsetDegrees ? 0
, outputName ? "eDP-1"
}:

let
  rem = top: bot: let k = builtins.div top bot; in top - k * bot;
  rotBase.normal = 0;
  rotBase.right-up = 90;
  rotBase.bottom-up = 180;
  rotBase.left-up = 270;
  rot = builtins.mapAttrs (name: value: rem (value + offsetDegrees) 360) rotBase;
in
stdenv.mkDerivation rec {
  pname = "sway-autorotate";
  version = "unstable-2023-05-16";

  src = fetchFromGitHub {
    owner = "emiljonsrud";
    repo = "sway_autorotate";
    rev = "118d7b7ef71b613ec5e6a8da6964aba911a85901";
    hash = "sha256-nwLrQTT9gA9RFy6Wijc1yRqf5uke2jmIHxlKlGfxCUI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  postPatch = ''
    cp ${./CMakeLists.txt} ./CMakeLists.txt
    sed -i \
      -e 's|swaymsg|${sway}/bin/swaymsg|g' \
      -e 's|monitor-sensor|${iio-sensor-proxy}/bin/monitor-sensor|g' \
      -e 's|eDP-1|${outputName}|g' \
      -e 's|"normal", "${toString rotBase.normal}"|"normal", "${toString rot.normal}"|' \
      -e 's|"right-up", "${toString rotBase.right-up}"|"right-up", "${toString rot.right-up}"|' \
      -e 's|"bottom-up", "${toString rotBase.bottom-up}"|"bottom-up", "${toString rot.bottom-up}"|' \
      -e 's|"left-up", "${toString rotBase.left-up}"|"left-up", "${toString rot.left-up}"|' \
      autorotate.cpp
  '';

  meta = with lib; {
    description = "Service to autorotate laptop screen in sway";
    homepage = "https://github.com/emiljonsrud/sway_autorotate/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
