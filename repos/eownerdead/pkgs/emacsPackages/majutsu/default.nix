{
  trivialBuild,
  fetchFromGitHub,
  magit,
  transient,
  with-editor,
  ...
}:
trivialBuild rec {
  pname = "majutsu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = pname;
    rev = "9c938913b20ddb6cb11ae40ae91ac2836bfce0cc";
    hash = "sha256-Puiqe65QxfNcJvoDBlLMaNaxHygaPEUwgPhctWoMlAQ=";
  };

  packageRequires = [
    magit
    transient
    with-editor
  ];
}
