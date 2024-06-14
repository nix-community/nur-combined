{ lib
, fetchFromGitHub
, makeWrapper
, stdenv

# Dependencies
, ios-webkit-debug-proxy
, python3
}:

let
  inherit (builtins) toFile;
in
stdenv.mkDerivation {
  pname = "ios-safari-remote-debug-kit";
  version = "0-unstable-2022-06-21";

  src = fetchFromGitHub {
    owner = "HimbeersaftLP";
    repo = "ios-safari-remote-debug-kit";
    rev = "bfa15e76ec1c52caccf97ad1e0b5beaf1a1bea1a";
    hash = "sha256-eBNljVJxTi9kCXXzHC60eKuTRXsILJyLO4PlOklEyYo=";
  };

  webkitSrc = fetchFromGitHub {
    owner = "WebKit";
    repo = "WebKit";
    rev = "WebKit-7615.1.3.1";
    sparseCheckout = "Source/WebInspectorUI/UserInterface";
    hash = "sha256-hZR/MAnE5E5Z1yzo8LGTZ2bi/jkX3vlFKr24/NLCgNs=";
  };

  postUnpack = ''
    cp --no-preserve=mode --recursive --reflink=auto \
      $webkitSrc $sourceRoot/src/WebKit
  '';

  patches = [
    (toFile "disable-fetch.patch" ''
      --- a/src/generate.sh
      +++ b/src/generate.sh
      @@ -9,11 +8,0 @@
      -if [ -d "WebKit" ]; then
      -  echo "WebKit folder already exists!"
      -  echo "Delete it if you want to update your installation."
      -  read -p "Press enter to close this window!"
      -  exit
      -fi
      -
      -echo "Downloading original WebInspector"
      -svn checkout \
      -  https://svn.webkit.org/repository/webkit/trunk/Source/WebInspectorUI/UserInterface \
      -  WebKit/Source/WebInspectorUI/UserInterface
    '')

    (toFile "disable-interactive.patch" ''
      --- a/src/generate.sh
      +++ b/src/generate.sh
      @@ -46 +41,0 @@
      -read -p "Press enter to close this window!"
      \ No newline at end of file
    '')

    (toFile "disable-legacy-protocol" ''
      --- a/src/generate.sh
      +++ b/src/generate.sh
      @@ -37,7 +26,0 @@
      -echo "Copying InspectorBackendCommands.js for the latest version"
      -protocolPath="WebKit/Source/WebInspectorUI/UserInterface/Protocol"
      -legacyPath="$protocolPath/Legacy/iOS"
      -versionFolder="$(ls -1 $legacyPath | sort | tail -n 1)"
      -backendCommandsFile="$legacyPath/$versionFolder/InspectorBackendCommands.js"
      -echo "  -> Choosing file $backendCommandsFile"
      -cp $backendCommandsFile $protocolPath
    '')

    (toFile "enable-strict.patch" ''
      --- a/src/generate.sh
      +++ b/src/generate.sh
      @@ -1,2 +1,3 @@
       #!/bin/bash
      +set -eu
       
    '')

    (toFile "fix-proxy-command.patch" ''
      --- a/src/start.sh
      +++ b/src/start.sh
      @@ -16 +16 @@
      -DEBUG_PROXY_EXE="ios-webkit-debug-proxy"
      +DEBUG_PROXY_EXE="ios_webkit_debug_proxy"
    '')
  ];

  postPatch = ''
    chmod +x src/{generate,start}.sh
    patchShebangs src/generate.sh
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = "./src/generate.sh";

  installPhase = ''
    install -D -t $out src/start.sh
    makeWrapper $out/start.sh $out/bin/ios-safari-remote-debug-kit \
      --prefix PATH : ${lib.makeBinPath [ ios-webkit-debug-proxy python3 ]}

    cp --reflink=auto --recursive --target-directory $out src/WebKit
  '';

  meta = {
    description = "Remote debugging of iOS Safari";
    homepage = "https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit";
    license = lib.licenses.gpl3;
  };
}
