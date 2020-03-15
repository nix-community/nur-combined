{ rustPlatform, fetchFromGitHub, stdenv, fzf, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname = "navi";
  version = "master";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    rev = "48c2b64f7f184dc351d04d2fe2bda1b2313b8d79";
    sha256 = "1y7mfai7a0hwzq7kw997w0jwjpzqr2wcfr66jxf60k2jpbf4bk8h";
  };

  cargoSha256 = "18d3b9g2jxkgscx9186v5301y4y01wd00kcs14617fgjnv0lyz1g";
  verifyCargoDeps = true;

  postInstall = ''
    mkdir -p $out/share/navi/
    mv cheats $out/share/navi/
    mv shell $out/share/navi/

    wrapProgram "$out/bin/navi" \
      --suffix "PATH" : "${fzf}/bin" \
      --suffix "NAVI_PATH" : "$out/share/navi/cheats"
  '';
  nativeBuildInputs = [ makeWrapper ];


  meta = with stdenv.lib; {
    description = "An interactive cheatsheet tool for the command-line";
    homepage = "https://github.com/denisidoro/navi";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}
