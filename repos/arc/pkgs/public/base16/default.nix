{
  base16-schemes-source = import ./source.nix {
    pname = "base16-schemes-source";
    version = "2021-04-14";
    rev = "e720724b96f77f3d63f5cfbe8f9616ddc6ea0ecb";
    sha256 = "1b64rzwdbwflhg52g9qiqf0paqa0a5m7lyh68ibxqdqqr5raj76w";
    sources = ./schemes.json;
  };
  base16-templates-source = import ./source.nix {
    pname = "base16-templates-source";
    version = "2021-04-14";
    rev = "420ca457387950d93146748e44eb4cec94d79cee";
    sha256 = "0i1bacsbyhmz3vaxrxslxbr16n5fgwgvxsikvz8p6n43k173msiw";
    sources = ./templates.json;
  };
  base16-schemes = import ./schemes.nix;
  # moved to build-support to avoid being considered a package
  #base16-templates = import ./templates.nix;
  #base16-shell-preview-arc = ./base16-shell-preview.nix;
}
