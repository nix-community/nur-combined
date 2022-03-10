
/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
./result/bin/subtitleedit
*/

# status: broken. build error:
# NETSDK1064: Package UTF.Unknown, version 2.5.0 was not found

{ lib
, stdenv
, fetchFromGitHub
, buildDotnetPackage
, dotnetPackages
, msbuild
, dotnet-sdk
, fetchNuGet
, strace
, mono4
, callPackage
}:

let

  # Microsoft.Win32.Registry https://retkomma.wordpress.com/2011/10/01/registry-settings-in-mono-on-linux/

  NHunspell = fetchNuGet rec {
    pname = "NHunspell";
    baseName = pname; # legacy
    version = "1.2.5554.16953";
    sha256 = "7XerlnjFQCFehsIITYqYNyJQl/TJ0FZy571+ihEZBTk=";
    #postUnpack = ''find . -type f'';
    outputFiles = [ "*" ];
  };

  # error NETSDK1064: Package UTF.Unknown, version 2.5.0 was not found.
  UTF.Unknown = fetchNuGet rec {
    pname = "UTF.Unknown";
    baseName = pname; # legacy
    version = "2.5.0";
    sha256 = "EYnSj6FRrxdfpFVh72NOhG8i9m1pb8yaWyy3TXyHj/Q=";
    #postUnpack = ''find . -type f'';
    #outputFiles = [ "lib/*" ];
    outputFiles = [ "*" ];
  };

  Microsoft.Bcl.Build = fetchNuGet rec {
    pname = "Microsoft.Bcl.Build";
    baseName = pname; # legacy
    version = "1.0.21";
    sha256 = "V2oqSu0y7yPzhxKhDzuMcQfNjWOZiuypt1RC1XmEQ+4=";
    #postUnpack = ''find . -type f'';
    #outputFiles = [ "lib/*" ];
    outputFiles = [ "*" ];
  };

  Microsoft.Win32.Registry = fetchNuGet rec {
    pname = "Microsoft.Win32.Registry";
    baseName = pname; # legacy
    version = "5.0.0";
    sha256 = "9kylPGfKZc58yFqNKa77stomcoNnMeERXozWJzDcUIA=";
    #postUnpack = ''find . -type f'';
    #outputFiles = [ "lib/*" ];
    outputFiles = [ "*" ];
  };
  /* should use mono facade
    /nix/store/gar7iq0ylvaikn7z5i61qip1ci4lvs3i-mono-6.12.0.122/lib/mono/4.5/Facades/Microsoft.Win32.Registry.AccessControl.dll
    /nix/store/gar7iq0ylvaikn7z5i61qip1ci4lvs3i-mono-6.12.0.122/lib/mono/4.5/Facades/Microsoft.Win32.Registry.dll
    /nix/store/gar7iq0ylvaikn7z5i61qip1ci4lvs3i-mono-6.12.0.122/lib/mono/4.5/Facades/Microsoft.Win32.Registry.AccessControl.pdb
  */

  Vosk = fetchNuGet rec {
    pname = "Vosk";
    baseName = pname; # legacy
    version = "0.3.32";
    sha256 = "HpxydQwvxExNudOuNtQqsvEHIpuFLDLlfgtT/G2bETA=";
    #postUnpack = ''find . -type f'';
    #outputFiles = [ "lib/*" ];
    outputFiles = [ "*" ];
  };

  ncalc = fetchNuGet rec {
    pname = "ncalc";
    baseName = pname; # legacy
    version = "1.3.8";
    sha256 = "AKVHpvMsbPqyAGf+ba/DQY/USoFpMrqdaYhl2iVrhCE=";
    #postUnpack = ''find . -type f'';
    #outputFiles = [ "lib/*" ];
    outputFiles = [ "*" ];
  };

  Newtonsoft.Json = fetchNuGet rec {
    pname = "Newtonsoft.Json";
    baseName = pname; # legacy
    version = "13.0.1";
    sha256 = "K2tSVW4n4beRPzPu3rlVaBEMdGvWSv/3Q1fxaDh4Mjo=";
    outputFiles = [ "*" ];
  };
  # /nix/store/pm6il5m5i0jqscz1x4hz1jqxvpw0qrhn-msbuild-16.10.1+xamarinxplat.2021.05.26.14.00/lib/mono/msbuild/Current/bin/Newtonsoft.Json.dll

  Microsoft.Net.Http = fetchNuGet rec {
    pname = "Microsoft.Net.Http";
    baseName = pname; # legacy
    version = "2.2.29";
    sha256 = "v04J/yG2BG249iVnf1JBD28FGWUoTMlLmiLjVoao+XA=";
    outputFiles = [ "*" ];
  };

in

