{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "narumitw-pi-extensions";
  version = "0-unstable-2026-08-28";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    rev = "f576de3c88815f5136a757f96732282808cf3c7f";
    hash = "sha256-ez8aW3KTPLNARc4QSUCMp6D6STdlytkpCiSwze+hzjY=";
  };

  patches = [ ./package.json.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Y+lZiEyfz7l1qIRKX38y4YMMvSvqLht6IjUQkSDtkAE=";

  postInstall = ''
    cp -r $out/lib/node_modules/pi-extensions/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extensions and reusable extension libraries";
    homepage = "https://github.com/narumiruna/pi-extensions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
