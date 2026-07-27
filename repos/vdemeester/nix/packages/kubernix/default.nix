{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "kubernix";
  version = "unstable-2020-05-07";
  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "saschagrunert";
    repo = pname;
    rev = "01ea39f468dd8abf6816a87fcac886a25ec05b0d";
    sha256 = "1zqqdcxidn10a4p1b64r1w79nwlifk1si0lf9jfkb7099rfrhalf";
  };

  cargoSha256 = "0xaf056x46c5561hypd85ni7bkijvz26kpwy5iiw19ijnlj1adw9";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Single dependency Kubernetes clusters for local testing, experimenting and development";
    homepage = https://github.com/saschagrunert/kubernix;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ saschagrunert ];
    platforms = platforms.linux;
  };
}
