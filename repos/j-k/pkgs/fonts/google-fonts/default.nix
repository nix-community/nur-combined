{ lib, fetchFromGitHub }:

let
  pname = "google-fonts";
  version = "2021-06-26";
in fetchFromGitHub {
  name = "${pname}-${version}";
  owner = "google";
  repo = "fonts";
  rev = "f2c3da05f6b8d8ee6b3abc4b466287ccdd680501";
  sha256 = "sha256-2xHOXoSRD4p53jg3kouByUINW4CwNyyC7eh1qcEhpNE=";

  postFetch = ''
    tar xf $downloadedFile --strip 1

    # These directories need to be removed because they contain
    # older or duplicate versions of fonts also present in other
    # directories. This causes non-determinism in the install since
    # the installation order of font files with the same name is not
    # fixed.
    rm -r ofl/{cabincondensed,signikanegative,signikanegativesc}
    if find . -name "*.ttf" | sed 's|.*/||' | sort | uniq -c | sort -n | grep -v '^.*1 '; then
      echo "error: duplicate font names"
      exit 1
    fi

    # This abomination of a font causes crashes with `libfontconfig';
    # it has an absurd number of symbols
    rm -r ofl/adobeblank

    # Install without extra wdth/wght files
    find . -name '*.ttf' ! -name "*\[wdth*\]*" ! -name "*\[*wght\]*" -exec install -Dm 444 -t $out/share/fonts/ttf '{}' \+
  '';

  meta = with lib; {
    description = "Font files available from Google Fonts";
    homepage = "https://fonts.google.com";
    license = with licenses; [ asl20 ofl ufl ];
    platforms = platforms.all;
    maintainers = with maintainers; [ jk ];
  };
}
