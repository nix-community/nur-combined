{ stdenv, fetchFromGitHub, fetchurl
, meson, ninja, pkgconfig
, xorg
, glm
, python3
, boost
, vulkan-headers
, vulkan-loader
, shaderc
, makeWrapper
}:

let
  args_hxx = fetchurl {
    url = https://raw.githubusercontent.com/Taywee/args/6cd243def4b335efa5a83acb4d29aee482970d2e/args.hxx;
    sha256 = "0lbhqjlii0q1jdwb7pd9annhrlsfarkmdx7zbfllw5wxqrsmj8nc";
  };
  pyboost = python3.pkgs.toPythonModule boost;
  pypkgs =  with python3.pkgs; [ xlib psutil pyboost python ];
  xpkgs = with xorg; [ libxcb xcbutil xcbutilkeysyms xcbutilwm libX11 ];
in
stdenv.mkDerivation rec {
  pname = "chamferwm";
  version = "2019-05-16";
  src = fetchFromGitHub {
    owner = "jaelpark";
    repo = pname;
    rev = "91f3b07d54ebcd0c9f0154e842c31b27069e9057";
    sha256 = "1b4m90nwxdcslkc5y5qhhj8jdyxz0jxhf0iy36alrwxb7p191lvy";
  };

  # to make use easier, use install locations as defaults for path args
  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace $'{"config",\'c\'},"config.py");' \
                $'{"config",\'c\'},"${placeholder "out"}/share/chamfer/config/config.py");' \
      --replace '{"shader-path"});' \
                '{"shader-path"},{"${placeholder "out"}/share/chamfer/shaders"});'

    cp ${args_hxx} third/args/args.hxx
  '';

  nativeBuildInputs = [ meson ninja pkgconfig shaderc makeWrapper ];
  buildInputs = [ glm boost vulkan-headers vulkan-loader ] ++ pypkgs ++ xpkgs;

  # Default copies over the shaders, which is a start but.. ;)
  # Based on upstream's linked PKGBUILD:
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=chamfer-git
  installPhase = ''
    install -Dm755 -t $out/bin chamfer
    install -Dm755 -t $out/share/chamfer/shaders *.spv
    install -Dm755 -t $out/share/chamfer/config ../config/*
  '';

  postFixup = ''
    wrapProgram $out/bin/chamfer --set PYTHONPATH "${python3.pkgs.makePythonPath pypkgs}"
  '';
}

