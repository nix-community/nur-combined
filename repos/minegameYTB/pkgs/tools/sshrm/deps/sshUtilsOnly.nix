{ stdenvNoCC, openssh }:

stdenvNoCC.mkDerivation {
  pname = "ssh-only";
  version = openssh.version;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontPatchElf = true;

  ### Only link ssh utils used by the derivation
  buildInputs = [ openssh ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${openssh}/bin/ssh $out/bin/ssh
    ln -s ${openssh}/bin/ssh-keygen $out/bin/ssh-keygen
  '';
}
