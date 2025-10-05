{
  lib,
  fetchFromGitHub,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "rodnik";
  version = "2025.08.26";

  src = fetchFromGitHub {
    owner = "dwcoaching";
    repo = "rodnik";
    rev = "07713413efe57a5cbffff21100e2597fcbf2467c";
    hash = "sha256-sxGC18GrgIm9/a0ZEtJIc8JTTRjnieuE40EiCqNoqKs=";
  };

  vendorHash = "sha256-zOFjjOYVcUuQfkqIMmbP+R+QlvjRB/8oIWeXgLoWlfw=";

  meta = {
    description = "Rodnik.today";
    homepage = "https://github.com/dwcoaching/rodnik";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
