{ stdenv, lib, buildGoModule, git, fetchFromGitHub }:

with lib;
rec {
  operatorSdkGen =
    { version
    , sha256
    , vendorSha256
    }:

    buildGoModule rec {
      inherit vendorSha256;
      pname = "operator-sdk";
      name = "${pname}-${version}";
      rev = "v${version}";

      builtInputs = [ "git" ];

      goPackagePath = "github.com/operator-framework/operator-sdk";
      subPackages = [ "cmd/operator-sdk" ];
      buildFlagsArray = let t = "${goPackagePath}/version"; in
        ''
          -ldflags=
            -X ${t}.GitVersion=${version}
            -X ${t}.KubernetesVersion=v1.17.2
        '';

      src = fetchFromGitHub {
        inherit rev;
        owner = "operator-framework";
        repo = "operator-sdk";
        sha256 = "${sha256}";
      };
      modSha256 = "${vendorSha256}";

      postInstall = ''
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/operator-sdk completion bash > $out/share/bash-completion/completions/operator-sdk
        mkdir -p $out/share/zsh/site-functions/
        $out/bin/operator-sdk completion zsh > $out/share/zsh/site-functions/_operator-sdk
      '';

      meta = {
        description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
        homepage = https://github.com/operator-framework/operator-sdk;
        license = lib.licenses.asl20;
      };
    };

  operator-sdk_0_16 = makeOverridable operatorSdkGen {
    version = "0.16.0";
    sha256 = "1qdvnfxz81ij1y7qdk5xjq0nd3dqgbdjq0gmramxmkkz892cdaf3";
    vendorSha256 = "11nz0fdxpsc9ifszprgp1l70myhadh90hcs94cilrpqwlci0i8c5";
  };
  operator-sdk_0_17 = makeOverridable operatorSdkGen {
    version = "0.17.0";
    sha256 = "11mirwgmmhfccv1knxvf2pv51pisngw5lb8vpcbzi5v2lm192aqk";
    vendorSha256 = "0mspbnw41c6r3p7kaafza1v10zi4jv0vrnzxwpyh7pkmx150xgvd";
  };
  operator-sdk_0_18 = makeOverridable operatorSdkGen {
    version = "0.18.0";
    sha256 = "1jbi5v1kcni740znjxm6hbpjx3a1zlkgnbnpsqbiljfi6k7spn6p";
    vendorSha256 = "19icxp39kvgh7v8sa190ym8i9ffyxgccf6mvqn48hdhq5sr95wm2";
  };
  operator-sdk_0_19 = makeOverridable operatorSdkGen {
    version = "0.19.0";
    sha256 = "0prwdsxm8sldzdn7r9k1yw2q4asz90n25g4zcfaq23vs6fkxch9b";
    vendorSha256 = "1pz1k23a7jrisflx03jfp5a6xcw7x6pjkp9b6bma9y9w4jaklyqw";
  };
}
