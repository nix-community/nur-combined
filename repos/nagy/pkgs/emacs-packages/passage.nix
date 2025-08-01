{
  lib,
  melpaBuild,
  fetchFromGitHub,
  ht,
  with-editor,
  s,
  f,
  age,
}:

melpaBuild {
  pname = "passage";
  version = "0-unstable-2025-02-28";

  src = fetchFromGitHub {
    owner = "anticomputer";
    repo = "passage.el";
    rev = "e7385ecbb6aa857a799424d7838bd93624fa2d9c";
    hash = "sha256-x73D5BXdDgIMQFSatv/4v5Ld9NdQx4cANblNs6RarzE=";
  };

  packageRequires = [
    ht
    with-editor
    s
    f
    age
  ];

  meta = {
    homepage = "https://github.com/anticomputer/passage.el";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
