{ pkgs
, fetchFromGitHub
, lib
, stdenv
}:
let

myPython = pkgs.python3.withPackages(ps: [ ps.six ps.chardet ps.pdfkit ]);

src = fetchFromGitHub {
  owner = "polo2ro";
  repo = "imapbox";
  rev = "a0ab2aead8f8eee4b1319f3b6abc003ea095338b";
  sha256 = "sha256-NTaPLfJQcMJiJiO/vEjumHYtWorgduO2noZEPpOL0Q8=";
};

in pkgs.writeShellApplication rec {
	name = "imapbox";

  text = ''
    ${myPython}/bin/python ${src}/imapbox.py "$@"
  '';

  runtimeInputs = with pkgs; [
    #wkhtmltopdf
  ];

  meta = with lib; {
    description = "Dump a IMAP folder into .eml files, message.txt, message.htmll and attachements.";
    longDescription = ''
      Dump imap inbox to a local folder in a regular backupable format: html, json and attachements.
      from: https://github.com/polo2ro/imapbox
    '';
    homepage = "https://github.com/polo2ro/imapbox";
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
