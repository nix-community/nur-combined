{ fetchgit, stdenv, lib, darwin, ... }:

stdenv.mkDerivation rec {
  name = "pam-touchid";
  so_version = "2";

  src = fetchgit {
    url = "https://github.com/Reflejo/pam-touchID";
    rev = "757cafcadfefc7601825577f51e80d4815900367";
    sha256 = "sha256-8E2jwLHChrN1wCsejgCvnr6jgNluhiAYvkDBrZAV3M0=";
  };

  nativeBuildInputs = [ darwin.apple_sdk.frameworks.LocalAuthentication ];

  preBuild = ''
    makeFlagsArray=(DESTINATION=$out LIBRARY_NAME=pam_touchid.dylib)
  '';
  preInstall = "substituteInPlace Makefile --replace '-o root -g wheel'";
  buildPhase = "PATH=$PATH:/usr/bin make"; # FIXME: impure

  # XXX: because makeFlagsArray is useless. I don't know why
  installPhase = ''
    mkdir -p $out/lib
    install -b -m 444 pam_touchid.so $out/lib/pam_touchid.dylib.${so_version}
  '';

  meta = with lib; {
    description = "PAM plugin module that allows touch ID to be used for authentication";
    homepage = "https://github.com/Reflejo/pam-touchID";
    licenses = licenses.unlicense;
    maintainers = with maintainers; [ congee ];
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    # Well, not really. The GitHub CI just does not evaluate darwin only packages.
    broken = true;  # FIXME
  };

}
