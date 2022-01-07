{ buildGoModule, fetchFromGitHub, lib, stdenv }:

buildGoModule {
  pname = "garlicshare";
  version = "unstable-20220104";
  src = fetchFromGitHub {
    owner = "R4yGM";
    repo = "garlicshare";
    rev = "70f6763990f17bf3994bd881871101edc0903481";
    hash = "sha256-CpyVccgeIUruL2iw1zIICRqJ39nLzvPkuurNAGR75zw=";
  };

  vendorSha256 = "KqpGAyI7//+wH6agNUZpDHjBwdT+RH2GulJWdZ1Qzdk=";

  meta = with lib; {
    description = "open source tool that lets you securely and anonymously share files on a hosted onion service using the Tor network";

    homepage = "https://r4ygm.github.io/garlicshare/";

    maintainers = with maintainers; [ lourkeur ];

    license = licenses.asl20;
  };
}
