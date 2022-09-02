{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "md2html";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "nocd5";
    repo = "md2html";
    rev = "v${version}";
    hash = "sha256-RVTKLueo9yY/rgSoHW4ILmDeGfw3O6TcAZh3ydHnAto=";
  };

  vendorHash = "sha256-XO8WD/SC2Xii0bUiuOGL9V7XgTJDZjsPrpmyONFm+7U=";

  meta = with lib; {
    description = "Markdown to single HTML";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
