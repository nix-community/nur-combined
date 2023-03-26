{ runCommand
, vim
, lib
}:
{ name ? "${basename}.${encoding}.add.spl"
, encoding ? "utf-8"
, basename ? "vim-spell"
, spellings
}: runCommand name rec {
  spelling = lib.concatStringsSep "\n" spellings;
  passAsFile = [ "spelling" ];
  nativeBuildInputs = [ vim ];
  vimExe = vim.meta.mainProgram or (lib.getName vim);
  vimArgs = toString (lib.optional (vimExe == "nvim") "--headless" ++ [
    "-n"
    "--clean"
  ]);
} ''
  $vimExe $vimArgs \
    --cmd "mkspell $out $spellingPath" \
    --cmd quit
''
