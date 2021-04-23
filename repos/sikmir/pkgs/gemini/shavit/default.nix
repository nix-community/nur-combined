{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "shavit";
  version = "2020-03-14";

  src = fetchFromSourcehut {
    owner = "~yotam";
    repo = pname;
    rev = "129b3e7fc700d02843c4fbd3e7cc73bf714f9cc2";
    hash = "sha256-LEI7cJkyLPVtkplbRwGFHKXiKiiMerE9EDgQ0vWL4Qk=";
  };

  vendorSha256 = "00avyrznhgw4zxp6z6n8zi86nsvm91iygm26401k3vp3i24ydhda";

  meta = with lib; {
    description = "Gemini server";
    inherit (src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
