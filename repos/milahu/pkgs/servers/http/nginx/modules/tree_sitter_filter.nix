{
  lib,
  fetchFromGitHub,
  tree-sitter,
  stdenv,
}:

rec {
  name = "ngx_tree_sitter_filter_module";
  src = fetchFromGitHub {
    owner = "milahu";
    repo = "ngx_tree_sitter_filter_module";
    rev = "f47cc05a748c416dd4c83414e17d2aff69b2f6c3";
    hash = "sha256-oSH/zKBYORfoRKSFHV08pDKSh488z8U7gX2mmjB5DLk=";
  };
  buildInputs = [ tree-sitter ];
  # --with-compat -> -DNGX_HTTP_HEADERS=1 -> enable r->headers_in.accept
  configureFlags = [ "--with-compat" ];
  meta = with lib; {
    description = "syntax highlighting for source code text files served by nginx webservers";
    homepage = "https://github.com/milahu/ngx_tree_sitter_filter_module";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
