{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "embgit";
  version = "0.6.3";

  src = fetchgit {
    url = "https://github.com/quiqr/embgit.git";
    rev = "${version}";
    sha256 = "sha256-8E/CQaIoeDsH61l7MEsb5QS8pMG/KM60xtkQ646otc8=";
  };

  vendorHash = "sha256-Ovzfw0hhkjhGb/ZV3Xc1ZTfD+GDJncnZ3YhXHzWmmhE=";

  meta = with lib; {
    description = ''
      Embedded Git for electron apps
    '';
    homepage = "https://github.com/quiqr/embgit";
    license = licenses.mit;
  };
}
