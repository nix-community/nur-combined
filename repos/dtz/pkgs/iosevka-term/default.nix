{ stdenv, fetchzip }:

let
  version = "2.1.0";
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
  ss01 = mkSS "01" "0mb28j65m9wz1pdaq4fx70w6kz8zjn48j4ld2559kfk47c7dsydr";
  ss02 = mkSS "02" "1rvzji8494pcklfb8bal67k8jq4k8fx7hp92j89dw8d8p9fjfrz2";
  ss03 = mkSS "03" "0jvk2b2s6zzrzxqvxgncplja00nm7hvisk0kj1h2w6fjhxq0xpa0";
  ss04 = mkSS "04" "0b5qsh1d90xfm42y98hfp8gxg23216lkyxgzn8cigm00xb2vxwz7";
  ss05 = mkSS "05" "15rn9f90svd7m2imr54vag33k86qlvsh372vfhlgcw41jhl3hsjb";
  ss06 = mkSS "06" "1rmsmnpy9lsrdhvvnp2sm3qgkn84alp1b6c4aykbnn49h7lkm0vj";
  ss07 = mkSS "07" "0vxvyxw9y7a5w87msw20br7sg8h88f3c9lnxif50zc4p3pqfd823";
  ss08 = mkSS "08" "1n3ws77px1s6ip000n4g8w7ydsc665srzg9zdmzxj7hfj5syjvaw";
  ss09 = mkSS "09" "1q08mz9f1bfb4kgz98ksl3n7c9df8bs5jyg260vwfm9sc4y0gpak";
  ss10 = mkSS "10" "01k83c34yljg3djn8xf1pzm21nw7048zc6arzszdgnrw771aywk0";
  ss11 = mkSS "11" "0pval28gli5a8r43yjjg2zikv4121j11fdcz8jb8622vpy0vjg4m";
}
