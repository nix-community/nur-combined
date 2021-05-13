{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "cf-dns-updater";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "cf-dns-updater";
    rev = "v${version}";
    sha256 = "0jfg8f4xmig56v3p2a8i9dpf0lhmamk5wahzw619hplp9bpl2gjf";
  };

  vendorSha256 = "1hbi9nw9pkkp54vby4bdwfbj6ps5dbmfhmngfv6wsdl2vcx91z26";
  runVend = true;
  
  meta = with stdenv.lib; {
    description = "Gets the public IP adress from FritzBox routers and updates Cloudflare DNS records";
    homepage = "https://github.com/ouzu/cf-dns-updater";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}