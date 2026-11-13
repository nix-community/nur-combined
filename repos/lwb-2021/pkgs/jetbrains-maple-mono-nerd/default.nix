{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  nix-update-script,
}:
stdenvNoCC.mkDerivation rec {
  pname = "jetbrains-maple-mono-nerd";
  version = "1.2304.79";
  src = fetchurl {
    url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/${version}/JetBrainsMapleMono-NF-XX-XX-XX.zip";
    hash = "sha256-Wu9Qva7hbUrfNiB7Tw5O77h6T5Y2rrdZWa4yyBM7LHU=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = "unzip $src";
  installPhase = let dirName = "JetBrainsMapleMono";
  in
  ''
    dst_opentype=$out/share/fonts/opentype/NerdFonts/${dirName}
    dst_truetype=$out/share/fonts/truetype/NerdFonts/${dirName}
    
    find -name \*.otf -exec mkdir -p $dst_opentype \; -exec cp -p {} $dst_opentype \;
    find -name \*.ttf -exec mkdir -p $dst_truetype \; -exec cp -p {} $dst_truetype \;
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Fusion JetBrains Maple Mono integration";
    homepage = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
