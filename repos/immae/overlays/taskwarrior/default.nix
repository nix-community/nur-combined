self: super:
{
  taskwarrior = super.taskwarrior.overrideAttrs (old: {
    postInstall = ''${old.postInstall}
      mkdir -p "$out/share/vim/vimfiles/ftdetect"
      mkdir -p "$out/share/vim/vimfiles/syntax"
      ln -s "../../../../share/doc/task/scripts/vim/ftdetect/task.vim" "$out/share/vim/vimfiles/ftdetect/"
      ln -s "../../../../share/doc/task/scripts/vim/syntax/taskrc.vim" "$out/share/vim/vimfiles/syntax/"
      ln -s "../../../../share/doc/task/scripts/vim/syntax/taskdata.vim" "$out/share/vim/vimfiles/syntax/"
      ln -s "../../../../share/doc/task/scripts/vim/syntax/taskedit.vim" "$out/share/vim/vimfiles/syntax/"
    '';
  });
}
