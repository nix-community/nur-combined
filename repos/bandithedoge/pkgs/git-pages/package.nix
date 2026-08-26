{
  buildGoModule,
  fetchFromCodeberg,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "git-pages";
  version = "0.9.1";
  src = fetchFromCodeberg {
    owner = "git-pages";
    repo = "git-pages";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4yQ3RRJbOfMaqjJJ6CRRN7TuaYY8ScLXxMZPd4tWPwk=";
  };

  vendorHash = "sha256-NNIkzgRki2rtCVUnnhT44rEBcMZYiJPmsXySpxiHYR0=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scalable static site server for Git forges (like GitHub Pages or Netlify)";
    homepage = "https://git-pages.org";
    license = lib.licenses.bsd0;
    platforms = lib.platforms.unix;
    mainProgram = "git-pages";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
