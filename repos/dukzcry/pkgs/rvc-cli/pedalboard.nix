{
  pkgs,
  lib,
  python3,
  fetchgit,
  fetchFromGitHub,
  stdenv,
  libcxx,
  pcre,
  dos2unix
}:

let
  patchFunction = path: ''
    ${dos2unix}/bin/dos2unix ${path}modules/juce_dsp/frequency/juce_Windowing.cpp
    ${dos2unix}/bin/dos2unix ${path}modules/juce_dsp/frequency/juce_Windowing.h
    ${dos2unix}/bin/dos2unix ${path}modules/juce_gui_basics/misc/juce_DropShadower.cpp
    ${dos2unix}/bin/dos2unix ${path}modules/juce_gui_basics/misc/juce_DropShadower.h
    ${dos2unix}/bin/dos2unix ${path}modules/juce_gui_basics/native/juce_linux_Windowing.cpp
  '';
  # Pedalboard still uses JUCE 6 as a submodule.
  juce6 = pkgs.juce.overrideAttrs (attrs: {
    version = "6.1.4";
    patches = attrs.patches or [ ] ++ [ ./juce.patch ];

    prePatch = patchFunction "";

    src = fetchFromGitHub {
      owner = "juce-framework";
      repo = "juce";
      rev = "ddaa09110392a4419fecbb6d3022bede89b7e841";
      hash = "sha256-XXG5BHLjYHFX4SE+GR0p+4p3lpvQZVRyUv080eRmvtA=";
    };
  });
in
python3.pkgs.buildPythonPackage rec {
  pname = "pedalboard";
  version = "0.8.3";
  pyproject = true;

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [
    "-I${lib.getDev libcxx}/include/c++/v1"
    "-I${juce6}/share/juce/modules"
    "-I${juce6}/share/juce/modules/juce_audio_processors/format_types/VST3_SDK"
  ];

  src = fetchgit {
    url = "https://github.com/spotify/pedalboard.git";
    rev = "v${version}";
    hash = "sha256-kp2PJ3dadfbsxtAogYnwc0dzfEbmET/tIUP0M9B0Udg=";
    fetchSubmodules = true;
  };

  prePatch = patchFunction "JUCE/";

  patches = [ ./juce.patch ];
  patchFlags = [
    "-p1"
    "-d"
    "JUCE"
  ];

  nativeBuildInputs = with python3.pkgs; [
    pkgs.pkg-config-unwrapped
    pkgs.python3Packages.pkgconfig
    setuptools
    wheel
    pybind11
    juce6
    pcre

    pkgs.gnumake
    pkgs.xorg.libX11.dev
    pkgs.xorg.libXft
    pkgs.xorg.libXinerama
    pkgs.xorg.xrandr
    pkgs.xorg.libXrandr
    pkgs.xorg.libxshmfence
    pkgs.xorg.libXext
    pkgs.xorg.xcursorgen
    pkgs.xorg.libXcursor

    (pkgs.python3Packages.freetype-py.overridePythonAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        pkgs.pkg-config-unwrapped
        pkgs.freetype
        pkgs.libsForQt5.libopenshot-audio

        juce6

        pkgs.gnumake
        pkgs.xorg.libX11.dev
        pkgs.xorg.libXft
        pkgs.xorg.libXinerama
        pkgs.xorg.xrandr
        pkgs.xorg.libXrandr
        pkgs.xorg.libxshmfence
        pkgs.xorg.libXext
        pkgs.xorg.xcursorgen
        pkgs.xorg.libXcursor

      ];
    }))

  ];

  propagatedBuildInputs =
    with python3.pkgs;
    [
      pkgs.pkg-config-unwrapped
      pkgs.python3Packages.pkgconfig
      numpy
      setuptools
      wheel
      pybind11
      juce6

      pkgs.freetype
      juce6
      pkgs.libsForQt5.libopenshot-audio

      pkgs.gnumake
      pkgs.xorg.libX11.dev
      pkgs.xorg.libXft
      pkgs.xorg.libXinerama
      pkgs.xorg.xrandr
      pkgs.xorg.libXrandr
      pkgs.xorg.libxshmfence
      pkgs.xorg.libXext
      pkgs.xorg.xcursorgen
      pkgs.xorg.libXcursor

    ];

  pythonImportsCheck = [ "pedalboard" ];

  meta = with lib; {
    description = "A Python library for working with audio";
    homepage = "https://github.com/spotify/pedalboard";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "pedalboard";
  };
}
