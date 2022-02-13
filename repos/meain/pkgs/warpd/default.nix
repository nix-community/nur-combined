{ pkgs, lib, xorg, xlibs, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "warpd";
  name = pname;
  version = "617f0e08d5a4ec80ce8df0d4e66f9edb32188921";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-WuejZx65XuhESwNgfc5E3L10rXFJWoxivjqgXhmA/wc=";
  };

  nativeBuildInputs = [xorg.libX11 xorg.libXi xorg.libXinerama xorg.libXft xorg.libXtst xlibs.libXext.dev];
  patches = [ ./change-font.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/warp $out/bin/warpd
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "A small X program which provides novel methods for keyboard driven cursor manipulation. ";
    homepage = "https://github.com/rvaiya/${pname}";
  };
}
