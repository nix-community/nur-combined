{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "cf-dns-updater";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "cf-dns-updater";
    rev = "v${version}";
    sha256 = "1hjz4c4jp6axvbqbq0knpqcz6x90nzfaf0hb4ajlg9rn0fb80yj3";
  };

  vendorSha256 = "11lq6mmvfa1yyqxaixgc1zzs6b3cr8ykzrgzdl5diwm2mn9zggc5";
  
  meta = with lib; {
    description = "Gets the public IP adress from FritzBox routers and updates Cloudflare DNS records";
    homepage = "https://github.com/ouzu/cf-dns-updater";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}