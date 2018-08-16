{ stdenv, fetchFromGitHub }:


stdenv.mkDerivation rec {
  name = "lab-${version}";
  inherit (meta) version;

  src = fetchFromGitHub {
    owner = "yurrriq";
    repo = "lab";
    rev = version;
    sha256 = "1v8qsqhr5wnf4y05x1l5qjdyswa23p8wkgmf7zv1r8y2j9kpvgq7";
  };

  dontBuild = true;

  installPhase = ''
    install -dm755 "$out/bin"
    install -Dt "$_" -m755 lab
  '';

  meta = with stdenv.lib; {
    description = "Like hub, but for GitLab";
    version = "0.0.2";
    license = licenses.mit;
    maintainers = with maintainers; [ yurrriq ];
    inherit (src.meta) homepage;
  };
}
