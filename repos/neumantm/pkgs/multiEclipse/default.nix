{ stdenv, lib, makeDesktopItem, writeShellScriptBin, symlinkJoin, coreutils, eclipses,
myEclipsePackages ? [ eclipses.eclipse-platform ],
logFile ? "/dev/null",
additionalJREs ? [],
}:

let
  eclipseNames = map (package: package.name) myEclipsePackages;
  numberEclipses = builtins.length eclipseNames;
  allEclipses = builtins.concatStringsSep "\" \"" eclipseNames;

  conditionalCommands = map (package:
    ''
      if [ "$variant" == "${package.name}" ] ;then
          executable="${package}/bin/eclipse"
      fi
    ''
  ) myEclipsePackages;

  executableSelector = builtins.concatStringsSep "\n" conditionalCommands;

  printJRELines = map(package:
    ''
      echo "${package.name} : ${package}"
    ''
  ) additionalJREs;

  printJRELinesWithDescription = [
    ''
     echo "These are the additional JREs and their base path for configuring them in eclipse:"
    ''
    ] ++ printJRELines;

  additionalJREInfo = builtins.concatStringsSep "\n" printJRELinesWithDescription;

  startEclipse = writeShellScriptBin "eclipse"
    ''
      PS3="Choose (1-${toString numberEclipses}):"

      echo "Choose the variant"
      select variant in "${allEclipses}"
      do
        break
      done

      echo "You chose $variant"

      ${executableSelector}

      ${additionalJREInfo}

      ${coreutils}/bin/nohup $executable -configuration $HOME/.eclipse/eclipse-$variant/configuration >${logFile} &

      sleep 0.1
    '';
  desktopItem = makeDesktopItem {
    name = "Eclipse";
    exec = "${startEclipse}/bin/eclipse";
    icon = "eclipse";
    comment = "Integrated Development Environment";
    desktopName = "Eclipse IDE";
    genericName = "Integrated Development Environment";
    categories = ["Development"];
    terminal = true;
  };
in symlinkJoin {
  name = "multiEclipse";
  paths = [ startEclipse ];

  postBuild =
    ''
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications
      mkdir -p $out/share/pixmaps
      ln -s ${builtins.elemAt myEclipsePackages 0}/share/pixmaps/eclipse.xpm $out/share/pixmaps/eclipse.xpm
    '';

  meta = with lib; {
    descripytion = "An eclipse varaiant chooser.";
    longDescription = ''Let's you choose the eclipse variant you need before starting.'';
    homepage = "https://github.com/neumantm/nur-packages";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
