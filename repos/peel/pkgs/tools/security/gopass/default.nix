{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "gopass-${version}";
  version = "v1.6.11";
  rev = "${version}";

  goPackagePath = "github.com/justwatchcom/gopass";

  src = fetchFromGitHub {
    inherit rev;
    owner = "justwatchcom";
    repo = "gopass";
    sha256 = "12pih414232bsdj1qqc04vck2p9254wjy044n5kbbdqbmfgap7sj";
  };

  postInstall = ''
    mkdir -p "$bin/share/bash-completion/completions"
    $bin/bin/gopass completion bash > "$bin/share/bash-completion/completions/gopass.bash"
    mkdir -p "$bin/share/zsh/site-functions"
    $bin/bin/gopass completion bash > "$bin/share/zsh/site-functions/gopass.zsh"
    mkdir -p "$bin/share/fish/vendor_completions.d"
    $bin/bin/gopass completion fish > "$bin/share/fish/vendor_completions.d/gopass.fish"
  '';
  meta = with stdenv.lib; {
    description = "The slightly more awesome standard unix password manager for teams";
    homepage = "https://www.justwatch.com/gopass";
    license = licenses.mit;
  };
}
