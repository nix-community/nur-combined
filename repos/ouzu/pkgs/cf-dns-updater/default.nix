{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "cf-dns-updater";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "cf-dns-updater";
    rev = "v${version}";
    sha256 = "0jfg8f4xmig56v3p2a8i9dpf0lhmamk5wahzw619hplp9bpl2gjf";
  };

  vendorSha256 = "07jkx29c18a0bmb8nyqvi64r0gvvj59swqwdlii54r7mk4in594a";
  runVend = true;
  
  meta = with lib; {
    description = "Gets the public IP adress from FritzBox routers and updates Cloudflare DNS records";
    homepage = "https://github.com/ouzu/cf-dns-updater";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}