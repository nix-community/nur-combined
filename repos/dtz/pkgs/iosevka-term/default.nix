{ stdenv, fetchzip }:

let
  version = "2.3.3";
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
  ss01 = mkSS "01" "18f31hsvnwfmwqgbcyy4v19x5idk0mzr5cwk213bx6yac5w5lzcx";
  ss02 = mkSS "02" "1c111asarpdw2jggsqajzhx4z15rh9qgslmzn6zacvxg5j8yzdsi";
  ss03 = mkSS "03" "1v60kxlgfkiv131j0qprs98biwdv9ld9rygla62zfmrlbajpz084";
  ss04 = mkSS "04" "1b7b4v3cwayqixdnh75kscnif6pp474d9dif1axa5l8x6p0cvyr6";
  ss05 = mkSS "05" "0v7ldm0lyvf5hr6dwl6r8pbvyy21hl08a57dyg66g68ya659ynv9";
  ss06 = mkSS "06" "1vxak7qn8vqnvzzydifa7yjrv6yg385hq25wawklrm4ddg3hyrqm";
  ss07 = mkSS "07" "1b4hs7qpcwm935p9kkl9vfl8pc2b1h16x5zm1frqr7f0y05basan";
  ss08 = mkSS "08" "1qymg4w5p07zdhwf3ipmx5qjrsk11kgzj0my1fd5gjx7gnysrb0b";
  ss09 = mkSS "09" "0bj7v8m607flilqpxl9fclh1dnjpz4l4v7qyjzrzlyd91zfvdf15";
  ss10 = mkSS "10" "1hy3b3kjqgcj7x11b4p2pk034vk3kvhk71b3jik1ff5dvx8li6vz";
  ss11 = mkSS "11" "0cfc7bsni9b2s25p050d4axcr47fqm5rayba614aqvd1a95knj10";
}
