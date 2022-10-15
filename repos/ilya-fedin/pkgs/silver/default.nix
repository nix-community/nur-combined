{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl_1_1 }:

rustPlatform.buildRustPackage rec {
  pname = "silver";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "reujab";
    repo = pname;
    rev = "v${version}";
    sha256 = "1p9c7l2bcc9pv5v9bgk01wrqdbcpvc3clf1sv0lw7ydq44ihqm08";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl_1_1 ];

  cargoSha256 = "1whzqf4nw47dm1sppqsv429j4nfg5g891g03l266ba57k3lfl1ib";

  meta = with lib; {
    description = "A cross-shell customizable powerline-like prompt with icons";
    homepage = https://github.com/reujab/silver;
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
