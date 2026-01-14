{
  stdenv,
  lib,
  mkWindowsApp,
  wine,
  wineArch,
  wineFlavor,
  enableVulkan ? false,
  enableMonoBootPrompt ? true,
}:
mkWindowsApp rec {
  inherit
    wine
    wineArch
    enableVulkan
    enableMonoBootPrompt
    ;

  pname = "wineshell-${wineFlavor}";
  version = "0.2.0"; # :version:

  src = ./.;

  winAppRun = ''
    echo "Welcome to wineshell, a Bash shell with an ephemeral ${wineFlavor} WINEPREFIX."
    echo "Within this Bash shell you can execute:"
    ls ${wine}/bin
    echo "winetricks"
    echo "The ephemeral WINEPREFIX is saved at $WINEPREFIX"
    echo "Once you exit this shell the WINEPREFIX will be deleted."
    bash
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Bash shell containing ${wineFlavor} with an ephemeral WINEPREFIX. Useful for running a Wine-compatible Windows program that you don't want to install.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    mainProgram = "wineshell-${wineFlavor}";
  };
}
