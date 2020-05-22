# name: lambda
function __fish_basename -d 'basically basename, but faster'
    string replace -r '^.*/' '' -- $argv
end

function __fish_dirname -d 'basically dirname, but faster'
    string replace -r '/[^/]+/?$' '' -- $argv
end


function __fish_prompt_status -S -a last_status -d 'Display flags for non-zero-exit status, root user, and background jobs'
    set -l nonzero
    set -l superuser
    set -l bg_jobs

    # Last exit was nonzero
    [ $last_status -ne 0 ]
    and set nonzero 1

    # If superuser (uid == 0)
    #
    # Note that iff the current user is root and '/' is not writeable by root this
    # will be wrong. But I can't think of a single reason that would happen, and
    # it is literally 99.5% faster to check it this way, so that's a tradeoff I'm
    # willing to make.
    [ -w / ]
    and [ (id -u) -eq 0 ]
    and set superuser 1

    # Jobs display
    jobs -p >/dev/null
    and set bg_jobs 1

    if [ "$nonzero" ]
        set_color red
        echo -n '! '
        set_color normal
    end

    if [ "$superuser" ]
        set_color red
        echo -n '$ '
        set_color normal
    end

    if [ "$bg_jobs" ]
        set_color gray
        echo -n '% '
        set_color normal
    end
end

function __fish_prompt_user -S -d 'Display current user and hostname'
    [ -n "$SSH_CLIENT" ]
    and set -l display_user_hostname

    if set -q display_user_hostname
        set -l IFS .
        hostname | read -l hostname __
        echo -ns (whoami) '@' $hostname
    end
end

function __fish_git_project_dir
    set -l git_dir (command git rev-parse --git-dir ^/dev/null)
    or return

    pushd $git_dir
    set git_dir $PWD
    popd

    switch $PWD/
        case $git_dir/\*
            # Nothing works quite right if we're inside the git dir
            # TODO: fix the underlying issues then re-enable the stuff below

            # # if we're inside the git dir, sweet. just return that.
            # set -l toplevel (command git rev-parse --show-toplevel ^/dev/null)
            # if [ "$toplevel" ]
            #   switch $git_dir/
            #     case $toplevel/\*
            #       echo $git_dir
            #   end
            # end
            return
    end

    set -l project_dir (__fish_dirname $git_dir)

    switch $PWD/
        case $project_dir/\*
            echo $project_dir
            return
    end

    set project_dir (command git rev-parse --show-toplevel ^/dev/null)
    switch $PWD/
        case $project_dir/\*
            echo $project_dir
    end
end

function __fish_git_ahead -S -d 'Print the ahead/behind state for the current branch'
    set -l ahead 0
    set -l behind 0
    for line in (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
        switch "$line"
            case '>*'
                if [ $behind -eq 1 ]
                    echo '±'
                    return
                end
                set ahead 1
            case '<*'
                if [ $ahead -eq 1 ]
                    echo "±"
                    return
                end
                set behind 1
        end
    end

    if [ $ahead -eq 1 ]
        echo "+"
    else if [ $behind -eq 1 ]
        echo "-"
    end
end

function __fish_git_branch -S -d 'Get the current git branch (or commitish)'
    set -l ref (command git symbolic-ref HEAD ^/dev/null)
    and begin
        string replace 'refs/heads/' "" $ref
        and return
    end

    set -l tag (command git describe --tags --exact-match ^/dev/null)
    and echo "tag:$tag"
    and return

    set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    echo "detached:$branch"
end

function __fish_prompt_git -S -a current_dir -d 'Display the actula git state'
    set -l dirty ''
    set -l show_dirty (command git config --bool bash.showDirtyState ^/dev/null)
    if [ "$show_dirty" != 'false' ]
        set dirty (command git diff --no-ext-diff --quiet --exit-code ^/dev/null; or echo -n "*")
    end

    set -l staged (command git diff --cached --no-ext-diff --quiet --exit-code ^/dev/null; or echo -n "~")
    set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
    set -l ahead (__fish_git_ahead)

    set -l new ''
    set -l show_untracked (command git config --bool bash.showUntrackedFiles ^/dev/null)
    if [ "$show_untracked" != 'false' ]
        set new (command git ls-files --other --exclude-standard --directory --no-empty-directory ^/dev/null)
        if [ "$new" ]
            set new "…"
        end
    end

    set -l flags "$dirty$staged$stashed$ahead$new"
    [ "$flags" ]
    and set flags ":$flags"

    __fish_path_segment $current_dir

    set_color green
    echo -n '{'
    echo -ns (__fish_git_branch) $flags ''
    echo -n '}'
    set_color normal

    set -l project_pwd (command git rev-parse --show-prefix ^/dev/null | string trim --right --chars=/)

    if [ "$project_pwd" ]
        set_color brblack
        echo -n "/$project_pwd"
        set_color normal
    end
end

function __fish_prompt_dir -S -d 'Display a shortened form of the current directory'
    __fish_path_segment "$PWD"
end

function __fish_path_segment -S -a current_dir -d 'Display a shortened form of a directory'
    set -l directory
    set -l parent

    switch "$current_dir"
        case /
            set directory '/'
        case "$HOME"
            set directory '~'
        case '*'
            set parent (__fish_pretty_parent "$current_dir")
            set directory (__fish_basename "$current_dir")
    end

    set_color white
    echo -n $parent
    set_color --bold
    echo -ns $directory ''
    set_color normal
end

function __fish_pretty_parent -S -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
    set -q fish_prompt_pwd_dir_length
    or set -l fish_prompt_pwd_dir_length 1

    # Replace $HOME with ~
    set -l real_home ~
    set -l parent_dir (string replace -r '^'"$real_home"'($|/)' '~$1' (__fish_dirname $current_dir))

    # Must check whether `$parent_dir = /` if using native dirname
    if [ -z "$parent_dir" ]
        echo -n /
        return
    end

    if [ $fish_prompt_pwd_dir_length -eq 0 ]
        echo -n "$parent_dir/"
        return
    end

    string replace -ar '(\.?[^/]{'"$fish_prompt_pwd_dir_length"'})[^/]*/' '$1/' "$parent_dir/"
end

# TODO: handle envs (nix-shell, virtualenv, ...)

function fish_prompt -d 'vde-lambda, a fish theme optimized for me :D'
    if test $TERM = "dumb"
        echo "\$ "
        return 0
    end
    # Save the last status for later
    set -l last_status $status

    __fish_prompt_status $last_status
    __fish_prompt_user

    # vcs
    set -l git_root (__fish_git_project_dir)

    if [ "$git_root" ]
        __fish_prompt_git $git_root
    else
        __fish_prompt_dir
    end

    set_color --bold brblack
    echo -n " λ "
    set_color normal
end
