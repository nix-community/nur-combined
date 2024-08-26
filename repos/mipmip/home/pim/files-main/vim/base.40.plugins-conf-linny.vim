let g:linny_open_notebook_path       = $HOME . '/secondbrain'
"let g:linnycfg_notebooks_paths = [ $HOME . '/cLinden/linny-notebook-template',  $HOME . '/secondbrain']


if filereadable($HOME."/.i-am-second-brain")
  call linny#Init()

  " CUSTOM WIKITAGS
  function! Linny_open_issue(innertag)
    execute "!firefox https://github.com/linden-project/linny.vim/issues/" . a:innertag
  endfunction

  call linny#RegisterLinnyWikitag('LINNYISSUE', 'Linny_open_issue')

  let g:linny_menu_display_docs_count = 1
  let g:linny_menu_display_taxo_count = 1

endif
