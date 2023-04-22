{ fetchFromGitHub
, lib
, nodejs
, stdenv
, callPackage
, gnused
}:
let
  nodeDependencies = (callPackage ./etherpad { }).nodeDependencies;
in
stdenv.mkDerivation rec {
  pname = "etherpad";
  version = "1.8.18";

  src = fetchFromGitHub {
    owner = "ether";
    repo = "etherpad-lite";
    rev = version;
    sha256 = "sha256-FziTdHmZ7DgWlSd7AhRdZioQNEPmiGZFHjc8pwnpKIo=";
  };

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./src/node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
  '';

  installPhase = ''
    mkdir $out
    cp ./* $out -r

    mv $out/bin/fastRun.sh $out/bin/etherpad
    sed -i "s#^cd .*#cd $out/#g" $out/bin/etherpad
    chmod +x $out/bin/etherpad
  '';


  meta = with lib; {
    description = "a highly customizable open source online editor providing collaborative editing in really real-time";
    longDescription = ''
      Etherpad is a highly customizable open source online editor providing collaborative editing in really real-time.

      Etherpad allows you to edit documents collaboratively in real-time, much like a live multi-player editor that runs in your browser. Write articles, press releases, to-do lists, etc. together with your friends, fellow students or colleagues, all working on the same document at the same time.

      All instances provide access to all data through a well-documented API and support import/export to many major data exchange formats. And if the built-in feature set isn't enough for you, there's tons of plugins that allow you to customize your instance to suit your needs.
    '';
    homepage = "https://etherpad.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ minion3665 ];
    broken = true;
  };
}
