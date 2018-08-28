{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "m-cli-${version}";
  version = "27dd5d06";

  src = fetchFromGitHub {
    owner = "rgcr";
    repo = "m-cli";
    rev = version;
    sha512 = "0kr4mbdj1clll6wr6jmbq3x8w4rxh9iihsymsqgbw7fyp8x27d9mqiszmhn74jclnici164f40ymw8k7qm48l2c3ybvc3yvfkr1zbw8";
  };

  dontBuild = true;

  installPhase = ''
    local MPATH="$out/share/m"

    gawk -i inplace '{
      gsub(/^\[ -L.*|^\s+\|\| pushd.*|^popd.*/, "");
      gsub(/MPATH=.*/, "MPATH='$MPATH'");
      gsub(/(update|uninstall)_mcli \&\&.*/, "echo NOOP \\&\\& exit 0");
      print
    }' m

    install -Dt "$MPATH/plugins" -m755 plugins/*

    install -Dm755 m $out/bin/m

    install -Dt "$out/share/bash-completion/completions/" -m444 completion/bash/m
    install -Dt "$out/share/fish/vendor_completions.d/" -m444 completion/fish/m.fish
    install -Dt "$out/share/zsh/site-functions/" -m444 completion/zsh/_m
  '';

  meta = with stdenv.lib; {
    description = "Swiss Army Knife for macOS";
    inherit (src.meta) homepage;
    repositories.git = git://github.com/rgcr/m-cli.git;

    license = licenses.mit;

    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
