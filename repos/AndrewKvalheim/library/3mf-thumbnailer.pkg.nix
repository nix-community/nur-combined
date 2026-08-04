{ lib
, writeTextFile

  # Dependencies
, unzip
}:

let
  inherit (lib) getExe;
  inherit (lib.generators) toINI;
in
writeTextFile {
  name = "3mf-thumbnailer";
  destination = "/share/thumbnailers/3mf.thumbnailer";
  text = toINI { } {
    "Thumbnailer Entry" = {
      Exec = "sh -c '${getExe unzip} -p \"$1\" 'Metadata/thumbnail.png' > \"$2\" || { rm \"$2\"; exit 1; }' _ %i %o";
      MimeType = "model/3mf";
    };
  };
}

