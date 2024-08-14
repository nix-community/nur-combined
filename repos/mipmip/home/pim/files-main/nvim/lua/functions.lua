function ReloadHomeManagerNeoVimConf()
  return function()
    print("Nix Home Manager: Rebuilding configuration..")
    local pid = vim.fn.getpid()
    local ok, result = pcall(vim.fn.writefile, {'kill -9 '.. tostring(pid)}, "/tmp/restartVim.sh")
    local job = vim.fn.jobstart(
      'cd /etc/nixos && ./RUNME.sh up_home',
      {
        cwd = '/etc/nixos',
        on_exit = function()
          print("Nix Home Manager: Configuration rebuild finished")
          if ok then
            --vim.fn.system('kill -9 '.. tostring(pid))
          else
            print(result)
          end
        end,
        on_stdout = function()
        end,
        on_stderr = function()
        end
      }
    )
  end
end

--vim.api.nvim_create_user_command('ReloadHomeManagerNeoVimConf', ReloadHomeManagerNeoVimConf, {})


function ToggleSpell(scope)
  return function ()
    scope.spell = not scope.spell
    vim.cmd("redraw")
    print("spell is " .. tostring(scope.spell))
  end
end


