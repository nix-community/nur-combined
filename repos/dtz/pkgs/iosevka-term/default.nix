{ stdenv, fetchzip }:

let
  version = "2.3.0";
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
  ss01 = mkSS "01" "0y0jiw0jiylgdc3d4z03macnc2xwnfp8jk0b221b3081xm15wc8i";
  ss02 = mkSS "02" "1h78i5mnbwhy3h6l2vacbn8szax00cxybgg4c98my5v310pyjxg8";
  ss03 = mkSS "03" "0pb6g9sxwp7qjd7jgb13856hnrzv54zxvdmvzfgwf4yz1kfp2hks";
  ss04 = mkSS "04" "1avychvkyhwb4mr5azz7hxcw1lgjlgphbx3jn0x5pd07d5w5dba8";
  ss05 = mkSS "05" "0lzfvwnwf643v6sdj1933br9l5phjdw6qw70bf9khz27k0lz1iwh";
  ss06 = mkSS "06" "08i8s3b5kc2ck3q8ds7ymlmnr4wpyp5n6pbcrikq9wpmz9hml8al";
  ss07 = mkSS "07" "1w1vi0gm5id0wlsckrq1qk0jvwdh3658ld1dgca874dycw7gl30q";
  ss08 = mkSS "08" "0ygbzqslqf64kcf66wl91jwjjdjdkkfidv488n9i7n20371p9cyg";
  ss09 = mkSS "09" "0y77qbfa1a2nnrf82rn7b9rv3d7xbc5fid4sn26fh5m9dbgb0nly";
  ss10 = mkSS "10" "17k6sr78ll5ycgh1dbwbk6chcsplk5sba3xfajrzy1rmbig6r5nx";
  ss11 = mkSS "11" "1xis1jadvjl3nk3ba7f93032hkaf3swy1g9x2p189k236c73izm8";
}
