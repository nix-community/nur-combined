{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "moar-pager"; # not to be confused with moarvm 
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "walles";
    repo = "moar";
    rev = "v${version}";
    sha256 = "sha256-5IJzGm32Uo+x2b+yWmmWXT5uxPQmii6SCXti2QDHkqc=";
  };

  vendorSha256 = "sha256-6I4TUQVtz6TQPgKLSuyVfwZJfrVSn+APGEGMYJFeEn4=";

  ldflags = [
    "-s" "-w"
    "-X main.versionString=${version}"
  ];

  # tests cannot find the sample files dir
  doCheck = false;

  meta = {
    description = "A terminal pager";
    homepage = "https://github.com/walles/moar";
    license = "BSD-2-Clause-FreeBSD";
  };
}