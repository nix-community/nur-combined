{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "obvious";
  version = "0-unstable-2023-04-07";

  src = fetchFromGitHub {
    owner = "alphapapa";
    repo = "obvious.el";
    rev = "07cb8b2d20cc6bf6d0883dbfb8f4ec4a364dbe7d";
    hash = "sha256-9MJFHmtmVlvgwjnP7l6k6LiI4b1RD9exwL+LVUPafNk=";
  };

  meta = {
    homepage = "https://github.com/alphapapa/obvious.el";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
