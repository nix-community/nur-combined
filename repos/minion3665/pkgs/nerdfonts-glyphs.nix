{ lib
, fetchFromGitHub
, stdenv
,
}:
stdenv.mkDerivation rec {
  pname = "nerdfonts-glyphs";
  version = "2.1.0";

  # This uses a sparse checkout because the repo is >2GB without it
  src = fetchFromGitHub {
    owner = "ryanoasis";
    repo = "nerd-fonts";
    rev = "v${version}";
    sparseCheckout = [ "/src/glyphs" ];
    sha256 = "sha256-boZUd1PM8puc9BTgOwCJpkfk6VMdXLsIyp+fQmW/ZqI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/fonts/truetype
    mkdir -p $out/bin $out/share/fonts/opentype
    find . -name "*.ttf" -exec mv {} $out/share/fonts/truetype \;
    find . -name "*.otf" -exec mv {} $out/share/fonts/opentype \;

  '';

  meta = with lib; {
    description = "A nerd-fonts copy that only includes the glyphs (rather than patching)";
    homepage = "https://nerdfonts.com/";
    license = licenses.free;
    maintainers = with maintainers; [ minion3665 ];
  };
}
