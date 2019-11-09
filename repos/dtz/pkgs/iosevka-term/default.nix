{ stdenv, fetchzip }:

let
  version = "2.3.2";
  mkSS = ss: sha256:
    let pname = "iosevka-term-ss${ss}"; in fetchzip rec {
    name = "${pname}-${version}";

    url = "https://github.com/be5invis/Iosevka/releases/download/v${version}/${name}.zip";

    postFetch = ''
      mkdir -p $out/share/fonts/
      unzip -j $downloadedFile ttf/\*.ttf -d $out/share/fonts/${pname}
    '';

    inherit sha256;

    meta = with stdenv.lib; {
      homepage = https://be5invis.github.io/Iosevka/;
      downloadPage = "https://github.com/be5invis/Iosevka/releases";
      description = pname;
      longDescription= ''
        Slender monospace sans-serif and slab-serif typeface inspired by Pragmata
        Pro, M+ and PF DIN Mono, designed to be the ideal font for programming.
        This contains 'Term SS${ss}' variant.
      '';
      license = licenses.ofl;
      platforms = platforms.all;
    };
  };
in {
  # See https://raw.githubusercontent.com/be5invis/Iosevka/master/images/stylesets.png
  ss01 = mkSS "01" "1nxqfgnxwkj6ib69rvc0w16vd53x23qmphiw5dr6dx60ssbbr2v2";
  ss02 = mkSS "02" "1bvhvlir645damywh00padarfy58b6sqx4xx7sdxxkygh6580v9l";
  ss03 = mkSS "03" "05bp7867qd1ry8w42whvx0q5mnjmzay4zilpif2cbv9ws4d75x6g";
  ss04 = mkSS "04" "11pvvzilqcp1wac94vjvjvyzrndvs5vzkr3w8sbg0hraccxncpks";
  ss05 = mkSS "05" "1jbj5kwax4vdn04firs19aajynrgdlvayc2kaaxq54jqpfsh2i6h";
  ss06 = mkSS "06" "05a0284cpc4w6kxzpn48chs96arjbdnixwrxs8lj563gjrvqdypp";
  ss07 = mkSS "07" "0c3adiimw5hp3y61n78582anaag6ii85v5il1g6w41xcwqn4b2qg";
  ss08 = mkSS "08" "0qb5fwi2ahh4kb2fmx1y9kjaqxddk04mh1kxbjyihj31ir8c7rzr";
  ss09 = mkSS "09" "1mvi37khnxnidn0fgkzh18856vp2f55j4500328xg2d3i9ww3cqm";
  ss10 = mkSS "10" "1df0rw0dx92s68987y86fmmx3jfsbm89nfgsgz20pxfp2g5myh2j";
  ss11 = mkSS "11" "1yaghv2xh55hdfn5x8kd9m6vjw73kdp2pxhr0bn9pi0s9idp0d7y";
}
