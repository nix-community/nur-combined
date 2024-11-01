{ fetchFromGitHub
, lib
, stdenvNoCC
, jq
}:
stdenvNoCC.mkDerivation rec {
  pname = "jq-emojify";
  version = "0.0.1";
  srcs = [
    (
      fetchFromGitHub {
        owner = "Freed-Wu";
        repo = pname;
        name = pname;
        rev = version;
        sha256 = "sha256-n1knGf8TloatQc0k8/ZKre7vXu6g1L2XVaTSQZreOrc=";
      }
    )
    (
      fetchFromGitHub {
        owner = "github";
        repo = "gemoji";
        name = "gemoji";
        rev = "v4.1.0";
        sha256 = "sha256-vs/ltvNzctK6mlKy+fxeVANfiQqueLBr3OvblyRNGvo=";
      }
    )
  ];
  sourceRoot = ".";

  buildInputs = [ jq ];

  buildPhase = ''
    install -d $out/lib/jq
    jq -srRf jq-emojify/scripts/generate-emoji.jq.jq gemoji/db/emoji.json > $out/lib/jq/emoji.jq
    sed -i s=/usr/lib=$out/lib=g jq-emojify/emojify
    install -D jq-emojify/emojify -t $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/jq-emojify";
    description = "A jq implementation for emojify";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
