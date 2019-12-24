{ lib, buildGoModule, mbtileserver }:

buildGoModule rec {
  pname = "mbtileserver";
  version = lib.substring 0 7 src.rev;
  src = mbtileserver;

  modSha256 = "0pa9dni3ihxnqpvarxmgvlm9wlgalnx97bdhy8s36as1rdzbgl16";

  meta = with lib; {
    description = mbtileserver.description;
    homepage = "https://github.com/consbio/mbtileserver";
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
  };
}
