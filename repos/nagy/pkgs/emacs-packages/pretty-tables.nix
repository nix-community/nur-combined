{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild (finalAttrs: {
  pname = "pretty-tables";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = "pretty-tables.el";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vSjlFWM0cfrLGvo0RmVY2pr3EkjAsIxJ1Os85yjuDHE=";
  };

  meta = {
    homepage = "https://github.com/alberti42/pretty-tables.el";
    description = "Aligned, wrapped display of tables";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
