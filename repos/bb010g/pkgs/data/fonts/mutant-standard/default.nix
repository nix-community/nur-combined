{ lib, stdenvNoCC, fetchzip }:

let
  pname = "mutant-standard";
  version = "2020.04";

  fcConf = "mutant-standard-emoji.conf";

  srcs = {
    sbixotSrc = fetchzip {
      name = "mutant-standard-${version}-sbixot-source";
      url = "https://mutant.tech/dl/${version}/mtnt_${version}_font_sbixot.zip";
      sha256 = "1sb1l24szj85qsy365zhg5v0j7bxvcwhb5lrd4maambyjpp0hd69";
    };
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  srcs = lib.attrValues srcs;

  fontconf_45 = builtins.toFile "45-${fcConf}" /*xml*/''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias binding="same">
    <family>Mutant Standard emoji</family>
    <default><family>emoji</family></default>
  </alias>
</fontconfig>
'';
  fontconf_60 = builtins.toFile "60-${fcConf}" /*xml*/''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias binding="same">
    <family>emoji</family>
    <prefer>
      <family>Mutant Standard emoji</family>
    </prefer>
  </alias>
</fontconfig>
'';
  fontconf_80 = builtins.toFile "80-${fcConf}" /*xml*/''
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="scan">
    <test name="family">
      <string>Mutant Standard emoji (sbixOT)</string>
    </test>
    <edit name="family" mode="append" binding="same">
      <string>Mutant Standard emoji</string>
    </edit>
  </match>

  <match target="scan">
    <test name="family">
      <string>Mutant Standard emoji</string>
    </test>
    <edit name="lang" binding="strong">
      <string>und-zsye</string>
    </edit>
    <edit name="color" binding="strong">
      <bool>true</bool>
    </edit>
  </match>
</fontconfig>
'';

  setSourceRoot = ''sourceRoot=$(pwd)'';
  postUnpack = ''
    mkdir src
    for i in ./*-source; do
      mv "$i" "src/''${i%-source}"
    done
  '';

  buildPhase = /*sh*/''
    runHook preBuild

    mkdir -p out/fonts
    mv src/mutant-standard-''${version}-sbixot/font/MutantStandardEmoji-sbixOT.ttf \
      out/fonts/MutantStandardEmoji-sbixot.ttf

    mkdir -p out/fontconfig
    cp "$fontconf_45" out/fontconfig/45-${fcConf}
    cp "$fontconf_60" out/fontconfig/60-${fcConf}
    cp "$fontconf_80" out/fontconfig/80-${fcConf}

    runHook postBuild
  '';

  installPhase = /*sh*/''
    runHook preInstall

    # mkdir -p "$out"/share/fonts/opentype
    # mv -t "$out"/share/fonts/opentype out/fonts/*.otf
    mkdir -p "$out"/share/fonts/truetype
    mv -t "$out"/share/fonts/truetype out/fonts/*.ttf

    mkdir -p "$out"/etc/fonts/conf.d
    mv -t "$out"/etc/fonts/conf.d/ out/fontconfig/*.conf

    runHook postInstall
  '';

  meta = {
    description = "Mutant Standard alternative emoji set";
    longDescription = ''
      Mutant Standard is an alternative emoji set. It rejects the status quo
      while maintaining many old favourites. It is pushing for a more diverse
      emoji future.

      Unlike other emoji sets, this is truly gender-neutral and inclusive to
      people of all kinds of orientations and genders.

      There are all-new ways to express yourself, including new emoji and
      modifiers for furries and roleplayers.

      Inspired by older emoji and emoticons, it's bright, simple and readable
      in many environments. Even on dark backgrounds!

      Mutant Standard is independent and free - it's supported by people like you.

      No marketing, no brands, no spying.
    '';
    homepage = "https://mutant.tech/";
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
  };
}
