{ stdenv, fetchzip }:

let
  version = "2.2.0";
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
  ss01 = mkSS "01" "0809jb8zasv8xz1yfk931shjavpqa98zw9k98z6ilg86dvr7n3p7";
  ss02 = mkSS "02" "1d8wvszfj1rzaav1svvbdnn13d3mr0q73s0645zwdi0mf8j4ys3n";
  ss03 = mkSS "03" "0hnj78fpf65rwzfgrhpxjp4rna0yg3zs7pwhc3iggp37c9shdrb3";
  ss04 = mkSS "04" "03qjw7mr91wcmwlxa5pqkmyk0i3jgbck1v3nkz3swr42vq16s63i";
  ss05 = mkSS "05" "1sqbv26fw61n675g9hlzfap6f7gjlakpwfikb7kqn202i0gvwdri";
  ss06 = mkSS "06" "16b74wfr8imlrpixl28yxiv4s2v0sf241j93y0h456a7j33z54ya";
  ss07 = mkSS "07" "1qkqm782gcy2r0vzpkfmrzplllh78flm8v9afzz4ncclqairz9jc";
  ss08 = mkSS "08" "12xcvdrqvv39438d8g4yzclnsiprlypj1mpvh98rr1zipplhwik5";
  ss09 = mkSS "09" "05xp3wmjljllr3q1w37mw93mp0liyhrc30dicrv2wy3pz1ki0amq";
  ss10 = mkSS "10" "1p6ckwyfgmlvrnql4465bjn188d2k02hbp0xmrgkvg15i4jkvqhl";
  ss11 = mkSS "11" "1jx5p4varpdiaysilw3l05yr00v1x0jp9s26wygz55rrszq7shcr";
}
