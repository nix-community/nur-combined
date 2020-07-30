#! /bin/bash
# This shebang will get patched

spack_wrapper_fun() {
  # Store LD_LIBRARY_PATH variables from spack shell function
  # This is necessary because MacOS System Integrity Protection clears
  # variables that affect dyld on process start.
  for var in LD_LIBRARY_PATH DYLD_LIBRARY_PATH DYLD_FALLBACK_LIBRARY_PATH; do
    eval "if [ -n \"\${${var}-}\" ]; then export SPACK_$var=\${${var}}; fi"
  done

  # Zsh does not do word splitting by default, this enables it for this
  # function only
  if [ -n "${ZSH_VERSION:-}" ]; then
    emulate -L sh
  fi

  # accumulate flags meant for the main spack command
  # the loop condition is unreadable, but it means:
  #     while $1 is set (while there are arguments)
  #       and $1 starts with '-' (and the arguments are flags)
  _sp_flags=""
  while [ ! -z ${1+x} ] && [ "${1#-}" != "${1}" ]; do
    _sp_flags="$_sp_flags $1"
    shift
  done

  # h and V flags don't require further output parsing.
  if [ -n "$_sp_flags" ] && \
    [ "${_sp_flags#*h}" != "${_sp_flags}" ] || \
    [ "${_sp_flags#*V}" != "${_sp_flags}" ];
    then
      @spack@ $_sp_flags "$@"
      return
  fi

  # set the subcommand if there is one (if $1 is set)
  _sp_subcommand=""
  if [ ! -z ${1+x} ]; then
    _sp_subcommand="$1"
    shift
  fi

  # Filter out use and unuse.  For any other commands, just run the
  # command.
  case $_sp_subcommand in
    "cd")
      _sp_arg=""
      if [ -n "$1" ]; then
        _sp_arg="$1"
        shift
      fi
      if [ "$_sp_arg" = "-h" ] || [ "$_sp_arg" = "--help" ]; then
        @spack@ cd -h
      else
        LOC="$(@spack@ location $_sp_arg "$@")"
        if [ -d "$LOC" ] ; then
          cd "$LOC"
        else
          return 1
        fi
      fi
      return
      ;;
    "env")
      _sp_arg=""
      if [ -n "$1" ]; then
        _sp_arg="$1"
        shift
      fi

      if [ "$_sp_arg" = "-h" ] || [ "$_sp_arg" = "--help" ]; then
        @spack@ env -h
      else
        case $_sp_arg in
          activate)
            # Get --sh, --csh, or -h/--help arguments.
            # Space needed here becauses regexes start with a space
            # and `-h` may be the only argument.
            _a=" $@"
            # Space needed here to differentiate between `-h`
            # argument and environments with "-h" in the name.
            # Also see: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
            if [ -z ${1+x} ] || \
              [ "${_a#* --sh}" != "$_a" ] || \
              [ "${_a#* --csh}" != "$_a" ] || \
              [ "${_a#* -h}" != "$_a" ] || \
              [ "${_a#* --help}" != "$_a" ];
                        then
                          # No args or args contain --sh, --csh, or -h/--help: just execute.
                          @spack@ env activate "$@"
                        else
                          # Actual call to activate: source the output.
                          eval $(@spack@ $_sp_flags env activate --sh "$@")
            fi
            ;;
          deactivate)
            # Get --sh, --csh, or -h/--help arguments.
            # Space needed here becauses regexes start with a space
            # and `-h` may be the only argument.
            _a=" $@"
            # Space needed here to differentiate between `--sh`
            # argument and environments with "--sh" in the name.
            # Also see: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
            if [ "${_a#* --sh}" != "$_a" ] || \
              [ "${_a#* --csh}" != "$_a" ];
                        then
                          # Args contain --sh or --csh: just execute.
                          @spack@ env deactivate "$@"
                        elif [ -n "$*" ]; then
                          # Any other arguments are an error or -h/--help: just run help.
                          @spack@ env deactivate -h
                        else
                          # No args: source the output of the command.
                          eval $(@spack@ $_sp_flags env deactivate --sh)
            fi
            ;;
          *)
            @spack@ env $_sp_arg "$@"
            ;;
        esac
      fi
      return
      ;;
    "load"|"unload")
      # Get --sh, --csh, -h, or --help arguments.
      # Space needed here becauses regexes start with a space
      # and `-h` may be the only argument.
      _a=" $@"
      # Space needed here to differentiate between `-h`
      # argument and specs with "-h" in the name.
      # Also see: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
      if [ "${_a#* --sh}" != "$_a" ] || \
        [ "${_a#* --csh}" != "$_a" ] || \
        [ "${_a#* -h}" != "$_a" ] || \
        [ "${_a#* --help}" != "$_a" ];
            then
              # Args contain --sh, --csh, or -h/--help: just execute.
              @spack@ $_sp_flags $_sp_subcommand "$@"
            else
              eval $(@spack@ $_sp_flags $_sp_subcommand --sh "$@" || \
                echo "return 1")  # return 1 if spack command fails
      fi
      ;;
    *)
      @spack@ $_sp_flags $_sp_subcommand "$@"
      ;;
  esac
}

spack_wrapper_fun $@

