{ stdenv
, lib
, fetchzip
, steam-run
# , zlib
# , autoPatchelfHook
}:

# TODO: Shouldn't need the whole steam-run FHS env.
# Adding autoPatchelfHook and zlib lets it build and run,
# but pygame errors out with "error: No available video device".
# It may be more practical to just create a version built from source.

stdenv.mkDerivation rec {
  pname = "digitalalovestory-bin";
  version = "1.1";

  src = fetchzip {
    url = "https://www.scoutshonour.com/lilyofthevalley/digital-1.1.tar.bz2";
    sha256 = "+7KcZ8dKts1AoKWNfHMKIt+w2fBFIAcnkuAtzSw49xk=";
  };

  # nativeBuildInputs = [
  #   autoPatchelfHook
  # ];

  buildInputs = [
    steam-run
  #   zlib
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # copy distributed files
    mkdir -p $out/opt/Digital-linux-x86
    cp -R source/* $out/opt/Digital-linux-x86

    # patch paths in entrypoint
    sed -i "s#\`dirname \\\\\\\"\$0\\\\\\\"\`#$out/opt/Digital-linux-x86#g" $out/opt/Digital-linux-x86/Digital.sh
    sed -i "s#\''${0%\\.sh}#$out/opt/Digital-linux-x86/Digital#g" $out/opt/Digital-linux-x86/Digital.sh
    sed -i "s#dir=.*#dir=$out/opt/Digital-linux-x86#g" $out/opt/Digital-linux-x86/Digital.sh
    sed -i 's/base=.*/base=Digital.sh/g' $out/opt/Digital-linux-x86/Digital.sh

    # wrap in steam-run
    sed -i 's#exec#exec "${steam-run}/bin/steam-run"#g' $out/opt/Digital-linux-x86/Digital.sh

    # link entrypoint to bin directory
    mkdir -p $out/bin
    ln -s $out/opt/Digital-linux-x86/Digital.sh $out/bin/Digital

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://scoutshonour.com/digital/";
    description = "Digital: A Love Story, a freeware game by Christine Love";
    license = licenses.cc-by-nc-sa-30;
    platforms = lists.intersectLists platforms.x86 platforms.linux;
  };
}
