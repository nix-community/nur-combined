{ stdenv, fetchFromGitHub, buildGoModule }:
with stdenv.lib;

let
  pname = "sfg";
  version = "0.2";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "pniedzwiedzinski";
    repo = "simple-feed-gen";
    rev = "v${version}";
    sha256 = "0h0wfq9fwls08kf8gyhxmzmrb77kkmbn6hp17q8lqcr810f9dk90";
  };

  vendorSha256 = "1b3ra7p666vjnf7hm1pjm1y852i89jpzyf6j9id19js1133jqz3p";

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sfg $out/bin
  '';

  meta = {
    description = "Tool for generating basic atom feeds from .gmi files. And nothing more.";
    homepage = "https://github.com/pniedzwiedzinski/simple-feed-gen";
    license = "MIT";
    platforms = platforms.linux;
  };
}
