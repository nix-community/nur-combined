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

  oc_4_5 = makeOverridable ocGen {
    version = "4.5.0-rc.6";
    sha256 = "17f5j5rqrwcwp50r64qqnwdjl5alm7liwy07g9y0p6v13hx160jz";
  };
  oc_4_4 = makeOverridable ocGen {
    version = "4.4.11";
    sha256 = "19j5xwh4bv6sd60jbbx5fg063c0csgwp42dkcziqhwl4css1szad";
  };
  oc_4_3 = makeOverridable ocGen {
    version = "4.3.28";
    sha256 = "095sbvrh6wsc9fabppwy0mmg6zvgxzpfsv11w944d6ibxrpdhh4v";
  };
  oc_4_2 = makeOverridable ocGen {
    version = "4.2.36";
    sha256 = "1f9h58mx0a3zhpx11gim13hd3m4yzwa6ipbp1gwlghmhjz1jh35v";
  };
  oc_4_1 = makeOverridable ocGen {
    version = "4.1.41";
    sha256 = "06wphg4vddhvavhxn07iq6pi3gq7ljbcdsgldwhyrjy8gx50bp47";
  };
}
