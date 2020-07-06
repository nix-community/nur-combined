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
    version = "4.4.5";
    sha256 = "019jms70s87lrsn9qbr9khc1h0hgpw2f3kh2wvmx5jisb08nba7r";
  };
  oc_4_3 = makeOverridable ocGen {
    version = "4.3.24";
    sha256 = "07gq6wkinsmysdwglpcpam3kdphyv9c9nqfbmfhlmy1k2y5cw536";
  };
  oc_4_2 = makeOverridable ocGen {
    version = "4.2.34";
    sha256 = "199qm7hc8949ang45s7avs3vs6hm1ppb9q4jkvzqx1hgfyc2qzpl";
  };
  oc_4_1 = makeOverridable ocGen {
    version = "4.1.41";
    sha256 = "06wphg4vddhvavhxn07iq6pi3gq7ljbcdsgldwhyrjy8gx50bp47";
  };
}
