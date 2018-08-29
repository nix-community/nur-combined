{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "kubectx-${version}";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ahmetb";
    repo = "kubectx";
    rev = "v${version}";
    sha256 = "1bmmaj5fffx4hy55l6x4vl5gr9rp2yhg4vs5b9sya9rjvdkamdx5";
  };

  dontBuild = true;

  installPhase = ''
    install -dm755 "$out/share/bash-completion/completions/"
    install -dm755 "$out/share/fish/vendor_completions.d/"
    install -dm755 "$out/share/zsh/site-functions/"

    for tool in kubectx kubens
    do
        install -Dt "$out/bin/" -m755 "$tool"

        local completion="completion/$tool"

        install -Dt "$out/share/$tool/completion/" \
                -m444 "$completion.bash" "$completion.fish" "$completion.zsh"

        ln -s "$out/share/$tool/$completion.bash" "$out/share/bash-completion/completions/"
        ln -s "$out/share/$tool/$completion.fish" "$out/share/fish/vendor_completions.d/"
        ln -s "$out/share/$tool/$completion.zsh"  "$out/share/zsh/site-functions/"
    done
  '';

  meta = with stdenv.lib; {
    inherit version;
    description = "Fast way to switch between clusters and namespaces in kubectl";
    license = licenses.asl20;
    inherit (src.meta) homepage;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.unix;
  };
}
