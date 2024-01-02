return {
  "robitx/gp.nvim",
  config = function()
    require("gp").setup({
      openai_api_key = {'cat', '/tmp/openaiapikey-plain'}
    })

  end,
}
