{ stdenv, lib, fetchurl }:

with lib;
rec {
  ocGen =
    { version
    , sha256
    }:

    stdenv.mkDerivation rec {
      pname = "oc";
      name = "${pname}-${version}";

      src = fetchurl {
        url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-client-linux-${version}.tar.gz";
        sha256 = "${sha256}";
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
    };

  oc_4_4 = makeOverridable ocGen {
    version = "4.4.1";
    sha256 = "1p0i1kzqxn3ggy4xhjb0qh401knb686ab0ivnxlb6plbl7g071x2";
  };
  oc_4_3 = makeOverridable ocGen {
    version = "4.3.18";
    sha256 = "0msvh9f0jkvyg33kd70jgsaq2g5wqjcfkpnanwaqfz5s6lphscrq";
  };
  oc_4_2 = makeOverridable ocGen {
    version = "4.2.30";
    sha256 = "1qkbiqcpvjl0abnx9c4d29h10d87swc6bjfjbcrw1qlq06ksh5vb";
  };
  oc_4_1 = makeOverridable ocGen {
    version = "4.1.38";
    sha256 = "1hpp2zfac7yvb9jba2qwg0qlmq2a1gg2jl0gjci6rmyxgl40pd18";
  };
}
