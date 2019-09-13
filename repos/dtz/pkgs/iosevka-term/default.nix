{ stdenv, fetchzip }:

let
  version = "2.2.1";
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
  ss01 = mkSS "01" "14ksvld849xsblxggl6qiyr7ic05kskx5mfdcn1w9vmcqjkngyyd";
  ss02 = mkSS "02" "12sx7b313cnxi5miczxh8a0qvdvq7vd133k99q43ida24v6dqp0k";
  ss03 = mkSS "03" "1q4m1hkam7lly9kniws72xrilmikjk8hmd38x8m583qrg3hc7y14";
  ss04 = mkSS "04" "0cfkcpdvvdqq4y359f0lmhidlhhn33fsmhw7gqsi4ff5lrqazjja";
  ss05 = mkSS "05" "1vra36lrd10vqd9h37iw3747znxpj5yblnq0f83z8z9ap3v1602d";
  ss06 = mkSS "06" "1cgdfjikm4lp8m3psma5l3bjssypv6jh7qff8pslfk85b637657j";
  ss07 = mkSS "07" "1x7iz9lyzx8ljg8di6bnbrdiv0skim66lb36s770r45m3wz4czxv";
  ss08 = mkSS "08" "0m0iiy98yyaxwxsr42jcai9skyy3shxgs9zhccgrrjhsa8x9n3jb";
  ss09 = mkSS "09" "0ncf3y0v1906lq0k9jjd1ikgl4r8dbxik4v3j6vcri4pfrn2vi2x";
  ss10 = mkSS "10" "18gvi32cxavipxhs4yk0jnlzklaag7klap3m9lyn4gdzdk20zy34";
  ss11 = mkSS "11" "0l9iszmkx8ldkxb010c7gv6dsf5b5xbj828f9mrmq6p5fmz1ljap";
}
