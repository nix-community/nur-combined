{ stdenv, lib, fetchFromGitHub, rustPlatform, makeWrapper
, pandoc, poppler_utils, ripgrep, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "ripgrep-all";
  version = "0.9.7-infdev";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = pname;
    rev = "ca0191c38ed0c3ef6dc733bd3c4d4359ff4fb522";
    sha256 = "0fkkpk82bd9bm184nmcx6vn1pqwc9z0abr6wsfr6vkd6vm3184ca";
  };

  cargoSha256 = "1z1008yyhzch92740bcs4mn5l0b2y7z3h2vjp5vh2qk99byh6ydm";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optional stdenv.isDarwin Security;

  postInstall = ''
    wrapProgram $out/bin/rga \
      --prefix PATH ":" "${lib.makeBinPath [ pandoc poppler_utils ripgrep ]}"
  '';

  # Use upstream's example data to run a couple of queries to ensure the dependencies
  # for all of the adapters are available.
  installCheckPhase = ''
    set -e
    export PATH="$PATH:$out/bin"

    test1=$(rga --rga-no-cache "hello" exampledir/ | wc -l)
    test2=$(rga --rga-no-cache --rga-adapters=tesseract "crate" exampledir/screenshot.png | wc -l)

    if [ $test1 != 26 ]
    then
      echo "ERROR: test1 failed! Could not find the word 'hello' 26 times in the sample data."
      exit 1
    fi

    if [ $test2 != 1 ]
    then
      echo "ERROR: test2 failed! Could not find the word 'crate' in the screenshot."
      exit 1
    fi
  '';

  doInstallCheck = false;
  doCheck = false; # ...

  meta = with lib; {
    description = "Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more";
    longDescription = ''
      Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc.

      rga is a line-oriented search tool that allows you to look for a regex in
      a multitude of file types. rga wraps the awesome ripgrep and enables it
      to search in pdf, docx, sqlite, jpg, movie subtitles (mkv, mp4), etc.
    '';
    homepage = "https://github.com/phiresky/ripgrep-all";
    license = with licenses; [ agpl3Plus ];
    maintainers = with maintainers; [ fliegendewurst ];
    mainProgram = "rga";
  };
}
