{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "mobsql";
  version = "0.6.0";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobsql";
    rev = "v${version}";
    hash = "sha256-jPx/We8a1L9hLDgxxg/pAfBkbT+cl7l8EmruYZ4maug=";
  };

  vendorHash = "sha256-YqduGY9c4zRQscjqze3ZOAB8EYj+0/6V7NceRwLe3DY=";

  postInstall = ''
    mv $out/bin/{cli,mobsql}
  '';

  meta = {
    description = "GTFS to SQLite import tool";
    homepage = "https://sr.ht/~mil/mobsql";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mobsql";
  };
}
