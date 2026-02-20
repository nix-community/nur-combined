{ pkgs, ... }:

let
  linux-repo = "https://raw.githubusercontent.com/torvalds/linux";
  linux-rev = "01da5216c572f6f8fca4e272451aad6c273b0d57";

  codespell-url = "https://raw.githubusercontent.com/codespell-project/codespell";
  codespell-rev = "a9fe3fe23cd63cf38cebdbdcd38a50c796983887";
in
pkgs.stdenv.mkDerivation {
  pname = "checkpatch";
  version = "6.18";

  checkpatchSrc = pkgs.fetchurl {
    url = "${linux-repo}/${linux-rev}/scripts/checkpatch.pl";
    hash = "sha256-SZFk+xVMSOSN76OqfRrARi1wVU7rsxtlf2fPhnNjKHs=";
  };

  spellingTxt = pkgs.fetchurl {
    url = "${linux-repo}/${linux-rev}/scripts/spelling.txt";
    hash = "sha256-PBUm0MxjZda2N7NeRwXiSt08Sh1Oc7wmHKt/buQHkmQ=";
  };

  constStructs = pkgs.fetchurl {
    url = "${linux-repo}/${linux-rev}/scripts/const_structs.checkpatch";
    hash = "sha256-6gZPaRanR2NGgDdJSusnCq40t8l2F+hNQkyluHM1ObI=";
  };

  codespellDict = pkgs.fetchurl {
    url = "${codespell-url}/${codespell-rev}/codespell_lib/data/dictionary.txt";
    hash = "sha256-rBAYrGtL4ktjJ2PtIwI5MrEB4MZJbyvWTZIsB73AYbg=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
    perl
    perlPackages.FileSlurp
    perlPackages.TermANSIColor
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/checkpatch

    install -m 0644 $checkpatchSrc $out/share/checkpatch/checkpatch.pl
    install -m 0644 $spellingTxt $out/share/checkpatch/spelling.txt
    install -m 0644 $constStructs $out/share/checkpatch/const_structs.checkpatch
    install -m 0644 $codespellDict $out/share/checkpatch/dictionary.txt

    substituteInPlace $out/share/checkpatch/checkpatch.pl \
      --replace "/usr/share/codespell/dictionary.txt" \
      "$out/share/checkpatch/dictionary.txt"

    mkdir -p $out/bin
    makeWrapper ${pkgs.perl}/bin/perl $out/bin/checkpatch.pl \
      --add-flags "$out/share/checkpatch/checkpatch.pl"
  '';

  meta = with pkgs.lib; {
    description = "Linux kernel checkpatch.pl";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
    sourceProvenance = [ pkgs.lib.sourceTypes.fromSource ];
    license = licenses.gpl2Only;
    platforms = platforms.all;
    mainProgram = "checkpatch.pl";
  };
}
