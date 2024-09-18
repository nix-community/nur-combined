{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule {
  pname = "diffnav";
  version = "2024-09-18";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "diffnav";
    rev = "ea5ccdb02dc1c8fdd12429975e9b6f79c8e43dcd";
    hash = "sha256-y+nODXTZpXdUTQYwqL01rPvD8bHhI48EH1TuEhPAeMU=";
  };

  vendorHash = "sha256-doRzntvXr7O7kmFT3mWXLmMjx6BqrnIqL3mYYtcbGxw=";

  postPatch = ''
    sed 's/1.22.6/1.22.5/' -i go.mod
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

