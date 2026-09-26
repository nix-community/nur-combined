{
  lib,
  fetchFromGitHub,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "rodnik";
  version = "20260907";

  src = fetchFromGitHub {
    owner = "dwcoaching";
    repo = "rodnik";
    rev = "8c47152f4ed7ef52aa44c889ffa539f65c4dc2a3";
    hash = "sha256-Vn92ywbM7MAmsMzii8aBWwnCFfL3w9GNL4lIia1l4IA=";
  };

  vendorHash = "sha256-QDolL8x/giaGME+mZ0F5lKhLRTOJN1KjXrqv+FnkxiA=";

  meta = {
    description = "Rodnik.today";
    homepage = "https://github.com/dwcoaching/rodnik";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
