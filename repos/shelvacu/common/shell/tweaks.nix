{ lib, ... }:
let
  shopts = {
    # keep-sorted start
    # default; I don't fully understand the implications of this, so leaving it
    array_expand_once = false;
    # default; i think it encourages bad habits
    autocd = false;
    # default; very bad habits
    cdable_vars = false;
    # default; this seems potentially convenient, but also potentially very confusing when I assume the thing I typed exists but it doesn't
    cdspell = false;
    # not default; "hey you're still running stuff", we'll see how annoying it is
    checkjobs = true;
    # default; seems reasonable
    checkwinsize = true;
    # default; vacu-shell-history properly supports multiline
    cmdhist = true;
    compat31 = null;
    compat32 = null;
    compat40 = null;
    compat41 = null;
    compat42 = null;
    compat43 = null;
    compat44 = null;
    complete_fullquote = null; # set by completion stuff
    # default; only expands if the dir exists? i find this confusing. also makes dirs full paths which is annoying
    direxpand = false;
    # default; no spellcheck
    dirspell = false;
    # not default; glob should glob! *slams fist*
    dotglob = true;
    # not default; (for interactive sessions) exec should exec V:
    execfail = true;
    # default; sure aliases are fine
    expand_aliases = true;
    extdebug = null; # if something wants to set it before me, let it be set
    # not default; moar pattern
    extglob = true;
    # default
    extquote = true;
    # not default
    failglob = true;
    force_fignore = null; # idk
    # not default; more consistent globbing
    globasciiranges = true;
    # default; this just makes sense
    globskipdots = false;
    # not default; very useful and ** means nothing without
    globstar = true;
    # not default; very simple difference, seems slightly better
    #   gnu_errfmt unset: `demo.sh: line 2: nonexistent_command: command not found`
    #   gnu_errfmt   set: `demo.sh:2: nonexistent_command: command not found`
    gnu_errfmt = true;
    # default; I keep track of history with vacu-shell-history so dont need this
    histappend = false;
    histreedit = null; # doesn't matter, histexpand is disabled
    # not default; if i ever do enable histexpand this will be what i want
    histverify = true;
    # default; idk whatever
    hostcomplete = true;
    # not default; this will be slightly annoying to get used to be brings it inline with when bash is given a HUP
    huponexit = true;
    inherit_errexit = null; # not relevant for interactive shell where i dont set errexit
    # default; I have a habit of `ctrl`-`A`, `#`, `Enter` to 'save' a command in the history
    interactive_comments = true;
    # default; allows setting vars in the final part of a pipe but meh, bash is just bad, if i need this ill stop using bash
    lastpipe = false;
    # not default; history should be accurate
    lithist = true;
    # persnickety details of how variables act; keep it default to match non-interactive
    localvar_inherit = null;
    localvar_unset = null;
    login_shell = null; # cant be changed
    # default; i dont use bash's mail stuff
    mailwarn = false;
    # not default; i dont see any reason id want to tabcomplete all possible commands
    no_empty_cmd_completion = true;
    # default; be exact
    nocaseglob = false;
    # default; be exact
    nocasematch = false;
    noexpand_translation = null; # i will never use this except to test what will happen; so keep it default
    # default; errglob is set so this doesnt matter; if for some reason it isnt then prefer expanding to a file that doesnt exist
    nullglob = false;
    # default
    patsub_replacement = true;
    # default; yeah i want completion
    progcomp = true;
    # default; doesn't seem to work?
    progcomp_alias = false;
    # default; I make use of this
    promptvars = true;
    restricted_shell = null; # cannot be set
    shift_verbose = null; # i dont need this interactive; so keep it default
    sourcepath = null; # i ~never call source, so keep it default
    # default; allow me to manage it manually
    varredir_close = false;
    xpg_echo = null; # keep default
    # keep-sorted end
  };
  setOpts = {
    # keep-sorted start
    allexport = false;
    braceexpand = true; # the foo_{a,b,c} syntax
    emacs = true;
    errexit = false;
    errtrace = null;
    functrace = null;
    hashall = false; # always check $PATH
    histexpand = false; # rarely useful; when i want history i just press up
    history = true;
    ignoreeof = false; # nah my ctrl-D is intentional
    keyword = false; # nah env vars only go before the command
    monitor = true; # yeah i do want `cmd &` to work
    noclobber = true; # be more explicit about overwriting files
    noexec = false; # ...not very useful, and doesnt even work(?), in interactive mode
    noglob = false;
    nolog = null; # "currently ignored"
    notify = false; # don't mingle job status with command output
    nounset = true; # complain when using an unset variable
    onecmd = false; # nonsense for interactive
    physical = false; # docs are confusing but I want the current behavior
    pipefail = false;
    posix = false;
    privileged = null;
    verbose = false;
    vi = false;
    xtrace = null;
    # keep-sorted end
  };
  mkLines = opts: f: lib.pipe opts [
    (lib.filterAttrs (_: val: val != null))
    (lib.mapAttrsToList f)
    (map (s: s + "\n"))
    (lib.concatStrings)
  ];
  shoptLines = mkLines shopts (name: val: "shopt ${if val then "-s" else "-u"} ${lib.escapeShellArg name}");
  setLines = mkLines setOpts (name: val: "set ${if val then "-o" else "+o"} ${lib.escapeShellArg name}"); 
in
{
  vacu.shell.idempotentShellLines = shoptLines + setLines;
}
