if begin; status --is-interactive; and not functions -q -- iterm2_status; and [ "$TERM" != screen ]; end
  function iterm2_status
    printf "\033]133;D;%s\007" $argv
  end

  # Mark start of prompt
  function iterm2_prompt_mark
    printf "\033]133;A\007"
  end

  # Mark end of prompt
  function iterm2_prompt_end
    printf "\033]133;B\007"
  end

  # Tell terminal to create a mark at this location
  function iterm2_preexec
    # For other shells we would output status here but we can't do that in fish.
    printf "\033]133;C;\007"
  end

  # Usage: iterm2_set_user_var key value
  # These variables show up in badges (and later in other places). For example
  # iterm2_set_user_var currentDirectory "$PWD"
  # Gives a variable accessible in a badge by \(user.currentDirectory)
  # Calls to this go in iterm2_print_user_vars.
  function iterm2_set_user_var
    printf "\033]1337;SetUserVar=%s=%s\007" "$argv[1]" (printf "%s" "$argv[2]" | base64 | tr -d "\n")
  end

  # iTerm2 inform terminal that command starts here
  function iterm2_precmd
    printf "\033]1337;RemoteHost=%s@%s\007\033]1337;CurrentDir=$PWD\007" $USER $iterm2_hostname

    # Users can define a function called iterm2_print_user_vars.
    # It should call iterm2_set_user_var and produce no other output.
    if functions -q -- iterm2_print_user_vars
      iterm2_print_user_vars
    end

  end

  functions -c fish_prompt iterm2_fish_prompt

  if functions -q -- fish_mode_prompt
    # This path for fish 2.2. Works nicer with fish_vi_mode.
    functions -c fish_mode_prompt iterm2_fish_mode_prompt
    function fish_mode_prompt --description 'Write out the mode prompt; do not replace this. Instead, change fish_mode_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_mode_prompt instead.'
       set -l last_status $status

       iterm2_status $last_status
       if not functions iterm2_fish_prompt | grep iterm2_prompt_mark > /dev/null
         iterm2_prompt_mark
       end
       sh -c "exit $last_status"

       iterm2_fish_mode_prompt
    end

    function fish_prompt --description 'Write out the prompt; do not replace this. Instead, change fish_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_prompt instead.'
       # Remove the trailing newline from the original prompt. This is done
       # using the string builtin from fish, but to make sure any escape codes
       # are correctly interpreted, use %b for printf.
       printf "%b" (string join "\n" (iterm2_fish_prompt))

       iterm2_prompt_end
    end
  else
    # Pre-2.2 path
    function fish_prompt --description 'Write out the prompt; do not replace this. Instead, change fish_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_prompt instead.'
      # Save our status
      set -l last_status $status

      iterm2_status $last_status
      if not functions iterm2_fish_prompt | grep iterm2_prompt_mark > /dev/null
        iterm2_prompt_mark
      end

      # Restore the status
      sh -c "exit $last_status"
      iterm2_fish_prompt
      iterm2_prompt_end
    end
  end

  function underscore_change -v _
    if [ x$_ = xfish ]
      iterm2_precmd
    else
      iterm2_preexec
    end
  end

  # If hostname -f is slow for you, set iterm2_hostname before sourcing this script
  if not set -q iterm2_hostname
    set iterm2_hostname (hostname -f)
  end

  iterm2_precmd
  printf "\033]1337;ShellIntegrationVersion=5;shell=fish\007"
end
