{ rustPlatform, fetchFromGitHub, stdenv, fzf, makeWrapper, ... }:

rustPlatform.buildRustPackage rec {

  name = "navi-${version}";

  version = "e99e1511e50a2706f0eea3286df94b6373acf8b0";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    # rev = "v${version}";
    rev = "${version}";
    sha256 = "07pfyvbzy62i5ncxgwcdim1pl5nfis3b8a2vkvjdvz167kx99xhg";
  };

  cargoSha256 = "18d3b9g2jxkgscx9186v5301y4y01wd00kcs14617fgjnv0lyz1g";
  verifyCargoDeps = true;

  postInstall = ''
    mkdir -p $out/share/navi/
    cp -r ./cheats $out/share/navi/
    wrapProgram "$out/bin/navi" \
      --suffix "PATH" : "${fzf}/bin" \
      --suffix "NAVI_PATH" : "$out/share/navi/cheats"
  '';
  buildInputs = [ fzf makeWrapper ];

  meta = with stdenv.lib; {
    description = "An interactive cheatsheet tool for the command-line";
    homepage = "https://github.com/denisidoro/navi";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}

