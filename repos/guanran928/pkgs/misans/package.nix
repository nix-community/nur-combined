{
  lib,
  stdenvNoCC,
  fetchzip,
  type ? "ttf",
}:
assert lib.assertOneOf "misans: `type`" type [
  "otf"
  "ttf"
  "vf"
  "woff"
  "woff2"
];
stdenvNoCC.mkDerivation {
  pname = "misans";
  version = "4.003"; # from font metadata

  src = fetchzip {
    url = "https://hyperos.mi.com/font-download/MiSans.zip";
    hash = "sha256-497H20SYzzUFaUHkqUkYlROLrqXRBLkBkylsRqZ6KfM=";
    stripRoot = false;
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase =
    let
      type' =
        {
          otf = "opentype";
          ttf = "truetype";
          vf = "truetype";
        }
        .${type} or type;

      dir = if (type == "vf") then ''MiSans\ VF.ttf'' else "${type}/MiSans-*";
    in
    ''
      runHook preInstall

      install -Dm644 -t $out/share/fonts/${type'} MiSans/${dir}

      runHook postInstall
    '';

  meta = {
    homepage = "https://hyperos.mi.com/font/";
    description = "MiSans font";
    platforms = lib.platforms.all;
    license = lib.licenses.unfree; # https://hyperos.mi.com/font-download/MiSans字体知识产权许可协议.pdf
  };
}
