{ pkgs, tree-sitter }:
let
  neovimPackage = { name, tag, sha256 }:
    (pkgs.neovim-unwrapped.overrideAttrs (attrs: {
      pname = "neovim";
      version = "${tag}";
      # TODO: Fix this if `tree-sitter` is updated
      # nativeBuildInputs = attrs.nativeBuildInputs ++ [ tree-sitter ];
      src = pkgs.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "${tag}";
        inherit sha256;
      };
    }));
in {
  # TODO: Enable once tree-sitter is updated
  #nightly = neovimPackage {
    #name = "nightly";
    #tag = "nightly";
    #sha256 = "sha256-hHpsZYdVwE9tW0WVee3Y55lrrYQYsT+hGH+3MJrspCg=";
  #};

  stable = neovimPackage {
    name = "stable";
    tag = "stable";
    sha256 = "sha256-VTijhD+Cncpr1eQ9e174ATlp5h1yssCNHVrxuaWR/oc=";
  };
}
