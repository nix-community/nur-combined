{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "mobsql";
  version = "0.5.0";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobsql";
    rev = "v${version}";
    hash = "sha256-OKwl9SudYUGAjR8l3y7BCSmCIuDo7IKosh02TedLvnQ=";
  };

  vendorHash = "sha256-6+rwz/7SiizixkrYnuyzpKNhhS9fFNLdce+2cCQI1J8=";

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
