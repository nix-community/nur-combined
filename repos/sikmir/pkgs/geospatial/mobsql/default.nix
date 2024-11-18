{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  sqlite,
}:

buildGoModule rec {
  pname = "mobsql";
  version = "0.8.3";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobsql";
    rev = "v${version}";
    hash = "sha256-p2y57z1Jt4aWNClDAcuCucpboCCCo0LmfiBmdgZfCVQ=";
  };

  vendorHash = "sha256-YqduGY9c4zRQscjqze3ZOAB8EYj+0/6V7NceRwLe3DY=";

  buildInputs = [ sqlite ];

  postInstall = ''
    mv $out/bin/{cli,mobsql}
  '';

  meta = {
    description = "GTFS to SQLite import tool";
    homepage = "https://sr.ht/~mil/mobsql";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mobsql";
    skip.ci = true;
  };
}
