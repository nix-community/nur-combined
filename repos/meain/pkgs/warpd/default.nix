{ pkgs, lib, xorg, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "warpd";
  name = pname;
  version = "1.1.2-beta";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-2gq5DZs5QGiz4kSDdqHjPX0uFh9WwomWWGV5YujE+Mc=";
  };

  nativeBuildInputs = [xorg.libX11 xorg.libXi xorg.libXinerama xorg.libXft xorg.libXtst xorg.libXext.dev];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/warpd $out/bin/warpd
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "A small X program which provides novel methods for keyboard driven cursor manipulation. ";
    homepage = "https://github.com/rvaiya/${pname}";
    license = licenses.mit;
  };
}
