{ stdenv, fetchzip }:

let
  version = "2.0.0";
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
  ss01 = mkSS "01" "0banyj4lpr0nnnarm42vkckasgagqd41q8r4ksy0y16ggidb61v6";
  ss02 = mkSS "02" "0ivpa69yzp0b6gg8hyi632v51jznjr789i76sanwggz0h6hjbyxj";
  ss03 = mkSS "03" "0yfbrvfpxanl4d5ys9kg2xybdbncaxcd44sf57z6akawk8d7bpm7";
  ss04 = mkSS "04" "1vqdp9nn2x1r95xs4nhnp7fxnhsfl1hddlcs1djmqg0pxp4p1v52";
  ss05 = mkSS "05" "1ccmn4a9drzp2w6cyj2dgl6v8857ms8bml09f5qpp126f58f7dmw";
  ss06 = mkSS "06" "128p9r9m289svdqknqdw8p4408lyp656j03wdrazmxbigh6hd8q3";
  ss07 = mkSS "07" "0cvgp1y32x9g6rrrgj2ag9sidqpfhjyi4fa9rn38vplzl04v9k67";
  ss08 = mkSS "08" "1498747cy2vvpmlzigsbpz3167v8qhjb4hjb2yrqbakbx5wssh25";
  ss09 = mkSS "09" "1qa4x4gsqd99blgfyifxwxayn5vq4ifnf5vi5856jzfp0qqas9rv";
  ss10 = mkSS "10" "1vmx9933x90w51r43bjn37dvhbpr9y0invvbf2616kir9wl4nk72";
  ss11 = mkSS "11" "0az1fsd63p5kz5j956ywnxnw6jmm60b1q3f9bn9q6kblcrqsjgwc";
}
