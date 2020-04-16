{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "oc";
  version = "4.4.0-rc.8";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-linux-${version}.tar.gz";
    sha256 = "0a4l64ga4d2kdniz24llmpczdpg444br81mrcrhxm3mnhyv9yvsz";
  };

  phases = " unpackPhase installPhase fixupPhase ";

  unpackPhase = ''
    runHook preUnpack
    mkdir ${name}
    tar -C ${name} -xzf $src
  '';

  installPhase = ''
    runHook preInstall
    install -D ${name}/oc $out/bin/oc
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/bin/oc
    # completions
    mkdir -p $out/share/bash-completion/completions/
    $out/bin/oc completion bash > $out/share/bash-completion/completions/oc
    mkdir -p $out/share/zsh/site-functions
    $out/bin/oc completion zsh > $out/share/zsh/site-functions/_oc
  '';
}
