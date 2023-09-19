if $LINNY == "devlindex"

  let g:linnycfg_debug                 = 1
  let g:linnycfg_path_wiki_content     = $HOME . '/cVim/lindex/spec/linny_db_root/wiki'
  let g:linnycfg_path_wiki_config      = $HOME . '/cVim/lindex/spec/linny_db_root/config'
  let g:linnycfg_path_index            = $HOME . '/cVim/lindex/tmp/index_files'
  let g:linnycfg_path_state            = $HOME . '/.linny/state_dev'
  let g:linnycfg_rebuild_index_command = '~/cVim/lindex/bin/lindex make -c ~/.lindex_dev.yml'

elseif $LINNY == "devplug"

  let g:linnycfg_debug                 = 1
  let g:linnycfg_path_wiki_content     = $HOME . '/.vim/plugged/linny.vim/test/linny_db_root/wiki'
  let g:linnycfg_path_wiki_config      = $HOME . '/.vim/plugged/linny.vim/test/linny_db_root/config'
  let g:linnycfg_path_index            = $HOME . '/.vim/plugged/linny.vim/test/linny_index_files'
  let g:linnycfg_path_state            = $HOME . '/.linny/state_dev2'
  let g:linnycfg_rebuild_index_command = $HOME . '/cVim/lindex/bin/lindex make -c ~/.lindex_dev2.yml'

elseif $LINNY == "devhugo"

  let g:linnycfg_path_wiki_content     = $HOME . '/cVim/carl/wikiContent'
  let g:linnycfg_path_wiki_config      = $HOME . '/cVim/carl/wikiConfig'
  let g:linnycfg_path_index            = $HOME . '/cVim/carl/wikiIndex'

  let g:linnycfg_path_state            = $HOME . '/.linny/state_dev3'
  let g:linnycfg_debug                 = 0

else

  let g:linnycfg_path_wiki_content     = $HOME . '/secondbrain/wikiContent'
  let g:linnycfg_path_wiki_config      = $HOME . '/secondbrain/wikiConfig'
  let g:linnycfg_path_index            = $HOME . '/secondbrain/wikiIndex'
  "let g:linnycfg_path_index            = $HOME . '/.linny/index_files'
  "let g:linnycfg_rebuild_index_command = $HOME . '/cVim/lindex/bin/lindex make -c '.$HOME.'/.lindex.yml'

end

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
