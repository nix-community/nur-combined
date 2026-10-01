{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.12.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gvl2xi9BqNandBDCAdIVWTa9df3fb/+CiWGTZbaEz3g=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-xL5y0R38DJiOK432d7wyNaWv69erhk7pEEmh+SRgCQM=";

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/rpiv-mono/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extensions";
    homepage = "https://github.com/juicesharp/rpiv-mono";
    downloadPage = "https://github.com/juicesharp/rpiv-mono/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
