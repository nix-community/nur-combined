{ lib, stdenv, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "your-editor";
  version = "1303";

  src = fetchFromGitHub {
    owner = "your-editor";
    repo = "yed";
    rev = "1b044e5704fcf8de142ae1d5a6eb45728f0d91a2";
    sha256 = "BWy/icQs8hVtNeM/mCi6LOah1UG0elU/DgCmfaIPD64=";
  };

  buildInput = [ pkgs.git pkgs.gcc ];
  installPhase = ''
    runHook preInstall
    patchShebangs install.sh
    patchShebangs plugins/align/build.sh
    patchShebangs plugins/autotrim/build.sh
    patchShebangs plugins/brace_hl/build.sh
    patchShebangs plugins/builder/build.sh
    patchShebangs plugins/calc/build.sh
    patchShebangs plugins/comment/build.sh
    patchShebangs plugins/completer/build.sh
    patchShebangs plugins/ctags/build.sh
    patchShebangs plugins/cursor_word_hl/build.sh
    patchShebangs plugins/find_file/build.sh
    patchShebangs plugins/fstyle/build.sh
    patchShebangs plugins/grep/build.sh
    patchShebangs plugins/hook/build.sh
    patchShebangs plugins/indent_c/build.sh
    patchShebangs plugins/jump_stack/build.sh
    patchShebangs plugins/lang/c/build.sh
    patchShebangs plugins/lang/conf/build.sh
    patchShebangs plugins/lang/cpp/build.sh
    patchShebangs plugins/lang/glsl/build.sh
    patchShebangs plugins/lang/jgraph/build.sh
    patchShebangs plugins/lang/latex/build.sh
    patchShebangs plugins/lang/make/build.sh
    patchShebangs plugins/lang/python/build.sh
    patchShebangs plugins/lang/sh/build.sh
    patchShebangs plugins/lang/syntax/c/build.sh
    patchShebangs plugins/lang/syntax/conf/build.sh
    patchShebangs plugins/lang/syntax/cpp/build.sh
    patchShebangs plugins/lang/syntax/glsl/build.sh
    patchShebangs plugins/lang/syntax/jgraph/build.sh
    patchShebangs plugins/lang/syntax/latex/build.sh
    patchShebangs plugins/lang/syntax/python/build.sh
    patchShebangs plugins/lang/syntax/sh/build.sh
    patchShebangs plugins/lang/syntax/yedrc/build.sh
    patchShebangs plugins/lang/tools/latex/build.sh
    patchShebangs plugins/lang/yedrc/build.sh
    patchShebangs plugins/line_numbers/build.sh
    patchShebangs plugins/log_hl/build.sh
    patchShebangs plugins/macro/build.sh
    patchShebangs plugins/man/build.sh
    patchShebangs plugins/paren_hl/build.sh
    patchShebangs plugins/profile/build.sh
    patchShebangs plugins/scroll_buffer/build.sh
    patchShebangs plugins/shell_run/build.sh
    patchShebangs plugins/style_pack/build.sh
    patchShebangs plugins/style_picker/build.sh
    patchShebangs plugins/styles/acme/build.sh
    patchShebangs plugins/styles/blue/build.sh
    patchShebangs plugins/styles/bold/build.sh
    patchShebangs plugins/styles/book/build.sh
    patchShebangs plugins/styles/bullet/build.sh
    patchShebangs plugins/styles/cadet/build.sh
    patchShebangs plugins/styles/casey/build.sh
    patchShebangs plugins/styles/dalton/build.sh
    patchShebangs plugins/styles/disco/build.sh
    patchShebangs plugins/styles/doug/build.sh
    patchShebangs plugins/styles/dracula/build.sh
    patchShebangs plugins/styles/drift/build.sh
    patchShebangs plugins/styles/elise/build.sh
    patchShebangs plugins/styles/elly/build.sh
    patchShebangs plugins/styles/embark/build.sh
    patchShebangs plugins/styles/first/build.sh
    patchShebangs plugins/styles/forest/build.sh
    patchShebangs plugins/styles/gruvbox/build.sh
    patchShebangs plugins/styles/hat/build.sh
    patchShebangs plugins/styles/humanoid/build.sh
    patchShebangs plugins/styles/lab/build.sh
    patchShebangs plugins/styles/monokai/build.sh
    patchShebangs plugins/styles/mordechai/build.sh
    patchShebangs plugins/styles/moss/build.sh
    patchShebangs plugins/styles/mrjantz/build.sh
    patchShebangs plugins/styles/nord/build.sh
    patchShebangs plugins/styles/olive/build.sh
    patchShebangs plugins/styles/papercolor/build.sh
    patchShebangs plugins/styles/river/build.sh
    patchShebangs plugins/styles/sammy/build.sh
    patchShebangs plugins/styles/skyfall/build.sh
    patchShebangs plugins/styles/solarized/build.sh
    patchShebangs plugins/styles/tempus_future/build.sh
    patchShebangs plugins/styles/vt/build.sh
    patchShebangs plugins/styles/vt_light/build.sh
    patchShebangs plugins/style_use_term_bg/build.sh
    patchShebangs plugins/vimish/build.sh
    patchShebangs plugins/yedrc/build.sh
    patchShebangs plugins/ypm/build.sh

    ./install.sh -p $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Your-editor (yed) is a small and simple terminal editor core that is meant to be extended through a powerful plugin architecture";
    homepage = "https://your-editor.org/";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ uniquepointer ];
    mainProgram = "yed";
  };
}
