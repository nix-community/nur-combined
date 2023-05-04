{ lib, stdenv, fetchFromGitHub }:
with lib;
stdenv.mkDerivation {
  pname = "rtl8723cs-firmware";
  version = "2020-07-05";

  src = fetchFromGitHub {
    owner = "anarsoul";
    repo = "rtl8723bt-firmware";
    rev = "8840b1052b4ee426f348cb35e4994c5cafc5fbbd";
    sha256 = "sha256-z6OZNDvGbU1g+U9aL/Pq6fB3l7Fxwq6EHSeHgrkqt78=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/lib/firmware"
    cp -R rtl_bt "$out/lib/firmware"
  '';

  meta = with lib; {
    description = "Firmware for rtl8723bs and rtl8723cs";
    # there are many sources for this, none of them authoritative.
    # the original binaries likely come from some Realtek SDK, hardcoded into a C array
    # if consistent with other drivers, but Realtek does not list this model in their
    # downloads page.
    # other sources:
    # - <https://megous.com/git/linux-firmware>
    # - <https://github.com/armbian/firmware>
    homepage = "https://github.com/anarsoul/rtl8723bt-firmware";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [ colinsane ];
    platforms = with platforms; linux;
  };
}

