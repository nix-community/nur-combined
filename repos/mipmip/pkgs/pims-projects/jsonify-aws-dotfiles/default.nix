{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "jsonify-aws-dotfiles";
  version = "23fa3367707e2dbb12da31682b6725851ffc8c1f";

  src = fetchgit {
    url = "https://github.com/mipmip/jsonify-aws-dotfiles.git";
    rev = "${version}";
    hash = "";
  };

  vendorHash = "";

  meta = with lib; {
    description = ''
      Convert aws config and credential files into a single JSON object
    '';
    homepage = "https://github.com/mipmip/jsonify-aws-dotfiles";
    license = licenses.mit;
  };
}
