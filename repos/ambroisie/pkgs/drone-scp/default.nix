{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "drone-scp";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "appleboy";
    repo = "drone-scp";
    rev = "v${version}";
    sha256 = "sha256-ELjPqoRR4O6gmc/PgthQuSXuSTQNzBZoAUT80zVVbV0=";
  };

  vendorSha256 = "sha256-/c103hTJ/Qdz2KTkdl/ACvAaSSTKcl1DQY3+Us6OxaI=";

  doCheck = false; # Needs a specific user...

  meta = with lib; {
    description = ''
      Copy files and artifacts via SSH using a binary, docker or Drone CI
    '';
    homepage = "https://github.com/appleboy/drone-scp";
    license = licenses.mit;
  };
}
