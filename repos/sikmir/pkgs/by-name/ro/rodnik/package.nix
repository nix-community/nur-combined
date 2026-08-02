{
  lib,
  fetchFromGitHub,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "rodnik";
  version = "0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "dwcoaching";
    repo = "rodnik";
    rev = "49a7788d0cce5715d1c7627a42931b6c1e1c29f1";
    hash = "sha256-otbUr3r6yxevJGyfdHSYLPNzmZqaJuogyrWCBxzc/C8=";
  };

  vendorHash = "sha256-HzZgD40QIg+cv/wxZnMJxhh0VULZGNR/JLa7aAWtRM4=";

  meta = {
    description = "Rodnik.today";
    homepage = "https://github.com/dwcoaching/rodnik";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
