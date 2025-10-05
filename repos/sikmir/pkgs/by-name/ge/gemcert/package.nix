{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule {
  pname = "gemcert";
  version = "2020-08-01";

  src = fetchFromSourcehut {
    owner = "~solderpunk";
    repo = "gemcert";
    rev = "fc14deb2751274d2df01f8d5abef023ec7e12a8c";
    hash = "sha256-za3pS6WlOJ+NKqhyCfhlj7gH4U5yFXtJ6gLta7WXhb0=";
  };

  patches = [ ./go.mod.patch ];

  vendorHash = null;

  meta = {
    description = "A simple tool for creating self-signed certs for use in Geminispace";
    homepage = "https://git.sr.ht/~solderpunk/gemcert";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "gemcert";
  };
}
