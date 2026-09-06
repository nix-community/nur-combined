{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  ffmpeg,
}:
buildGoModule rec {
  pname = "crunchyroll-downloader";
  version = "9861a9b";

  src = fetchFromGitHub {
    owner = "CuteTenshii";
    repo = "crunchyroll-downloader";
    rev = "${version}";
    sha256 = "sha256-yAebPwukzfBZKirnEP73w7/IGnUYa8/QOBJUCT/WsHA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  vendorHash = "sha256-lNWzylzk/VT3/vpSlsxCnVCmUY24dn9zdOp+8TFo0yE=";

  postInstall = ''
    ln -s $out/bin/crunchyroll-downloader $out/bin/crdl
  '';

  postFixup = ''
    wrapProgram $out/bin/crdl --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = with lib; {
    description = "Downloads anime from Crunchyroll and outputs them in a MKV file";
    homepage = "https://github.com/CuteTenshii/crunchyroll-downloader";
    changelog = "https://github.com/CuteTenshii/crunchyroll-downloader/releases";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "crdl";
  };
}
