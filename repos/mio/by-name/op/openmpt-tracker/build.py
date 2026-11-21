#!/usr/bin/env python3
"""Build OpenMPT's premake-generated .vcxproj projects with the MSVC tools under Wine.

There is no MSBuild (and no .NET) here: the `Release|x64` ItemDefinitionGroups
are translated into cl.exe / lib.exe / link.exe / rc.exe command lines directly,
which is enough because the generated projects are plain compile+link graphs.

Requires MSVC_ROOT to point at an msvc-wine install (VC/Tools/MSVC/..., kits/)
and cl/lib/link/rc on PATH.
"""
import argparse
import concurrent.futures
import glob
import os
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

NS = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
COND = "'Release|x64'"
MSVC_ROOT = os.environ.get("MSVC_ROOT", "")
# Healed copies of MFC's resource scripts; populated by heal_mfc_rc() because
# the ones shipped with ATL/MFC are unusable by rc.exe (see below).
MFC_RC_DIR = os.environ.get("MPT_MFC_RC_DIR", "")


def _msvc_lib(name):
    """Locate a library inside the installed MSVC tree (atlmfc or the CRT dir)."""
    for pat in ("vc/tools/msvc/*/atlmfc/lib/x64/" + name, "vc/tools/msvc/*/lib/x64/" + name):
        hits = glob.glob(os.path.join(MSVC_ROOT, pat))
        if hits:
            return hits[0]
    return name


def _decode_mixed_utf16(data):
    """Decode MFC's resource scripts, which mix UTF-16LE and UTF-16BE lines.

    The shipped files have a BOM but their 2-byte units are partly written
    big-endian, so a normal decode produces garbage and rc.exe stops with
    RC2255. Each ASCII byte is paired with a zero half, so dropping the zero
    bytes recovers the text whatever endianness a line used.
    """
    body = data[2:] if data[:2] in (b"\xff\xfe", b"\xfe\xff") else data
    # Each ASCII byte is paired with a zero half, whichever endianness that
    # line happened to use, so dropping the zero bytes recovers the text
    # regardless of where the file switches endianness.
    return bytes(b for b in body if b).decode("latin-1")


def heal_mfc_rc(dest):
    """Write rc.exe-usable copies of MFC's *.rc files into dest; return dest."""
    hits = glob.glob(os.path.join(MSVC_ROOT, "vc/tools/msvc/*/atlmfc/include"))
    if not hits:
        raise SystemExit(f"error: no atlmfc/include under MSVC_ROOT={MSVC_ROOT!r}")
    os.makedirs(dest, exist_ok=True)
    for path in sorted(glob.glob(os.path.join(hits[0], "*.rc"))):
        with open(path, "rb") as f:
            data = f.read()
        text = _decode_mixed_utf16(data)
        with open(os.path.join(dest, os.path.basename(path)), "w") as f:
            f.write(text)
    return dest


def excluded(el):
    """True when ExcludedFromBuild is set for this configuration."""
    for e in el:
        if e.tag.split("}")[1] != "ExcludedFromBuild":
            continue
        cond = e.get("Condition", "")
        if cond and COND not in cond:
            continue
        if (e.text or "").strip().lower() == "true":
            return True
    return False


def load(proj):
    root = ET.parse(proj).getroot()
    pdir = os.path.dirname(os.path.abspath(proj))
    cfg = {
        "name": os.path.splitext(os.path.basename(proj))[0],
        "dir": pdir,
        "cc": {},
        "link": {},
        "rc": {},
        "items": [],
        "rcitems": [],
        "refs": [],
    }
    for g in root.findall("m:PropertyGroup", NS):
        if COND not in g.get("Condition", ""):
            continue
        for e in g:
            t = e.tag.split("}")[1]
            if t in ("ConfigurationType", "TargetName", "TargetExt"):
                cfg[t] = (e.text or "").strip()
    for g in root.findall("m:ItemDefinitionGroup", NS):
        if COND not in g.get("Condition", ""):
            continue
        for cat, key in (("ClCompile", "cc"), ("Link", "link"), ("ResourceCompile", "rc")):
            c = g.find(f"m:{cat}", NS)
            if c is None:
                continue
            for e in c:
                cfg[key][e.tag.split("}")[1]] = (e.text or "").strip()
    for ig in root.findall("m:ItemGroup", NS):
        for c in ig:
            t = c.tag.split("}")[1]
            over = {e.tag.split("}")[1]: (e.text or "").strip() for e in c}
            if t in ("ClCompile", "ResourceCompile"):
                if excluded(c):
                    continue
                if c.get("Condition") and COND not in c.get("Condition"):
                    continue
                (cfg["items"] if t == "ClCompile" else cfg["rcitems"]).append((c.get("Include"), over))
            elif t == "ProjectReference":
                cfg["refs"].append(c.get("Include"))
    return cfg


