{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, acpi
, feh
, xorg
, coreutils
}:

stdenv.mkDerivation rec {
  pname = "battery-wallpaper";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = pname;
    rev = "3320d464e813257acfe361f02ad933fb81a2b5d9";
    hash = "sha256-2xH0MmQr6jxB6eFADRm1yCWh/000IEByXwNNEJ/UItY=";
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ feh acpi xorg.xrandr ];

  installPhase = ''
    mkdir -p $out/usr/share/battery-wallpaper/
    cp -r ./images $out/usr/share/battery-wallpaper/
    install -Dm 755 bwall.sh $out/bin/bwall
  '';

  
  postFixup = ''
    substituteInPlace $out/bin/bwall \
      --replace "/usr/share/battery-wallpaper/images" "$out/usr/share/battery-wallpaper/images" \

    wrapProgram "$out/bin/bwall" \
      --prefix PATH : "$out/bin" \
      --prefix PATH : ${lib.makeBinPath buildInputs };
  '';
  
  meta = {
    description = "A simple bash script to set an animated battery as desktop wallpaper";
    homepage = "https://github.com/adi1090x/battery-wallpaper/tree/master";
    license = lib.licenses.gpl3;
  };
}


