{ stdenvNoCC }: stdenvNoCC.mkDerivation {
  pname = "git-fixup";
  version = "2021-09-19";

  src = ./git-fixup.sh;

  unpackPhase = ''
    runHook preUnpack

    cp $src git-fixup.sh

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm0755 git-fixup.sh $out/bin/git-fixup

    runHook postInstall
  '';
}
