{ stdenv, fetchFromGitHub, buildGoPackage }:
buildGoPackage rec {
  name = "prosody-filer-${version}";
  version = "1.0.0-rc3";

  goPackagePath = "prosody-filer";

  src = fetchFromGitHub {
    owner = "ThomasLeister";
    repo = "prosody-filer";
    rev = "v${version}";
    sha256 = "1gb0ip95fj45amh3waslw5s9ir5ls2sjyabav8a3f5qsi4sp5xcg";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Golang mod_http_upload_external server for Prosody";
    license = licenses.mit;
    homepage = https://github.com/ThomasLeister/prosody-filer;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
