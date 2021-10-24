{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "smug";
  version = "0.2.4";

  src = fetchgit {
    url = "https://github.com/ivaaaan/smug.git";
    rev = "v${version}";
    sha256 = "sha256:1x2v4mv17m3937qhdar38yg43ay725rxvgcqpynh664x1hd3q2rd";
  };

  vendorSha256 = "sha256:1rba5rpvlr8dyhj145b5i57pm4skfpj3vm7vydkn79k6ak6x985x";

  meta = with lib; {
    description = ''
      Session manager for tmux written in Go
    '';
    homepage = "https://github.com/ivaaaan/smug";
    license = licenses.mit;
  };
}
