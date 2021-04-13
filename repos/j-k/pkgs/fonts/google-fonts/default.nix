{ lib, fetchFromGitHub }:

let
  pname = "google-fonts";
  version = "2021-04-09";
in fetchFromGitHub {
  name = "${pname}-${version}";
  owner = "google";
  repo = "fonts";
  rev = "2b2aab212c4ed04131063a55ccde23714dd191fd";
  sha256 = "sha256-7jfjXw8TajLCtPv8+lXa0Kkh5m+U51O7pCkx0vLYZ28=";

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
