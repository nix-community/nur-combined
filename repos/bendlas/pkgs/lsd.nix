{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "lsd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "lsd-rs";
    repo = "lsd";
    rev = "v${version}";
    sha256 = "sha256-syT+1LNdigUWkfJ/wkbY/kny2uW6qfpl7KmW1FjZKR8=";
  };

  cargoSha256 = "sha256-viLr76Bq9OkPMp+BoprQusMDgx59nbevVi4uxjZ+eZg=";

  ## FIXME error: Found argument '--test-threads' which wasn't expected, or isn't valid in this context
  doCheck = false;

  meta = with lib; {
    description = "The next gen ls command";
    homepage = https://github.com/lsd-rs/lsd;
    license = licenses.asl20;
    maintainers = [ maintainers.bendlas ];
    platforms = platforms.all;
  };
}