def expand(s, objdir, pdir):
    return (
        s.replace("$(IntDir)", os.path.abspath(objdir) + "/")
        .replace("$(ProjectDir)", os.path.abspath(pdir) + "/")
        .replace("$(SolutionDir)", os.path.abspath(pdir) + "/")
        .replace("$(OutDir)", os.path.abspath(objdir) + "/")
    )


def cc_flags(props, objdir, pdir="", cplusplus=True, no_pch=False):
    f = ["/nologo", "/c", "/W0"]
    f += {
        "Disabled": ["/Od"],
        "MinSpace": ["/O1"],
        "MaxSpeed": ["/O2"],
        "Full": ["/Ox"],
    }.get(props.get("Optimization", ""), ["/O2"])
    if props.get("IntrinsicFunctions", "").lower() == "true":
        f.append("/Oi")
    if props.get("StringPooling", "").lower() == "true":
        f.append("/GF")
    if props.get("FunctionLevelLinking", "").lower() == "true":
        f.append("/Gy")
    f += {
        "MultiThreaded": ["/MT"],
        "MultiThreadedDLL": ["/MD"],
        "MultiThreadedDebug": ["/MTd"],
        "MultiThreadedDebugDLL": ["/MDd"],
    }.get(props.get("RuntimeLibrary", ""), ["/MT"])
    if cplusplus:
        f += {
            "stdcpp20": ["/std:c++20"],
            "stdcpp17": ["/std:c++17"],
            "stdcpplatest": ["/std:c++latest"],
        }.get(props.get("LanguageStandard", ""), ["/std:c++20"])
    elif props.get("LanguageStandard_C"):
        f.append({"stdc17": "/std:c17", "stdc11": "/std:c11"}.get(props["LanguageStandard_C"], "/std:c17"))
    if props.get("ConformanceMode", "").lower() == "true":
        f.append("/permissive-")
    if props.get("UseStandardPreprocessor", "").lower() == "true":
        f.append("/Zc:preprocessor")
    if cplusplus and props.get("ExceptionHandling") != "Off":
        f.append("/EHsc")
    if props.get("DebugInformationFormat") in ("ProgramDatabase", "EditAndContinue"):
        # embedded, avoids running mspdbsrv under Wine
        f.append("/Z7")
    defs = [d for d in props.get("PreprocessorDefinitions", "").split(";") if d and "%(" not in d]
    f += ["/D" + d for d in defs]
    f += [
        "/I" + expand(i, objdir, pdir)
        for i in props.get("AdditionalIncludeDirectories", "").split(";")
        if i and "%(" not in i
    ]
    pch = props.get("PrecompiledHeader", "")
    hdr = props.get("PrecompiledHeaderFile") or "PCH.h"
    if pch in ("Use", "Create") and not no_pch:
        # "/Yc" + hdr must not be quoted: the wrapper passes the quotes through.
        f.append(("/Yu" if pch == "Use" else "/Yc") + hdr)
        f.append("/Fp" + os.path.join(objdir, "pch.pch"))
    f += ["/FI" + x for x in props.get("ForcedIncludeFiles", "").split(";") if x]
    f += [t for t in props.get("AdditionalOptions", "").split() if "%(" not in t]
    return f


