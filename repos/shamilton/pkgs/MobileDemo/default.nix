{ lib
, stdenvNoCC
, makeWrapper
, ffmpeg
, gifsicle
}:

stdenvNoCC.mkDerivation rec {
  pname = "MobileDemo";
  version = "unstable";
  
  mobiledemo = ./mobiledemo.sh;
  maquette = ./maquette.png;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    cp $mobiledemo mobiledemo.sh
    cp $maquette maquette.png
    substituteInPlace mobiledemo.sh \
      --replace "maquette.png" "$out/share/maquette.png"
  '';

  installPhase = ''
    runHook preInstall
    install -Dm 755 mobiledemo.sh "$out/bin/mobiledemo"
    install -Dm 644 maquette.png "$out/share/maquette.png"
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram "$out/bin/mobiledemo" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg gifsicle ]}
  '';

  propagatedBuildInputs = [ ffmpeg gifsicle ];

  meta = with lib; {
    description = "Scripts to make mobile apps demo gifs";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
