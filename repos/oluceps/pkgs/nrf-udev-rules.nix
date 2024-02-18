{ lib
, stdenv
, fetchFromGitHub
,
}:
## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.opensk-udev-rules ];
stdenv.mkDerivation (finalAttrs: {
  pname = "nrf-udev";

  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NordicSemiconductor";
    repo = "nrf-udev";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bEIAsz9ZwX6RTzhv5/waFZ5a3KlnwX4kQs29+475zN0=";
  };

  dontBuild = true;

  installPhase = ''
    install -D nrf-udev_1.0.1-all/lib/udev/rules.d/71-nrf.rules $out/lib/udev/rules.d/71-nrf.rules
    install -D nrf-udev_1.0.1-all/lib/udev/rules.d/99-mm-nrf-blacklist.rules $out/lib/udev/rules.d/99-mm-nrf-blacklist.rules
  '';

  meta = with lib; {
    homepage = "https://github.com/NordicSemiconductor/nrf-udev";
    description = "None";
    platforms = platforms.linux;
    license = licenses.asl20;
    maintainers = with maintainers; [ oluceps ];
  };
}
)
