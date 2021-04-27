{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2021-04-24";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "8070917b7e55893ecf4be648a55459e5a7a92ecc";
    hash = "sha256-cn4Netr/CYT8bG0qqBcbC+V7NrYCtxWbajD+3Sc4DkY=";
  };

  vendorSha256 = "sha256-KYuJl/xqZ/ioMNMugqEKsfZPZNx6u9FBmEkg+1cQX04=";

  meta = with lib; {
    description = "Static git gemini viewer";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
