{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "zsh-history";
  version = "2019-10-07";

  src = fetchFromGitHub {
    owner = "b4b4r07";
    repo = "history";
    rev = "a08ad2dcffc852903ae54b0c5704b8a085009ef7";
    sha256 = "0r3p04my40dagsq1dssnk583qrlcps9f7ajp43z7mq73q3hrya5s";
  };

  modSha256 = "1lyb5n3g1msn4iw1jc7hmrdx6fzphdj7qprvflh2rkyp1q2c8bil";
  goPackagePath = "github.com/b4b4r07/history";

  patches = [
    ./0001-Fix-path-marshalling-when-saveing-config.patch
    ./0002-Add-test-for-marshaling-unmarshaling-configs.patch
  ];

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
