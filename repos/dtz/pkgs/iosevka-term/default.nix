{ stdenv, fetchzip }:

let
  version = "2.0.1";
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
  ss01 = mkSS "01" "19ca37myc8r4svn8fqgsigfv5w8235yv37a9ff71imw2h1pjqiqr";
  ss02 = mkSS "02" "0fr9q6c7aw74zzn8i40qk5x2kagzahhr82cpcz11kz976456rsv9";
  ss03 = mkSS "03" "03jpylszpd58f7apzp39vm6a4ipqnbwlzcp9z52k4kmfpf1s0k99";
  ss04 = mkSS "04" "1kdmwvngkz2v8h5zmh0rhhb7yk7440xvv5wxn44w7nbwblllsdxd";
  ss05 = mkSS "05" "0bs3aylb4gq052shjq50l5cd2sl4b0mmwdhrdlm5p2xhd8d82xcq";
  ss06 = mkSS "06" "0ailbrwisibfqpjab3vjmkb5a25x6nwkz02vnbip6rw5glh1hnbg";
  ss07 = mkSS "07" "1jbnp549cnq3lm9vnlx5l7jzr05c2bzyy3z68djk9c3nfhhdwin1";
  ss08 = mkSS "08" "0y0szjw0n8p6cs6z0r5fmg86qb1sxiki6lp3xi4i46g9v6vfk5if";
  ss09 = mkSS "09" "17gccawwrs8fyv91psiy5071iny7sj3jhpik4l0pm9ws9mq806wy";
  ss10 = mkSS "10" "02mqdcx5drwqm832r9cl6ks97xf25iksjcmz553c79kd3lqx6kjb";
  ss11 = mkSS "11" "0b5wxxjas6829wl7ia4f21n5fw3hbpvzblv2pc6v8yc8q38r0pyz";
}
