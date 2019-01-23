{ stdenv, fetchFromGitHub, fzf }:

stdenv.mkDerivation {
  name = "fzf-zsh";
  src = fetchFromGitHub {
    owner = "Wyntau";
    repo = "fzf-zsh";
    rev = "ba1a5651af4baa02f14698431855ad48940b4348";
    sha256 = "14hv2hm0ib0bj739n2wzj58v0rbixin30jvmfmwrv65kfxblsi4h";
  };

  postPatch = ''
    substituteInPlace fzf-zsh.plugin.zsh \
      --replace \
        'fzf_path="$( cd "$fzf_zsh_path/../fzf/" && pwd )"' \
        "fzf_path=${fzf}" \
      --replace \
        '$fzf_path/shell' \
        '${fzf}/share/fzf'
  '';

  dontBuild = true;

  installPhase = ''
    install -Dm0644 fzf-zsh.plugin.zsh $out/share/zsh/plugins/fzf-zsh/fzf-zsh.plugin.zsh
  '';
}
