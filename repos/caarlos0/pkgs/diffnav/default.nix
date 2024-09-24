{ lib
, pkgs
, buildGoModule
, fetchFromGitHub
, makeWrapper
}:
buildGoModule rec {
  pname = "diffnav";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "diffnav";
    rev = "v${version}";
    hash = "sha256-y+nODXTZpXdUTQYwqL01rPvD8bHhI48EH1TuEhPAeMU=";
  };

  vendorHash = "sha256-doRzntvXr7O7kmFT3mWXLmMjx6BqrnIqL3mYYtcbGxw=";

  postPatch = ''
    sed 's/1.22.6/1.22.5/' -i go.mod
  '';

  nativeBuildInputs = [ makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/diffnav \
      --prefix PATH : ${lib.makeBinPath [ pkgs.delta ]}
  '';

  doCheck = false;

  meta = with lib; {
    description = "A git diff pager based on delta but with a file tree, à la GitHub";
    homepage = "https://github.com/dlvhdr/diffnav";
    changelog = "https://github.com/dlvhdr/diffnav/commits";
    maintainers = with maintainers; [ caarlos0 ];
    mainProgram = "diffnav";
  };
}

