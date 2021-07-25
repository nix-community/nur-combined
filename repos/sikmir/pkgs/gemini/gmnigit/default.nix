{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2021-07-19";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "b97513313e1e6ce870c3243b6d6c17424878f9ed";
    hash = "sha256-HMFZUkRU97YxrO+qMCf9z6d0JfPYyFKF7dfjDdilN3E=";
  };

  vendorSha256 = "sha256-IADs5JBIetVm4pYpl3TBUzhYmYV4xOkleXtzd0Yb7cY=";

  meta = with lib; {
    description = "Static git gemini viewer";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
