{ lib, buildGoModule, fetchgit, sources }:

buildGoModule rec {
  pname = "shavit";
  version = "2020-03-14";

  src = fetchgit {
    url = "https://git.sr.ht/~yotam/shavit";
    rev = "129b3e7fc700d02843c4fbd3e7cc73bf714f9cc2";
    sha256 = "02g1igsx441q20yv2ylc50mf598whl0lfnwrj9nzab1jk5q3nhic";
  };

  vendorSha256 = "00avyrznhgw4zxp6z6n8zi86nsvm91iygm26401k3vp3i24ydhda";

  meta = with lib; {
    description = "Gemini server";
    homepage = "https://git.sr.ht/~yotam/shavit";
    license = licenses.agpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
