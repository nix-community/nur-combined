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
    hash = "sha256-ULNvnvqj/XbeZjbbbmMuU39MXDvf9seD1pN0k/i0rm4=";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--github-release"
      "--asset-regex"
      "JetBrainsMapleMono-NF-XX-XX-XX.zip"
    ];
  };

  meta = with lib; {
    description = "Fusion JetBrains Maple Mono integration";
    homepage = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
