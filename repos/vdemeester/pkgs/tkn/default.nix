{ stdenv, lib, buildGoModule, fetchFromGitHub }:

with lib;
rec {
  tknGen = { version, sha256, modSha }:
    buildGoModule rec {
      pname = "tkn";
      name = "${pname}-${version}";

      goPackagePath = "github.com/tektoncd/cli";
      subPackages = [ "cmd/tkn" ];
      buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in
        ''
          -ldflags=
            -X ${t}.clientVersion=${version}
        '';
      src = fetchFromGitHub {
        owner = "tektoncd";
        repo = "cli";
        rev = "v${version}";
        sha256 = "${sha256}";
      };
      modSha256 = "${modSha}";
      vendorSha256 = "${modSha}";

      postInstall = ''
        # manpages
        manRoot="$out/share/man"
        mkdir -p "$manRoot/man1"
        for manFile in docs/man/man1/*; do
          manName="$(basename "$manFile")" # "docker-build.1"
          gzip -c "$manFile" > "$manRoot/man1/$manName.gz"
        done
        # completions
        mkdir -p $out/share/bash-completion/completions/
        $out/bin/tkn completion bash > $out/share/bash-completion/completions/tkn
        mkdir -p $out/share/zsh/site-functions
        $out/bin/tkn completion zsh > $out/share/zsh/site-functions/_tkn
      '';
      meta = with stdenv.lib; {
        homepage = https://github.com/tektoncd/cli;
        description = "A CLI for interacting with Tekton!";
        license = licenses.asl20;
        maintainers = with maintainers; [ vdemeester ];
      };
    };

  tkn_0_10 = makeOverridable tknGen {
    version = "0.10.0";
    sha256 = "1p0vjbfd8nrbdfh22g2yv8cljkzyamaphryf76i94cfi4245d9d7";
    modSha = "1cdhs794habhhv1242ffv3lpkddx6rk2wjiyknf3lq6q47xlzz24";
  };
  tkn_0_9 = makeOverridable tknGen {
    version = "0.9.0";
    sha256 = "11wcips37k1vfif2ckpdxgf1p5yh2zgccv3ngnl1jjm8kcqla40q";
    modSha = "160174vw34v9w53azkzslcskzhsk1dflccfbvl1l38xm624fj4lw";
  };
  tkn_0_8 = makeOverridable tknGen {
    version = "0.8.0";
    sha256 = "00qznm02gsxvgxjakj7qpm8rgx82bnyycw4l7kpnrly5m07nm9gv";
    modSha = "0a9m46aspqbvnnvhg6qv0adarr7plj91vknbz9idc8yz4sv9wi8j";
  };
}