buildDotnetPackage rec {

  pname = "subtitleedit";
  baseName = pname; # legacy
  version = "3.6.4";
  src = fetchFromGitHub {
    owner = "SubtitleEdit";
    repo = "subtitleedit";
    rev = version;
    sha256 = "5EW9qPSVbKRpWy2oR1zailECStWRYnzzGO6rxIRctN0=";
  };

  #projectFile = "SubtitleEdit.sln";
    # build all projects
    # ./src/UpdateResourceScript/UpdateResourceScript.csproj
    # ./src/UpdateLanguageFiles/UpdateLanguageFiles.csproj
    # ./src/ui/SubtitleEdit.csproj
    # ./src/libse/LibSE.csproj
    # ./src/UpdateAssemblyInfo/UpdateAssemblyInfo.csproj
    # ./src/Test/Test.csproj
  projectFile = "src/ui/SubtitleEdit.csproj";

  propagatedBuildInputs = [
  ];
  buildInputs = [
    #dotnetPackages.NUnit
    #dotnetPackages.NUnitRunners
    #dotnetPackages.Nuget
    msbuild
    #dotnet-sdk
    #strace
  ];

  # patch *.csproj files
  # project.assets.json -> fix: error NETSDK1004: Assets file '/build/source/src/libse/obj/project.assets.json' not found. Run a NuGet package restore to generate this file. [/build/source/src/libse/LibSE.csproj]
  postUnpack = ''
    (
      cd $sourceRoot

      if true
      then
        cp -v ${./SubtitleEdit.csproj} src/ui/SubtitleEdit.csproj
        cp -v ${./Test.csproj} src/Test/Test.csproj
        cp -v ${./LibSE.csproj} src/libse/LibSE.csproj
      fi

      if true
      then
        mkdir src/libse/obj
        cp -v ${./project.assets.json} src/libse/obj/project.assets.json
      fi
    )
  '';

  # error NETSDK1004: Assets file '/build/source/src/libse/obj/project.assets.json' not found. Run a NuGet package restore to generate this file. [/build/source/src/libse/LibSE.csproj]
  # -> add msbuild flag: /restore
  #    access denied
  #    -> add: export HOME=/tmp
  #    problem: /restore only works online
  #    -> run "msbuild /restore" in a nix-shell
  #    the *.csproj files need some patching, e.g. dont run *.bat scripts
  /*
    cp ../../SubtitleEdit.csproj src/ui/SubtitleEdit.csproj
    cp ../../Test.csproj src/Test/Test.csproj
    cp ../../LibSE.csproj src/libse/LibSE.csproj 
    msbuild /restore /p:Configuration=Release SubtitleEdit.sln
    cp src/libse/obj/project.assets.json ../../project.assets.json
  */
  #    -> copy project.assets.json

  # FIXME? It was not possible to find any installed .NET SDKs.

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/dotnet-packages.nix
  # emulate `nuget restore Source/Boogie.sln`
  # which installs in $srcdir/Source/packages
  #  preBuild = ''
  #    mkdir -p Source/packages/NUnit.2.6.3
  #    ln -sn ${dotnetPackages.NUnit}/lib/dotnet/NUnit Source/packages/NUnit.2.6.3/lib
  #  '';

  # error NETSDK1064: Package Microsoft.Win32.Registry, version 5.0.0 was not found.
  # -> Microsoft.Win32.Registry: should use facade by mono
  # -> remove Microsoft.Win32.Registry from subtitleedit/src/libse/LibSE.csproj
  # -> ok?

  # error NETSDK1064: Package System.Drawing.Common, version 5.0.2 was not found.
  # -> remove System.Drawing.Common from subtitleedit/src/libse/LibSE.csproj
  # -> ok?

  # error NETSDK1064: Package UTF.Unknown, version 2.5.0 was not found.
  # strace: nothing :(

  preBuild = ''

    (
      set -x
      export HOME=/tmp
      pwd # /build/source

      nuget locals all -list

      for d in .
      #$HOME/.nuget src src/libse src/libse/obj
      do
        mkdir -p $d/packages

        ln -s -v ${UTF.Unknown}/lib/dotnet/UTF.Unknown $d/packages/UTF.Unknown.${UTF.Unknown.version}
        mkdir $d/packages/UTF.Unknown
        ln -s -v ${UTF.Unknown}/lib/dotnet/UTF.Unknown $d/packages/UTF.Unknown/${UTF.Unknown.version}
        mkdir $d/packages/utf.unknown
        ln -s -v ${UTF.Unknown}/lib/dotnet/UTF.Unknown $d/packages/utf.unknown/${UTF.Unknown.version}

        ln -s -v ${Microsoft.Bcl.Build}/lib/dotnet/Microsoft.Bcl.Build $d/packages/Microsoft.Bcl.Build.${Microsoft.Bcl.Build.version}
        ln -s -v ${Vosk}/lib/dotnet/Vosk $d/packages/Vosk.${Vosk.version}
        ln -s -v ${NHunspell}//lib/dotnet/NHunspell $d/packages/NHunspell.${NHunspell.version}
        ln -s -v ${ncalc}//lib/dotnet/ncalc $d/packages/ncalc.${ncalc.version}
        ln -s -v ${Newtonsoft.Json}//lib/dotnet/Newtonsoft.Json $d/packages/Newtonsoft.Json.${Newtonsoft.Json.version}
        ln -s -v ${Microsoft.Net.Http}//lib/dotnet/Microsoft.Net.Http $d/packages/Microsoft.Net.Http.${Microsoft.Net.Http.version}
      done

      sed 's/\[REVNO\]/${REVNO}/g; s/\[GITHASH\]/${GITHASH}/g' <src/ui/Properties/AssemblyInfo.cs.template >src/ui/Properties/AssemblyInfo.cs
      sed 's/\[REVNO\]/${REVNO}/g; s/\[GITHASH\]/${GITHASH}/g' <src/libse/Properties/AssemblyInfo.cs.template >src/libse/Properties/AssemblyInfo.cs
    )

  '';

  GITHASH = "0000000";
  REVNO = "0000";

  # error NETSDK1064: Package System.Drawing.Common, version 5.0.2 was not found.
  # https://www.mono-project.com/docs/gui/drawing/

  buildPhase = ''
    export HOME=/tmp # needed for /restore
    runHook preBuild

    #strace -ff # not helpful
    msbuild /p:Configuration=Release ${projectFile}
    # /restore
    # -verbosity:diagnostic # not helpful

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/SubtitleEdit/subtitleedit";
    description = "the subtitle editor :)";
    license = licenses.gpl3;
  };
}
