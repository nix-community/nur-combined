{ fetchFromGitHub }:
rec {
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-6GPsg2/EJyomU9lqu+LdRNVaDPTc8z+kFwDQUi6mDI0=";
  };
}
