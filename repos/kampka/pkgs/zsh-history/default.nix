{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "zsh-history";
  version = "2019-12-10";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "8da016bd91b0c2eb53c9980f00eee6abdbb097e2";
    sha256 = "13n643ik1zjvpk8h9458yd9ffahhbdnigmbrbmpn7b7g23wqqsi3";
  };

  modSha256 = "1lyb5n3g1msn4iw1jc7hmrdx6fzphdj7qprvflh2rkyp1q2c8bil";
  goPackagePath = "github.com/b4b4r07/history";

  postInstall = ''
    install -d $out/share
    cp -r "$NIX_BUILD_TOP/source/misc/"* "$out/share"
  '';

  meta = with lib; {
    description = "A CLI to provide enhanced history for your ZSH shell";
    license = licenses.mit;
    homepage = https://github.com/b4b4r07/history;
    platforms = platforms.unix;
    maintainers = with maintainers; [ kampka ];
  };
}
