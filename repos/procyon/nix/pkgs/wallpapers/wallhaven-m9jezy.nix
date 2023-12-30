# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ lib
, stdenv
, imagemagick
, fetchurl
, wallpaperFill ? "#1e1e2e"
, wallpaperColorize ? "75%"
, wallpaperParams ? "-10,0"
}:
stdenv.mkDerivation {
  pname = "wallhaven";
  version = "m9jezy";
  src = fetchurl {
    url = "https://w.wallhaven.cc/full/m9/wallhaven-m9jezy.png";
    hash = "sha256-7jxU/FHwUhEipglwI3pD2EvWqR3oNuWXGg+P4lMnl4Y=";
  };

  nativeBuildInputs = [ imagemagick ];

  unpackPhase = ''
    mkdir $out
    cp -r $src $out/original.png
  '';

  patchPhase = ''
    ${imagemagick}/bin/convert $out/original.png -colorspace Gray $out/grayscale.png
    ${imagemagick}/bin/convert $out/grayscale.png -fill "${wallpaperFill}" -colorize "${wallpaperColorize}" $out/colorized.png
    ${imagemagick}/bin/convert $out/colorized.png -brightness-contrast "${wallpaperParams}" $out/dimmed.png
  '';

  meta = {
    description = "Wallpaper: Sakurajima Mai (Seishun Buta Yarō wa Bunny Girl-senpai no Yume wo Minai)";
    homepage = "https://wallhaven.cc/w/m9jezy";
    license = lib.licenses.unfree;
  };
}
