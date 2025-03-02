{
  stdenv,
  lib,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  scdoc,
  dbus,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "mpris-ctl";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "mariusor";
    repo = "mpris-ctl";
    rev = "v${version}";
    hash = "sha256-o/E6TJuEm5eHYeTEPyi8l8Y5j0y08oXGv3XaxxydpRU=";
  };

  nativeBuildInputs = [
    pkg-config
    scdoc
    installShellFiles
  ];

  buildInputs = [ dbus ];

  buildPhase = ''
    runHook preBuild

    make VERSION="${version}" release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    scdoc < mpris-ctl.1.scd > mpris-ctl.1
    installManPage mpris-ctl.1
    install -D mpris-ctl $out/bin/mpris-ctl

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Basic mpris player control for linux command line";
    homepage = "https://github.com/mariusor/mpris-ctl";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "mpris-ctl";
  };
}
