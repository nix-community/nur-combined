local success, err = pcall(require, 'adapter.fennel')
if not success then
    print(err)
    print("Failed to import the fennel stuff. LSP and the Lua stuff will not be available")
    print("Are you sure that your dotfiles is in ~/.dotfiles?")
else
    local success, err = pcall(require, 'adapter.nvim')
    if not success then
        print(err)
    end
end
