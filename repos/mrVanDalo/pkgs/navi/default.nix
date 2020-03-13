{ rustPlatform, fetchFromGitHub, stdenv, fzf , makeWrapper, ... }:

rustPlatform.buildRustPackage rec {

  name = "navi-${version}";

  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "denisidoro";
    repo = "navi";
    rev = "v${version}";
    sha256 = "1kh4s7s595l95xirdb0fvgkdbig3zcfkdiqk8zdz9cfglzcm5192";
  };

  cargoSha256 = "18d3b9g2jxkgscx9186v5301y4y01wd00kcs14617fgjnv0lyz1g";
  verifyCargoDeps = true;

  postInstall = ''
    mkdir -p $out/share/navi/
    cp -r ./cheats $out/share/navi/
    wrapProgram "$out/bin/navi" \
      --set "PATH" "$PATH:${fzf}/bin" \
      --set "NAVI_PATH" "$NAVI_PATH:$out/share/navi/cheats"

    '';
    buildInputs = [ fzf makeWrapper];

  meta = with stdenv.lib; {
    description = "An interactive cheatsheet tool for the command-line";
    homepage = "https://github.com/denisidoro/navi";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}

