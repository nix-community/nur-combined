{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule {
  pname = "shavit";
  version = "0-unstable-2020-03-14";

  src = fetchFromSourcehut {
    owner = "~yotam";
    repo = "shavit";
    rev = "129b3e7fc700d02843c4fbd3e7cc73bf714f9cc2";
    hash = "sha256-LEI7cJkyLPVtkplbRwGFHKXiKiiMerE9EDgQ0vWL4Qk=";
  };

  vendorHash = "sha256-qsHmiYjj7jEDIEbU52NIdWtrUPzImm9u/4Q/aH/2WwE=";

  meta = {
    description = "Gemini server";
    homepage = "https://git.sr.ht/~yotam/shavit";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
