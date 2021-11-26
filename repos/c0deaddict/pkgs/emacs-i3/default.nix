{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "emacs-i3";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = pname;
    rev = version;
    sha256 = "sha256-j03KikRZMZyav0VaGWAuYkOICj1nRqRi+ncwM46Dc7E=";
  };

  cargoSha256 = "sha256-x4dy7lEBov+/7nn7oTqQta2l6gFb5FnWEA3Ws2XPXpQ=";

  meta = with lib; {
    description = "Emacs i3 unified window management";
    homepage = "https://github.com/c0deaddict/emacs-i3";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
