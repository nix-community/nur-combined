{
  lib,
  stdenv,
  Foundation,
  IOKit,
}:
stdenv.mkDerivation rec {
  pname = "sleepwatcher";
  version = "2.2.1";

  src = fetchTarball {
    url = "https://www.bernhard-baehr.de/sleepwatcher_2.2.1.tgz";
    sha256 = "0kjrf9lriciw9wf9qk5p33gnj5zj715vkvnaqzv5pld2r3akhj4i";
  };

  preferLocalBuild = true;
  dontConfigure = true;

  buildInputs = [IOKit Foundation];

  env.NIX_CFLAGS_COMPILE = toString [
    "-O3"
    "-mmacosx-version-min=10.13"
    "-framework IOKit"
    "-framework CoreFoundation"
  ];

  buildPhase = ''
    runHook preBuild

    $CC -o sleepwatcher $src/sources/sleepwatcher.c

    runHook postBuild
  '';

  postBuild = ''
    substituteInPlace config/*.plist \
      --replace "/usr/local/sbin" "$out/bin" \
      --replace "/etc/rc" "$out/bin/rc"
  '';

  installPhase = ''
    install -Dm755 sleepwatcher $out/bin/sleepwatcher
    install -Dm644 config/de.bernhard-baehr.sleepwatcher-20compatibility.plist $out/share/de.bernhard-baehr.sleepwatcher.plist
    install -Dm644 config/de.bernhard-baehr.sleepwatcher-20compatibility-localuser.plist $out/share/de.bernhard-baehr.sleepwatcher-user.plist
    install -Dm755 config/rc.* $out/bin/
  '';

  meta = with lib; {
    description = "Monitors sleep, wakeup, and idleness of a Mac";
    homepage = "https://www.bernhard-baehr.de/";
    license = licenses.gpl3Plus;
    maintainers = [maintainers.jpts];
    platforms = platforms.darwin;
  };
}
