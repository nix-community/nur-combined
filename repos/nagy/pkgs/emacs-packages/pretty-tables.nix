{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild (finalAttrs: {
  pname = "pretty-tables";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "alberti42";
    repo = "pretty-tables.el";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j1lNE/eTMeIdKDlyXv2p2FFLM5yK+B4YvVZxQJQUASQ=";
  };

  meta = {
    homepage = "https://github.com/alberti42/pretty-tables.el";
    description = "Aligned, wrapped display of tables";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
