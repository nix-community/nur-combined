{ rustPlatform, fetchFromGitHub, stdenv, fzf, makeWrapper }:

rustPlatform.buildRustPackage rec {

  pname = "navi";
  version = "2.0.11";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    rev = "v${version}";
    sha256 = "1pd4rzy4fy6c0pv3pr6q2v5v13amksmw9p6kywcr48z76rhksnbn";
  };

  cargoSha256 = "18d3b9g2jxkgscx9186v5301y4y01wd00kcs14617fgjnv0lyz1g";

  verifyCargoDeps = true;

  postInstall = ''
    mkdir -p $out/share/navi/
    mv cheats $out/share/navi/
    wrapProgram "$out/bin/navi" \
      --suffix "PATH" : "${fzf}/bin" \
      --suffix "NAVI_PATH" : "$out/share/navi/cheats"
  '';
  buildInputs = [ makeWrapper ];

  meta = with stdenv.lib; {
    description = "An interactive cheatsheet tool for the command-line";
    homepage = "https://github.com/denisidoro/navi";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}

