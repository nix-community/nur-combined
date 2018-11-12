{ stdenv, fetchFromGitHub }:


stdenv.mkDerivation rec {
  name = "lab-${version}";
  inherit (meta) version;

  src = fetchFromGitHub {
    owner = "yurrriq";
    repo = "lab";
    rev = version;
    sha256 = "1dh1xmfk2px4jyhj7cwhbp9nqkx59s91winq569gfl5zvnc9w7zy";
  };

  dontBuild = true;

  installPhase = ''
    install -dm755 "$out/bin"
    install -Dt "$_" -m755 lab
  '';

  meta = with stdenv.lib; {
    description = "Like hub, but for GitLab";
    version = "0.1.0";
    license = licenses.mit;
    maintainers = with maintainers; [ yurrriq ];
    inherit (src.meta) homepage;
  };
}
