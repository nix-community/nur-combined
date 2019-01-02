{ stdenv, fetchzip }:

let
  version = "2.0.2";
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
  ss01 = mkSS "01" "08l2fis7lncm2yf33yvg3scqvim7viv6s8fm3ii825y759g4nwk1";
  ss02 = mkSS "02" "0fzcbz8p1iaf4y6dnr7f7wsb1y7pa6hy2a690ri1wyw01764fs7p";
  ss03 = mkSS "03" "0yxy15vsr4nlwgqgi8bps23rzmbj6m595ygya1p145n4bs4i21pr";
  ss04 = mkSS "04" "1vklbn63q5ksncjp16mh2hjwxm44lbhmj36rl8i32cv0673q9dzy";
  ss05 = mkSS "05" "0ksym4vlckahid7ik9pn5c3ysgp6wqrpsr2h0ngx16axr8yh1mcc";
  ss06 = mkSS "06" "1ashv9jbq414zs9mx400b0wng3hm0avxylvnknkkgfnh59w55rab";
  ss07 = mkSS "07" "0icrsazd9phjjq2hnqr72jqwlwwarhrx78r3a3kcmf93mafyfj1n";
  ss08 = mkSS "08" "16j74cm2dfp9ih40brp7fw676mrwysji2dih72zi0jxsqglqxhly";
  ss09 = mkSS "09" "00z5n51bw57nm9wfscfdwzvfmq2pl29ijqxsk6kb8v2h0p5yl5fs";
  ss10 = mkSS "10" "0nb839bkv343y2wl7s52gkf6h69kv37qkjbyw8gmlx9svjjrphvl";
  ss11 = mkSS "11" "0n4l2nlskpvjnn84qxh51df3pyxbvd2jlmapignwwkyx8f7y48xw";
}
