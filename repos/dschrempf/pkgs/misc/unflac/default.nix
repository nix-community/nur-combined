{ lib
, buildGoModule
, fetchFromSourcehut
}:

buildGoModule rec {
  pname = "unflac";
  version = "f7506edc9b820a727a18b358c7e42a16399a0958";

  src = fetchFromSourcehut {
    owner = "~ft";
    repo = "unflac";
    rev = version;
    hash = "sha256-bkEExEQlDQEYRTlkagZffzXbDb9ehUrOHXFhf3Qu28s=";
  };

  vendorSha256 = "sha256-hGzbYj3yKTK2cK9syNd7dDQJZmKBhipGr3qdWvF37Hw=";

  meta = with lib; {
    description = "A command line tool for fast frame accurate audio image + cue sheet splitting";
    homepage = "https://git.sr.ht/~ft/unflac";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };

  # nativeBuildInputs = [ ];
  # buildInputs = [ ];
  # propagatedBuildInputs = [ ];
}
