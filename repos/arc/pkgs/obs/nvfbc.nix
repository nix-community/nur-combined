{ fetchFromGitLab, stdenv, obs-studio, meson, ninja, lib }: stdenv.mkDerivation rec {
  pname = "obs-nvfbc";
  version = "2020-06-26";

  src = fetchFromGitLab {
    owner = "fzwoch";
    repo = pname;
    rev = "87fe22bd32940343eb49f1fe5f3220a530a3ac56";
    sha256 = "1gkx6kfbnvawny5zgp117v6av08mrabzkwxc3bq425cqshy2q95c";
  };

  nativeBuildInputs = [ meson ninja ];
  buildInputs = [ obs-studio ];
  obsbindir = "bin/" + {
    x86-64 = "64bit";
  }.${stdenv.hostPlatform.parsed.cpu.arch} or "32bit";

  postInstall = ''
    install -d $out/share/obs/obs-plugins/$pname/$obsbindir
    mv $out/lib/obs-plugins/nvfbc.so $out/share/obs/obs-plugins/$pname/$obsbindir/
    rmdir $out/lib{/obs-plugins,}
  '';
}
