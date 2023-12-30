return {
 'linden-project/linny.vim',
  enabled = false,
  config = function()
    vim.g.linnycfg_path_wiki_content = vim.env.HOME .. '/secondbrain/wikiContent'
    vim.g.linnycfg_path_wiki_config = vim.env.HOME .. '/secondbrain/wikiConfig'
    vim.g.linnycfg_path_index = vim.env.HOME .. '/secondbrain/wikiIndex'
    vim.g.linny_menu_display_docs_count = 1
    vim.g.linny_menu_display_taxo_count = 1

    vim.g.linnycfg_setup_autocommands = 1
    -- vim.fn['linny#Init']()
    -- vim.fn.linny#Init()
  end,
}

