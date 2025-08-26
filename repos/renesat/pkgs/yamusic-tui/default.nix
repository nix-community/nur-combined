{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  alsa-lib,
  xorg,
}:
buildGoModule rec {
  pname = "yamusic-tui";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "DECE2183";
    repo = "yamusic-tui";
    tag = "v${version}";
    hash = "sha256-OYQpOUrphIIXcQHtzX5lrfEUM7KNY50kaHHln9ya3Z8=";
  };

  proxyVendor = true;

  vendorHash = "sha256-j2mnm5/cIW+kkm2qpFJROjSC3JE0VJIHCTnCug1Ha88=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    xorg.libX11
  ];

  meta = {
    description = "An unofficial Yandex Music terminal client";
    homepage = "https://github.com/DECE2183/yamusic-tui";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
    platforms = lib.platforms.linux;
  };
}
