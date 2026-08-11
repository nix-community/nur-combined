# based on https://github.com/NixOS/nixpkgs/pull/421656

{
  lib,
  fetchFromGitHub,
  xclip,
  xsel,
  buildPythonApplication,
  setuptools,
  pyaudio,
  pycodec2,
  audioop-lts,
  mistune,
  beautifulsoup4,
  sh,
  materialyoucolor,
  qrcode,
  pillow,
  kivy,
  lxmf,
  rns,
  numpy,
  lxst,
  # pyobjus # sys.platform=='darwin'",
  imagemagick,
}:

buildPythonApplication rec {
  pname = "sideband";
  version = "1.8.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "Sideband";
    tag = "${version}";
    hash = "sha256-iaYRPywlRYeW+nOudxv/DDUkDG0pzd8Ty3MC3IOARWs=";
  };

  postPatch = ''
    sed -i 's|Exec=sideband|Exec=$out/bin/sideband|' sbapp/assets/io.unsigned.sideband.desktop

    substituteInPlace sbapp/sideband/core.py \
      --replace-fail \
        '                    if not self.is_daemon:' \
        '                    if False: # dont install desktop files on nixos linux'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    pyaudio
    pycodec2
    audioop-lts
    mistune
    beautifulsoup4
    sh
    materialyoucolor
    qrcode
    pillow
    kivy
    lxmf
    rns
    numpy
    lxst
  ];

  propagatedBuildInputs = [
    xclip
    xsel
  ];

  nativeBuildInputs = [
    imagemagick
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp sbapp/assets/io.unsigned.sideband.desktop $out/share/applications

    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/$i"x"$i/apps
      magick sbapp/assets/icon.png -background none -resize $i"x"$i $out/share/icons/hicolor/$i"x"$i/apps/${pname}.png
    done
  '';

  meta = {
    description = "Extensible Reticulum LXMF messaging and LXST telephony client";
    homepage = "https://github.com/markqvist/Sideband";
    license = lib.licenses.cc-by-nc-sa-40;
    mainProgram = "sideband";
  };
}
