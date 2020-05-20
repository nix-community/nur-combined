{ stdenv, writeShellScriptBin, symlinkJoin, coreutils, eclipses, 
myEclipsePackages ? [ eclipses.eclipse-platform ],
logFile ? "/dev/null"
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

      ${coreutils}/bin/nohup $executable >${logFile} &
      
      sleep 0.1
    '';
in symlinkJoin {
  name = "multiEclipse";
  paths = [ startEclipse ];

  meta = with stdenv.lib; {
    descripytion = "An eclipse varaiant chooser.";
    longDescription = ''Let's you choose the eclipse variant you need before starting.'';
    homepage = "https://github.com/neumantm/nur-packages";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