def pch_flags(props, objdir, pdir=""):
    """Flags for the /Yc translation unit: no /FI, otherwise cl reports C2857."""
    props = dict(props)
    props["ForcedIncludeFiles"] = ""
    return cc_flags(props, objdir, pdir)


def run(cmd, cwd, log):
    log.write("$ " + " ".join(cmd) + "\n")
    log.flush()
    p = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    log.write(p.stdout)
    log.flush()
    return p.returncode, p.stdout


def batch(items, n):
    for i in range(0, len(items), n):
        yield items[i : i + n]


def build_project(proj, outroot, jobs, log, only=None, no_pch=False):
    cfg = load(proj)
    name, pdir = cfg["name"], cfg["dir"]
    objdir = os.path.join(outroot, "obj", name)
    os.makedirs(objdir, exist_ok=True)
    # svn_version stub expected by the projects
    svnd = os.path.join(objdir, "svn_version")
    os.makedirs(svnd, exist_ok=True)
    stub = os.path.join(pdir, "..", "svn_version", "svn_version.h")
    if os.path.isfile(stub):
        shutil.copyfile(stub, os.path.join(svnd, "svn_version.h"))
    inc = [i for i in cfg["cc"].get("AdditionalIncludeDirectories", "").split(";") if i and "%(" not in i]
    cfg["cc"]["AdditionalIncludeDirectories"] = ";".join(inc + [svnd])
    cfg["rc"]["AdditionalIncludeDirectories"] = ";".join(
        [i for i in cfg["rc"].get("AdditionalIncludeDirectories", "").split(";") if i and "%(" not in i]
        + inc
        + [svnd]
    )

    pch_items, normal = [], []
    for inc_path, over in cfg["items"]:
        if over.get("PrecompiledHeader") == "Create" and not no_pch:
            pch_items.append((inc_path, over))
        else:
            normal.append((inc_path, over))

    def obj_exists(rel):
        return os.path.exists(os.path.join(objdir, os.path.splitext(os.path.basename(rel))[0] + ".obj"))

    normal = [(p, o) for p, o in normal if not obj_exists(p)]
    if only:
        normal = normal[:only]

    base = cc_flags(cfg["cc"], objdir, pdir, no_pch=no_pch)
    base_c = cc_flags(cfg["cc"], objdir, pdir, cplusplus=False, no_pch=no_pch)

    def lang_of(rel):
        return "c" if os.path.splitext(rel)[1].lower() == ".c" else "cpp"

    rc = 0
    for inc_path, over in pch_items:
        props = dict(cfg["cc"])
        props.update({k: v for k, v in over.items() if k in ("PrecompiledHeader", "PrecompiledHeaderFile")})
        cmd = ["cl"] + pch_flags(props, objdir, pdir) + ["/Fo" + objdir + "\\", inc_path]
        rc, out = run(cmd, pdir, log)
        print(f"[{name}] pch rc={rc}")
        if rc:
            print(out[-3000:])
            return rc

    def work(group):
        flags = base_c if lang_of(group[0]) == "c" else base
        return run(["cl"] + flags + ["/MP", "/Fo" + objdir + "\\"] + group, pdir, log)

    groups = []
    for lang in ("c", "cpp"):
        groups += list(batch([p for p, _ in normal if lang_of(p) == lang], 6))

    failures = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for (rc, out), group in zip(ex.map(work, groups), groups):
            if rc:
                failures.append((group, out))
    if failures:
        for group, out in failures[:2]:
            print(f"[{name}] FAILED {len(group)} files, e.g. {group[0]}")
            print(out[-4000:])
        return 1
    print(f"[{name}] compiled {sum(len(g) for g in groups)} files")
    return 0


