{ stdenv, lib, fetchgit, makeWrapper, firefox, gnome }:

stdenv.mkDerivation {
  pname = "multifirefox";
  version = "unstable-2016-05-10";

  src = fetchgit {
    url = "https://gist.github.com/c44d6ca8ac76333ca4a2";
    rev = "f71167ad2e35a2bb2166047e5ecfd7c0a5ea17ad";
    sha256 = "sha256-Bix4S/MUW5MzAA0/xyO63EpFAzLGRtwJ3sJYwl4ahT4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 multifirefox -t $out/opt/multifirefox
    install -Dm644 multifirefox.desktop -t $out/share/applications

    cp -R ${firefox}/share/icons $out/share/
    makeWrapper $out/opt/multifirefox/multifirefox \
      $out/bin/multifirefox \
      --prefix PATH : "${lib.makeBinPath [ firefox gnome.zenity ]}"
    substituteInPlace $out/share/applications/multifirefox.desktop \
      --replace "/usr/bin/env " "$out/bin/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Equivalent of `firefox -P PROFILE_NAME -no-remote` but with the remote enabled";
    homepage = "https://codeberg.org/wolfangaukang/multifirefox";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.linux;
  };
}
