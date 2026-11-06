{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "cern-httpd";
  version = "0.2-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "cern-httpd";
    rev = "8ef4e53b69be6c50982b4c89635107b2beaa5189";
    hash = "sha256-1igOQijEw4fvAmdygJRTG98s4mj7ZcgJOySS1leeTOY=";
  };

  # The Makefile builds the two servers into build/.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/cern-httpd $out/share/doc/cern-httpd
    install -m755 build/daemon $out/bin/cern-httpd
    install -m755 build/tcp_daemon $out/bin/cern-tcp-daemon
    cp -R htdocs $out/share/cern-httpd/
    cp NOTICE README.md $out/share/doc/cern-httpd/
    runHook postInstall
  '';

  meta = {
    description = "Tim Berners-Lee's early CERN web servers, ported to modern systems";
    homepage = "https://github.com/lillycham/cern-httpd";
    # CERN put the basic server in the public domain in 1993; see NOTICE.
    license = lib.licenses.publicDomain;
    mainProgram = "cern-httpd";
    # Only macOS has been tried.
    platforms = lib.platforms.darwin;
  };
}