def make_output(cfg, objdir, libdir, bindir, log):
    """Static library, or DLL plus import library, depending on the project."""
    objs = sorted(f for f in os.listdir(objdir) if f.lower().endswith(".obj"))
    if not objs:
        print(f"[{cfg['name']}] no objects")
        return 1
    os.makedirs(libdir, exist_ok=True)
    out = os.path.join(libdir, cfg["name"] + ".lib")
    objwin = [os.path.join(objdir, o) for o in objs]
    if cfg.get("ConfigurationType") == "DynamicLibrary":
        os.makedirs(bindir, exist_ok=True)
        target = cfg.get("TargetName", cfg["name"])
        dll = os.path.join(bindir, target + cfg.get("TargetExt", ".dll"))
        cmd = ["link", "/nologo", "/DLL", "/OUT:" + dll, "/IMPLIB:" + out]
        if cfg["link"].get("ModuleDefinitionFile"):
            cmd.append("/DEF:" + cfg["link"]["ModuleDefinitionFile"])
        cmd += [
            os.path.join(libdir, os.path.splitext(os.path.basename(r.replace("\\", "/")))[0] + ".lib")
            for r in cfg["refs"]
        ]
        cmd += objwin
        rc, o = run(cmd, cfg["dir"], log)
        print(f"[{cfg['name']}] dll rc={rc} ({len(objs)} objs)")
    else:
        cmd = ["lib", "/nologo", "/OUT:" + out] + objwin
        rc, o = run(cmd, cfg["dir"], log)
        print(f"[{cfg['name']}] lib rc={rc} ({len(objs)} objs)")
    if rc:
        print(o[-2000:])
    return rc


def build_rc(cfg, outdir, log, mfc_rc_dir=None):
    res = os.path.join(outdir, cfg["name"] + ".res")
    rcp = cfg["rc"]
    # Defines come straight from the XML, which escapes quotes as \" ; rc.exe
    # reads a backslash before a quote as a line continuation (RC2104).
    defs = [
        d.replace('\\"', '"') for d in rcp.get("PreprocessorDefinitions", "").split(";") if d and "%(" not in d
    ]
    incs = [i for i in rcp.get("AdditionalIncludeDirectories", "").split(";") if i and "%(" not in i]
    if mfc_rc_dir and os.path.isdir(mfc_rc_dir):
        incs.insert(0, mfc_rc_dir)
    cmd = ["rc", "/nologo", "/fo" + res]
    cmd += ["/d" + d for d in defs]
    cmd += ["/i" + i for i in incs]
    cmd += [p for p, _ in cfg["rcitems"]]
    rc, o = run(cmd, cfg["dir"], log)
    print(f"[{cfg['name']}] rc rc={rc}")
    if rc:
        print(o[-3000:])
    return rc, res


def link_exe(cfg, out, libdir, log, res=None):
    objdir = os.path.join(out, "obj", cfg["name"])
    objs = [os.path.join(objdir, o) for o in sorted(os.listdir(objdir)) if o.lower().endswith(".obj")]
    bindir = os.path.join(out, "bin")
    os.makedirs(bindir, exist_ok=True)
    lk = cfg["link"]
    deps = [d for d in lk.get("AdditionalDependencies", "").split(";") if d and "%(" not in d]
    if not deps:
        # Static MFC: afxnmcd (the no-MFC-controls-in-dialogs variant) must come
        # before nafxcw, exactly as afx.h's #pragma comment(lib, ...) order does.
        deps = [_msvc_lib("afxnmcd.lib"), _msvc_lib("nafxcw.lib"), _msvc_lib("libcmt.lib")]
    cmd = ["link", "/nologo", "/SUBSYSTEM:WINDOWS", "/MACHINE:X64"]
    cmd.append("/OUT:" + os.path.join(bindir, cfg["name"] + ".exe"))
    cmd.append("/LIBPATH:" + libdir)
    if lk.get("GenerateDebugInformation", "").lower() == "true":
        cmd.append("/DEBUG")
    if lk.get("OptimizeReferences", "").lower() == "true":
        cmd.append("/OPT:REF")
    if lk.get("EnableCOMDATFolding", "").lower() == "true":
        cmd.append("/OPT:ICF")
    if lk.get("LargeAddressAware", "").lower() == "true":
        cmd.append("/LARGEADDRESSAWARE")
    cmd += [t for t in lk.get("AdditionalOptions", "").split() if "%(" not in t]
    cmd += objs
    if res:
        cmd.append(res)
    for r in cfg["refs"]:
        name = os.path.splitext(os.path.basename(r.replace("\\", "/")))[0]
        cmd.append(os.path.join(libdir, name + ".lib"))
    cmd += deps
    # MFC's headers auto-link a different static-MFC variant than the one above.
    have = {os.path.basename(d).lower() for d in deps}
    cmd += ["/NODEFAULTLIB:" + x for x in ("afxnmcd.lib", "nafxcw.lib", "uafxcw.lib", "msvcrt.lib") if x not in have]
    rc, o = run(cmd, cfg["dir"], log)
    print(f"[{cfg['name']}] link rc={rc}")
    if rc:
        print(o[-4000:])
    return rc


