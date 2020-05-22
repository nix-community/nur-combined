function __fish_prompt_nix_shell
    [ -z "$IN_NIX_SHELL" ]
    and return
    set_color yellow
    echo -n -s '🄪  '
    set_color normal
end

# ⏍ ⧆ ⌗ ⧉
function __fish_prompt_direnv
    [ -z "$DIRENV_DIR" ]
    and return
    set_color yellow
    echo -n -s '⧉ '
    set_color normal
end

function __fish_prompt_virtualenv
    [ -z "$VIRTUAL_ENV" ]
    and return
    set_color green
    echo -ns 'venv:' (basename "$VIRTUAL_ENV") ' '
    set_color normal
end

function fish_right_prompt
    __fish_prompt_direnv
    __fish_prompt_nix_shell
    __fish_prompt_virtualenv
end
