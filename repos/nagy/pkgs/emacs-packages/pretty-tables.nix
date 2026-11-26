{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild (finalAttrs: {
  pname = "pretty-tables";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = "pretty-tables.el";
    tag = "v${finalAttrs.version}";
    hash = "sha256-21roj7W2wLs0M5bPHGQb5s6VHagZuRGu3/SZ/R7iDQo=";
  };

  meta = {
    homepage = "https://github.com/alberti42/pretty-tables.el";
    description = "Aligned, wrapped display of tables";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
