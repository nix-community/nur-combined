{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ts3exporter";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "hikhvar";
    repo = "ts3exporter";
    rev = "v${version}";
    sha256 = "05vcc4sdv9i5wpg0km1ir28z1l55xmiwnh10dc6fw72r60hmvqbj";
  };

  vendorSha256 = "15jzxm4yviv1pjhb9zjmy0zccn28qcdwsk1pkx3x8yl0h2hdxpgf";
  
  meta = with lib; {
    description = "Teamspeak 3 exporter for prometheus ";
    homepage = "https://github.com/hikhvar/ts3exporter";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}