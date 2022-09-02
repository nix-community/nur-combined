{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gmnhg";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "tdemin";
    repo = "gmnhg";
    rev = "v${version}";
    hash = "sha256-c60dBp9jY8ZepLkQzy1VCZ5DK/y2eey+cdXrexDlCDM=";
  };

  vendorHash = "sha256-q6302+asnOyZ59cRKg3ZUvrCtO7+nYohkmNSuVdKiLE=";

  meta = with lib; {
    description = "Hugo-to-Gemini Markdown converter";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
