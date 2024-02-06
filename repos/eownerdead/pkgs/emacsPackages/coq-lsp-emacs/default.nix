{ trivialBuild, fetchFromGitHub, eglot }:
trivialBuild rec {
  pname = "coq-lsp-emacs";
  version = "master";

  src = fetchFromGitHub {
    owner = "Kaptch";
    repo = pname;
    rev = "429cfd2ead54a7e9235233df72a68baf1a823633";
    hash = "sha256-Ogf3MWKJ5E1+5IhyKzHYtVwgOK2LTmifa7u/gj02A3U==";
  };

  packageRequires = [ eglot ];
}

