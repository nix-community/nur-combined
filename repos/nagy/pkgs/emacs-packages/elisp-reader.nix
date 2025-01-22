{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "elisp-reader";
  version = "0-unstable-2024-06-02";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "elisp-reader.el";
    rev = "ce4b77cbf3b74e1479a864ed51579eeafde79062";
    hash = "sha256-J8jTorny1MkbltuOKMtjDcMzKoJjMv+LideSWVX2ehg=";
  };

  preBuild = ''
    rm -f tmp.el
  '';

  meta = {
    homepage = "https://github.com/mishoo/elisp-reader.el";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
