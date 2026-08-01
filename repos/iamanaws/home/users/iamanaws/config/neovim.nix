{
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    extraPackages = [ pkgs.xdg-utils ];

    extraConfig = ''
      " custom vimrc configuration
    '';

    initLua = ''
      local api = require("nvim-tree.api")

      local external_extensions = {
        avi = true,
        gif = true,
        jpeg = true,
        jpg = true,
        mkv = true,
        mov = true,
        mp4 = true,
        mpeg = true,
        mpg = true,
        ogg = true,
        pdf = true,
        png = true,
        svg = true,
        webm = true,
        webp = true,
      }

      local function open_with_system(path)
        vim.fn.jobstart({ "xdg-open", path }, { detach = true })
      end

      local function open_node()
        local node = api.tree.get_node_under_cursor()
        if not node then
          return
        end

        if node.type == "directory" then
          api.node.open.edit()
          return
        end

        local extension = vim.fn.fnamemodify(node.absolute_path, ":e"):lower()
        if external_extensions[extension] then
          api.tree.close()
          open_with_system(node.absolute_path)
          return
        end

        api.node.open.edit()
      end

      local function open_external()
        local node = api.tree.get_node_under_cursor()
        if not node or node.type == "directory" then
          return
        end

        api.tree.close()
        open_with_system(node.absolute_path)
      end

      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        sort_by = "case_sensitive",
        view = {
          width = 36,
          preserve_window_proportions = true,
        },
        renderer = {
          group_empty = true,
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        filters = {
          dotfiles = false,
        },
        on_attach = function(bufnr)
          api.config.mappings.default_on_attach(bufnr)

          local opts = function(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          vim.keymap.set("n", "<CR>", open_node, opts("Open"))
          vim.keymap.set("n", "O", open_external, opts("Open externally"))
          vim.keymap.set("n", "gx", open_external, opts("Open externally"))
        end,
      })

      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file tree" })
    '';

    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      nvim-web-devicons
    ];
  };
}
