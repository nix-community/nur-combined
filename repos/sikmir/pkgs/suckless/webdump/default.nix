{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webdump";
  version = "0-unstable-2024-07-06";

  src = fetchgit {
    url = "git://git.codemadness.org/webdump";
    rev = "5cde25b5150bd0375e9b5800bf3855765830c588";
    hash = "sha256-holkUH9ImpcVVJo429jq9BqB6YRpqifQBmbUrD6TzgU=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "HTML to plain-text converter for webpages";
    homepage = "https://git.codemadness.org/webdump/file/README.html";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
