{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ts3exporter";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "hikhvar";
    repo = "ts3exporter";
    rev = "v${version}";
    sha256 = "05vcc4sdv9i5wpg0km1ir28z1l55xmiwnh10dc6fw72r60hmvqbj";
  };

  vendorSha256 = "18xjfbwmnz2104pnh5vr36m2b61n50y4aa2zbvhbbw8af2ibmgci";
  runVend = true;
  
  meta = with stdenv.lib; {
    description = "Teamspeak 3 exporter for prometheus ";
    homepage = "https://github.com/hikhvar/ts3exporter";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}