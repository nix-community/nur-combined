{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "org-pretty-table";
  version = "0-unstable-2023-03-19";

  src = fetchFromGitHub {
    owner = "Fuco1";
    repo = "org-pretty-table";
    rev = "38e4354bbf7a8d08294babd067fac697038119b1";
    hash = "sha256-IeHnoB9hpISwuzI+pKiU+5wvGvz9YJrG5amGg6DGgq4=";
  };

  meta = {
    homepage = "https://github.com/Fuco1/org-pretty-table";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
