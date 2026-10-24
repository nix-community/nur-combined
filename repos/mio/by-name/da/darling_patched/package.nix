{
  darling,
  coreutils,
  fetchFromGitHub,
  fetchpatch,
  lib,
}:

# Upstream darling, plus open PRs that apply on that commit:
# Clang/CMake/DESTDIR build fixes, SysV semaphore IDs, libc++ filesystem
# symbols, and host-path linking (darpath).
# Drafts, ARM64 ports, Docker/RPM packaging, off-by-default options, and the
# GLUT/MediaLibrary stubs are not included.
let
  # Same owner/repo as the Darling submodules. Applied by replacing the
  # already-fetched trees; a gitlink-only patch cannot update them.
  submodule =
    {
      repo,
      rev,
      hash,
      fetchSubmodules ? false,
    }:
    fetchFromGitHub {
      owner = "darlinghq";
      name = "${repo}-src";
      inherit
        repo
        rev
        hash
        fetchSubmodules
        ;
    };

  submodules = {
    # https://github.com/darlinghq/darling/pull/1801
    "src/external/cctools-port" = submodule {
      repo = "cctools-port";
      rev = "e762c084b585943eaca9db29080972e3a2804f4f";
      hash = "sha256-Uh6K9r2xwou7zHwbVq1Sl9Dh2BX6Rmd5DHdLcZIhmjI=";
    };
    # https://github.com/darlinghq/darling/pull/1799
    # indium is a nested submodule; the LLVM 23 opcode change is version-gated.
    "src/external/metal" = submodule {
      repo = "darling-metal";
      rev = "5165c9ed0b18809a6d0ecd3b86c294a153e5fdb6";
      hash = "sha256-xvkg4l11sIE6i1HNGqacRuZck3Wg7/pYfhkUeSa5+JM=";
      fetchSubmodules = true;
    };
    # https://github.com/darlinghq/darling/pull/1798
    "src/external/objc4" = submodule {
      repo = "darling-objc4";
      rev = "092352cab947b410a73b5123b190df03f90c1802";
      hash = "sha256-SEzSDIspitSGlJ7JDan0lkbz0Bp0p43iY2T6fSvWgY8=";
    };
    # https://github.com/darlinghq/darling/pull/1793
    "src/external/libcxx" = submodule {
      repo = "darling-libcxx";
      rev = "7d5d86d3546aea24b50c38ad25a0d141ee5271d8";
      hash = "sha256-n2zVSU03GIQNqRR1zIJWoKzIJIf2ZPq4VfvXuqUWhgI=";
    };
    # https://github.com/darlinghq/darling/pull/1792
    "src/external/file_cmds" = submodule {
      repo = "darling-file_cmds";
      rev = "35f7c7e689afc4bba78058eee8d9d76c2f59e368";
      hash = "sha256-990uti0RjrGNfd2i+uBMQQqO8p/U8JqxvmQ3Eo4MMpY=";
    };
    # https://github.com/darlinghq/darling/pull/1790
    "src/external/xnu" = submodule {
      repo = "darling-xnu";
      rev = "ba9627345b7a7c84a3dfd3c710059407cc771276";
      hash = "sha256-jxqUbnwx3yfxwTxj8fQXrowjh5p5aoEz7E+YI5EbZwI=";
    };
  };

  pr =
    name: rev: hash: extra:
    fetchpatch (
      {
        inherit name hash;
        url = "https://github.com/Tatsh/darling/commit/${rev}.patch";
      }
      // extra
    );
in
darling.overrideAttrs (old: {
  pname = "darling_patched";

  patches = [
    # https://github.com/darlinghq/darling/pull/1791
    (pr "darling-pr-1791-asm-static-libraries.patch" "764ef432933d2c10cd293a32fed3530366fcb69b"
      "sha256-NEmwzXsl4S9Ci6nqZsAc5DRDARJUVssZw67+nmHGMYI="
      { }
    )
    # https://github.com/darlinghq/darling/pull/1792
    # The file_cmds half is a submodule bump, swapped in below.
    (pr "darling-pr-1792-destdir.patch" "65c5bf55f9d9d4124f6bfc89d3e8fecff38d1438"
      "sha256-3wOgVkVY346x5fgwrjM3CgvVGunuOUghXunZ5981aOk="
      {
        excludes = [ "src/external/file_cmds" ];
      }
    )
    # https://github.com/darlinghq/darling/pull/1794
    (pr "darling-pr-1794-mig-fail.patch" "77997c9141a1225495c9acd6db10e1dd55938df4"
      "sha256-/jcNFlgjSfxf22FKVyfmcEiFgb1epCw+mzHysqIxbxo="
      { }
    )
    # https://github.com/darlinghq/darling/pull/1795
    (pr "darling-pr-1795-no-objc-constant-literals.patch" "8a226a0b439e8cf9549704fe008791df799cd293"
      "sha256-SnBJBO6Mw/tPzX9Cvdnf2w+0jWNI+CTnkiq72lJuQMY="
      { }
    )
    # https://github.com/darlinghq/darling/pull/1800
    (pr "darling-pr-1800-cross-compiling.patch" "b7a065afaed919e243da80ae9041d094bc70a23d"
      "sha256-4jat8UkJCnTN3PfJzdhCHboYkXEt4QHcmY6FQqEfGio="
      { }
    )
    # https://github.com/darlinghq/darling/pull/1802
    (pr "darling-pr-1802-link-host-directories.patch" "08f6a7e1f1f97f099e8d49f96486b1110f7682c8"
      "sha256-vf73lznXXuKj38tjHinoXposzZvusfOO4E6m1dNLYqQ="
      { }
    )
    # https://github.com/darlinghq/darling/pull/1803
    (pr "darling-pr-1803-darpath.patch" "7cbcfd25f915068d61acb90840f8d82d7a53b926"
      "sha256-A5Hwtks1Bsw9GuJtizQLIhSTRjbHGLpih8Ei/j1C6AM="
      { }
    )
  ];

  postPatch =
    old.postPatch
    + ''
      # Nix has no /bin/mkdir. A bare `mkdir` is also a Darling target, so CMake
      # would turn the MIG custom command into a dependency cycle. PR 1794 stops
      # ignoring a failing mkdir, which is what hid this.
      substituteInPlace cmake/mig.cmake --replace-fail /bin/mkdir ${coreutils}/bin/mkdir

      replace_submodule() {
        local dest=$1 src=$2
        chmod -R u+w "$dest"
        rm -rf "$dest"
        cp -a "$src" "$dest"
        # cp -a keeps the store mode, and later phases rewrite config.sub in place.
        chmod -R u+w "$dest"
      }
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (path: src: ''
        replace_submodule ${path} ${src}
      '') submodules
    );

  # PR 1798 derives OBJC_IS_DEBUG_BUILD from NDEBUG, so Release is usable.
  cmakeBuildType = "Release";

  # In-prefix darpath embeds LIBEXEC_PATH, which is the Nix install prefix, so it
  # can map paths onto the installed files. mldr is already excluded for its rpath.
  postFixup =
    builtins.replaceStrings [ "--exclude=mldr" ] [ "--exclude=mldr --exclude=darpath" ]
      old.postFixup;

  meta = old.meta // {
    description = "Darling with open pull requests for Clang, DESTDIR installs, semaphores, and host paths";
  };
})
