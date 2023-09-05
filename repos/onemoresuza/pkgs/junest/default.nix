{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
  wget,
  bash,
  coreutils,
  bubblewrap,
  proot,
}:
stdenvNoCC.mkDerivation rec {
  pname = "junest";
  version = "7.4.7";
  src = fetchFromGitHub {
    owner = "fsquillace";
    repo = pname;
    rev = version;
    hash = "sha256-ln912blkn0mlXHHSJ2QENZXCpmV0WZWEiWpuelYnuco=";
  };

  doBuild = false;

  installPhase = ''
    runHook preInstall

    install -d "$out/"{opt/junest,bin}
    cp -r lib/ bin/ "$out/opt/junest"
    ln -s "../opt/junest/bin/junest" "$out/bin/junest"
    ln -s "../opt/junest/bin/sudoj" "$out/bin/sudoj"

    runHook postInstall
  '';

  wrapperPath = lib.makeBinPath [
    wget
    bash
    coreutils
    bubblewrap
    proot
  ];

  postFixUp = ''
    wrapProgram "$out/bin/junest" \
      --prefix "PATH" ":" "${wrapperPath}"
  '';

  meta = with lib; {
    description = "A lightweight Arch Linux based distro";
    longDescription = ''
      JuNest (Jailed User Nest) is a lightweight Arch Linux based distribution that allows the
      creation of disposable and partially isolated GNU/Linux environments within any generic
      GNU/Linux host OS and without requiring root privileges to install packages.
    '';
    homepage = "https://github.com/fsquillace/junest/";
    license = licenses.gpl3;
    mainProgram = "junest";
  };
}
