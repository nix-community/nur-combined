{ lib
, buildGoModule
, fetchFromSourcehut
, ffmpeg
, makeWrapper
}:

buildGoModule rec {
  pname = "unflac";
  version = "1.0";

  src = fetchFromSourcehut {
    owner = "~ft";
    repo = "unflac";
    rev = version;
    hash = "sha256-hLEyJOREWZNA3bGdD5nkKf4QpdujRdZVr5vVklClnO4=";
  };

  vendorSha256 = "sha256-QqLjz1X4uVpxhYXb/xIBwuLUhRaqwz2GDUPjBTS4ut0=";

  postInstall = ''
    wrapProgram $out/bin/unflac \
      --prefix PATH : ${lib.getBin ffmpeg}/bin
  '';

  nativeBuildInputs = [ makeWrapper ];
  # buildInputs = [];
  # propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "A command line tool for fast frame accurate audio image + cue sheet splitting";
    homepage = "https://git.sr.ht/~ft/unflac";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
