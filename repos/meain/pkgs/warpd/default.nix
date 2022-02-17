{ pkgs, lib, xorg, xlibs, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "warpd";
  name = pname;
  version = "0cb25272c7ad6521158cedfc0971adb5d6cbd71b";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-eXMSrPvMR/GURoiXb06UNlxS6fjLFmsusdKeYOnMdS8=";
  };

  nativeBuildInputs = [xorg.libX11 xorg.libXi xorg.libXinerama xorg.libXft xorg.libXtst xlibs.libXext.dev];
  patches = [ ./font-config.patch ]; # add option to customize fonts

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
