#!/usr/bin/env python3
"""Darwin arm64 asm adjustments for ART.

1. ENTRY labels stay non-global so Darwin allows b.cond/cbz to same-file labels.
2. C-callable ENTRY points get an explicit Mach-O alias `_name = name`.
3. `bl` to C/C++ callees (art*, fmod, and macro args) get a leading `_`.
"""
from __future__ import annotations

import re
from pathlib import Path


def fix_entry(text: str) -> str:
    def repl(_m: re.Match[str]) -> str:
        # Local label for Darwin b.cond/cbz; Mach-O C alias for callers.
        return (
            ".macro ENTRY name\n"
            "    /* Cache alignment for function entry */\n"
            "    .balign 16\n"
            "\\name:\n"
            "    .globl _\\name\n"
            "    _\\name = \\name\n"
            ".endm"
        )

    return re.sub(r"^\.macro ENTRY.*?^\.endm", repl, text, flags=re.M | re.S)


# Asm-local Mterp labels in main.S (not C). Tail-call C helper is MterpCheckBefore only.
_ASM_LOCAL_MTERP = re.compile(
    r"^(mterp_op_|MterpCommon|MterpHelpers|MterpFallback|MterpDone|"
    r"MterpException|MterpReturn|MterpSuspend|MterpPossible|"
    r"MterpCheckSuspend|MterpOnStack|MterpProfile|common_)"
)
_C_TAIL_CALLS = {"MterpCheckBefore"}


def should_underscore_c_call(name: str, *, is_bl: bool) -> bool:
    """Whether a branch/call target is a C/C++ symbol needing a Mach-O '_' prefix."""
    if not name or name.startswith(("_", ".")) or name[0].isdigit():
        return False
    # Template args ($helper) expand to C function names.
    if name.startswith("$"):
        return True
    # Macro parameters: only known C-callee formals on bl; never on b (e.g. \return -> .L*).
    if name.startswith("\\"):
        return is_bl and name in {r"\cxx_name", r"\entrypoint", r"\helper"}
    if name in {
        "ExecuteMterpImpl",
        "artMterpAsmInstructionEnd",
        "artMterpAsmInstructionStart",
    }:
        return False
    # `b` to asm-local Mterp* must stay unprefixed; only known C tail calls get `_`.
    if name.startswith("Mterp"):
        if is_bl:
            return True
        return name in _C_TAIL_CALLS
    if _ASM_LOCAL_MTERP.match(name):
        return False
    # C/C++ callees from asm (art*, fmod*).
    return bool(re.match(r"^(art|fmod)", name))


def underscore(name: str, *, is_bl: bool = True) -> str:
    return ("_" + name) if should_underscore_c_call(name, is_bl=is_bl) else name


def fix_calls(text: str) -> str:
    # Python mterp templates embed calls in strings, e.g. instr="bl      fmodf".
    def repl_instr(m: re.Match[str]) -> str:
        return f'{m.group(1)}{underscore(m.group(2), is_bl=True)}{m.group(3)}'

    text = re.sub(
        r'(instr="bl\s+)([A-Za-z_$][A-Za-z0-9_]*)(")',
        repl_instr,
        text,
    )

    def repl_bl(m: re.Match[str]) -> str:
        return f"{m.group(1)}bl{m.group(2)}{underscore(m.group(3), is_bl=True)}"

    text = re.sub(
        r"(^|[\s])bl(\s+)([A-Za-z_$\\][A-Za-z0-9_]*)",
        repl_bl,
        text,
        flags=re.M,
    )

    def repl_b(m: re.Match[str]) -> str:
        return f"{m.group(1)}b{m.group(2)}{underscore(m.group(3), is_bl=False)}"

    text = re.sub(
        r"(^|[\s])b(\s+)([A-Za-z_$\\][A-Za-z0-9_]*)",
        repl_b,
        text,
        flags=re.M,
    )
    return text


def export_alias(name: str) -> str:
    return f"    .globl _{name}\n    _{name} = {name}\n"


def fix_mterp_main(text: str) -> str:
    text = re.sub(r"^[ \t]*\.global artMterpAsmInstructionEnd[ \t]*\n", "", text, flags=re.M)
    text = re.sub(r"^[ \t]*\.global artMterpAsmInstructionStart[ \t]*\n", "", text, flags=re.M)
    text = text.replace(
        "artMterpAsmInstructionEnd:",
        "artMterpAsmInstructionEnd:\n" + export_alias("artMterpAsmInstructionEnd"),
    )
    text = text.replace(
        "artMterpAsmInstructionStart = .L_op_nop",
        "artMterpAsmInstructionStart = .L_op_nop\n"
        + export_alias("artMterpAsmInstructionStart"),
    )
    return text


def fix_quick_globals(text: str) -> str:
    text = text.replace(
        ".global art_quick_read_barrier_mark_introspection_arrays",
        export_alias("art_quick_read_barrier_mark_introspection_arrays").rstrip(),
    )
    text = text.replace(
        ".global art_quick_read_barrier_mark_introspection_gc_roots",
        export_alias("art_quick_read_barrier_mark_introspection_gc_roots").rstrip(),
    )
    return text


def main() -> None:
    for root in [
        Path("art/runtime/arch/arm64"),
        Path("art/runtime/interpreter/mterp/arm64"),
    ]:
        for path in root.rglob("*.S"):
            text = fix_entry(path.read_text())
            text = fix_calls(text)
            if path.name == "main.S" and "mterp" in str(path):
                text = fix_mterp_main(text)
            elif "quick_entrypoints" in path.name or "jni_entrypoints" in path.name:
                text = fix_quick_globals(text)
            path.write_text(text)


if __name__ == "__main__":
    main()
