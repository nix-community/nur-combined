{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "saait";
  version = "0.8";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    tag = finalAttrs.version;
    hash = "sha256-W86JAYUsyvOWt/YTqXfqMA/CwQq7uVIV1F6+AeRB/8s=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "The most boring static page generator";
    homepage = "https://git.codemadness.org/saait/file/README.html";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
