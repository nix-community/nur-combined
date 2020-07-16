{ stdenv, lib, fetchurl }:

with lib;
rec {
  openshiftInstallGen =
    { version
    , sha256
    }:

    stdenv.mkDerivation rec {
      pname = "openshift-install";
      name = "${pname}-${version}";

      src = fetchurl {
        inherit sha256;
        url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-install-linux-${version}.tar.gz";
      };

      phases = " unpackPhase installPhase fixupPhase ";

      unpackPhase = ''
        runHook preUnpack
        mkdir ${name}
        tar -C ${name} -xzf $src
      '';

      installPhase = ''
        runHook preInstall
        install -D ${name}/openshift-install $out/bin/openshift-install
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/openshift-install completion bash > $out/share/bash-completion/completions/openshift-install
        mkdir -p $out/share/zsh/site-functions
        $out/bin/openshift-install completion zsh > $out/share/zsh/site-functions/_openshift-install
      '';

      meta = {
        description = "Install an OpenShift cluster";
        homepage = https://github.com/openshift/installer;
        license = lib.licenses.asl20;
      };
    };

  openshift-install_4_5 = makeOverridable openshiftInstallGen {
    version = "4.5.2";
    sha256 = "0apb94914y9g2driwbnbcgd3y60jwsnpmb0n8nlzrshbfmkvp7l7";
  };
  openshift-install_4_4 = makeOverridable openshiftInstallGen {
    version = "4.4.13";
    sha256 = "10n2i0wkzay277cixc3qifag8l0pqba31ljvczx5m8bi06hnnsni";
  };
  openshift-install_4_3 = makeOverridable openshiftInstallGen {
    version = "4.3.29";
    sha256 = "0rrzmc8pkks8k3ar834z6k5nl0mgpi8llyb14slcn7mwilwg9024";
  };
}
