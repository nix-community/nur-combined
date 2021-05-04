{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "gmnigit";
  version = "2021-05-03";

  src = fetchFromSourcehut {
    owner = "~kornellapacz";
    repo = pname;
    rev = "6104fffa30382eac461668cd3e3334aeb9be5898";
    hash = "sha256-/1iicldvGgIm/GZEQBkdJ9ML/a/5PfJA/fvfBRTPVFs=";
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
