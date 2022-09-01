{ lib, stdenv, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "gemini-ipfs-gateway";
  version = "2022-07-06";

  src = fetchFromSourcehut {
    owner = "~hsanjuan";
    repo = pname;
    rev = "fc646a2089758c1af9aba790a991c19a2e6b37e8";
    hash = "sha256-50viZnrgrxXNmpmfV1NQn/QTAlSEO505jbz1pzPfypA=";
  };

  vendorHash = "sha256-nSeVJrQKbUHhLPggIfir+YGoXuMLwmon+ZgJHfNNqdM=";

  meta = with lib; {
    description = "IPFS access over the Gemini protocol";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
