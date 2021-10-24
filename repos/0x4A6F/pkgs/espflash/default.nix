{ pkgs, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "espflash";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "esp-rs";
    repo = "espflash";
    rev = "e73960e9788383e9281df5102a7eef2edcd8b6c3";
    sha256 = "1wprr3pc041hfd921vkh9dn2gyyp2g2j1kz9wny5kl94y4614c9d";
  };

  cargoPatches = [ ./Cargo.lock.patch ];
  cargoSha256 = "sha256:03jjbwbid3r0p2v2nwn678r83x7sjp34xswp92rahfbi81x5kg57";

  meta = with pkgs.lib; {
    description = "ESP8266 and ESP32 serial flasher";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.gpl2;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