def build_all(src, out, jobs, log, no_pch):
    vsdir = os.path.join(src, "build", "vs2022win10")
    gui_path = os.path.join(vsdir, "OpenMPT.vcxproj")
    gui = load(gui_path)
    libdir = os.path.join(out, "lib")
    seen, projs = set(), []
    for r in gui["refs"]:
        p = os.path.normpath(os.path.join(vsdir, r.replace("\\", "/")))
        if p in seen:
            continue
        seen.add(p)
        if os.path.isfile(p):
            projs.append(p)
        else:
            print(f"missing project ref: {p}")
    pending = {p: load(p) for p in projs}
    ordered = []
    done = set()
    # mpg123/lame produce DLLs plus import libs, so a project that references
    # them must be linked after its own dependency exists.
    while pending:
        progressed = False
        for p, cfg in list(pending.items()):
            deps = [
                os.path.normpath(os.path.join(os.path.dirname(p), r.replace("\\", "/"))) for r in cfg["refs"]
            ]
            if all(d in done or d not in pending for d in deps):
                ordered.append((p, cfg))
                done.add(p)
                del pending[p]
                progressed = True
        if not progressed:
            ordered += list(pending.items())
            break
    for p, cfg in ordered:
        print(f"=== {cfg['name']}")
        if build_project(p, out, jobs, log, no_pch=no_pch):
            print(f"[{cfg['name']}] COMPILE FAILED")
            return 1
        if make_output(cfg, os.path.join(out, "obj", cfg["name"]), libdir, os.path.join(out, "bin"), log):
            return 1
    print("=== OpenMPT (GUI)")
    if build_project(gui_path, out, jobs, log, no_pch=no_pch):
        return 1
    rc, res = build_rc(gui, out, log, MFC_RC_DIR)
    if rc:
        return 1
    return link_exe(gui, out, libdir, log, res)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--project", default="OpenMPT")
    ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--only", type=int, default=0)
    ap.add_argument("--no-pch", action="store_true")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--link-only", action="store_true")
    ap.add_argument("--heal-mfc-rc", metavar="DIR", help="write healed MFC resource scripts to DIR and exit")
    a = ap.parse_args()
    global MFC_RC_DIR
    if a.heal_mfc_rc:
        print(heal_mfc_rc(a.heal_mfc_rc))
        return 0
    if not MSVC_ROOT:
        raise SystemExit("error: set MSVC_ROOT to an msvc-wine installation")
    if not MFC_RC_DIR:
        MFC_RC_DIR = heal_mfc_rc(os.path.join(a.out, "mfc-rc"))
    proj = os.path.join(a.src, "build", "vs2022win10", a.project + ".vcxproj")
    os.makedirs(a.out, exist_ok=True)
    with open(os.path.join(a.out, "build.log"), "w") as log:
        if a.all:
            return build_all(a.src, a.out, a.jobs, log, a.no_pch)
        if a.link_only:
            gui = load(proj)
            rc, res = build_rc(gui, a.out, log, MFC_RC_DIR)
            if rc:
                return rc
            return link_exe(gui, a.out, os.path.join(a.out, "lib"), log, res)
        return build_project(proj, a.out, a.jobs, log, a.only, a.no_pch)


if __name__ == "__main__":
    sys.exit(main())
