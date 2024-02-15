{lib, stdenv, buildGoModule, fetchFromGitHub, makeWrapper, tor }:

buildGoModule {
  pname = "garlicshare";
  version = "unstable-20220107";
  src = fetchFromGitHub {
    owner = "R4yGM";
    repo = "garlicshare";
    rev = "cb0523a5adbd82ea789200ca5c04c5f390f6583a";
    hash = "sha256-T7cV/y0pci2QzDtE0PlwvhQXHf9vIbQCQTgSI7SaQWk=";
  };

  vendorSha256 = "KqpGAyI7//+wH6agNUZpDHjBwdT+RH2GulJWdZ1Qzdk=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/garlicshare --prefix PATH : ${tor}/bin
    '';

  meta = with lib; {
    description = "open source tool that lets you securely and anonymously share files on a hosted onion service using the Tor network";

    homepage = "https://r4ygm.github.io/garlicshare/";

    maintainers = with maintainers; [ lourkeur ];

    license = licenses.asl20;
  };
}
