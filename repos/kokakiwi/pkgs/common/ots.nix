{ fetchFromGitHub }:
rec {
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-tYYbvktYaAUZbfJzADd/vkJ0NHLFY9lJEhclWZ6uOu4=";
  };
}
