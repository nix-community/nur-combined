{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "jsonify-aws-dotfiles";
  version = "4c60e320b23ee0fae085cfce0b13d3753e39e73e";

  src = fetchgit {
    url = "https://github.com/wearetechnative/jsonify-aws-dotfiles.git";
    rev = "${version}";
    hash = "sha256-sL1kpWyAVLxoQRJa+m7XSIaM0kxhmE1kOLpnTZVQwB0=";
  };

  vendorHash = "sha256-W6XVd68MS0ungMgam8jefYMVhyiN6/DB+bliFzs2rdk=";

  meta = with lib; {
    description = ''
      Convert aws config and credential files into a single JSON object
    '';
    homepage = "https://github.com/mipmip/jsonify-aws-dotfiles";
    license = licenses.mit;
  };
}
