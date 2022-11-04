# https://docs.akkoma.dev/stable/installation/otp_en/#installing-akkoma
{ lib, python3, fetchFromGitHub
, version ? "94949289f07e7f915f640b71179b193356fc1d5b", stdenvNoCC }:
let
  python = (python3.withPackages
    (p: with p; [ anyio aiohttp aiosqlite beautifulsoup4 json5 pendulum ]));
in stdenvNoCC.mkDerivation {
  pname = "pleroma-ebooks";
  inherit version;

  src = fetchFromGitHub {
    owner = "ioistired";
    repo = "pleroma-ebooks";
    rev = version;
    sha256 = "sha256-TyyyuRvu8vTpVtMBjooWQh97QxuAaaolBmxWBcDK14A";
  };

  phases = [ "installPhase" ];
  buildInputs = [ python ];
  runtimeInputs = [ python ];

  newShebang = "#!${python}/bin/python";

  installPhase = ''
    mkdir -p $out
    cp -r "$src" "$out/bin"

    bins=($out/bin/fetch_posts.py $out/bin/gen.py $out/bin/reply.py)

    for i in "''${bins[@]}"; do
      chmod +w $i
      printf "%s\n%s" "$newShebang" "$(cat $i)" > $i
    done
  '';

  dontPatchELF = true;
  #dontPatchShebangs = true;

  meta = with lib; {
    description = "pleroma-ebooks";
    homepage = "https://github.com/ioistired/pleroma-ebooks";
    license = licenses.agpl3Only;
  };
}
