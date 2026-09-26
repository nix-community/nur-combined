#!/usr/bin/env python3
"""Quick diff helper for sass-spec failures."""
import json, os, subprocess, sys, tempfile
from pathlib import Path
from collections import Counter, defaultdict

HERE = Path(__file__).resolve().parent
RESULTS = HERE / "results.json"
SUITE = HERE / "sass-spec" / "spec"
SASS_BIN = HERE.parent / "target" / "release" / "sasso"

def find_case_files(name):
    # name format: archive_id:subdir or just dir path
    if ":" in name:
        archive_id, sub = name.split(":", 1)
        archive_path = SUITE / (archive_id + ".hrx")
        if archive_path.exists():
            # parse hrx
            text = archive_path.read_text(encoding="utf-8")
            files = {}
            cur_path = None
            cur_lines = []
            import re
            marker = re.compile(r"^<===> ?(.*)$")
            def flush():
                if cur_path is not None:
                    body = "\n".join(cur_lines)
                    if body.endswith("\n"):
                        body = body[:-1]
                    files[cur_path] = body
            for line in text.split("\n"):
                m = marker.match(line)
                if m:
                    flush()
                    p = m.group(1).strip()
                    cur_path = p if p else None
                    cur_lines = []
                else:
                    if cur_path is not None:
                        cur_lines.append(line)
            flush()
            # find input in subdir
            for ext in ("input.scss", "input.sass"):
                key = f"{sub}/{ext}" if sub else ext
                if key in files:
                    input_text = files[key]
                    input_name = ext
                    break
            else:
                return None
            # expected output
            out_key = f"{sub}/output.css" if sub else "output.css"
            err_key = f"{sub}/error" if sub else "error"
            expected = files.get(out_key)
            expects_error = err_key in files
            return input_text, input_name, expected, expects_error, files
    else:
        d = SUITE / name
        for ext in ("input.scss", "input.sass"):
            inp = d / ext
            if inp.exists():
                input_text = inp.read_text(encoding="utf-8")
                input_name = ext
                break
        else:
            return None
        expected = (d / "output.css").read_text(encoding="utf-8") if (d / "output.css").exists() else None
        expects_error = (d / "error").exists()
        files = {f.name: f.read_text(encoding="utf-8") for f in d.iterdir() if f.is_file()}
        return input_text, input_name, expected, expects_error, files
    return None

def main():
    cases = json.load(open(RESULTS))['cases']
    fails = [c for c in cases if c['status'] == 'FAIL']
    # group by top dir
    groups = defaultdict(list)
    for c in fails:
        top = c['name'].split('/')[0].split(':')[0]
        groups[top].append(c['name'])

    for top, names in sorted(groups.items(), key=lambda x: -len(x[1])):
        print(f"\n{'='*60}")
        print(f"GROUP: {top} ({len(names)} failures)")
        print(f"{'='*60}")
        for name in names[:3]:
            print(f"\n--- {name} ---")
            info = find_case_files(name)
            if not info:
                print("  (could not locate case files)")
                continue
            input_text, input_name, expected, expects_error, files = info
            with tempfile.TemporaryDirectory() as td:
                tdp = Path(td)
                in_path = tdp / input_name
                in_path.write_text(input_text, encoding="utf-8")
                for k, v in files.items():
                    if k in ("input.scss", "input.sass", "output.css", "error", "options.yml"):
                        continue
                    (tdp / k).write_text(v, encoding="utf-8")
                cmd = [str(SASS_BIN), f"--style=expanded", str(in_path)]
                try:
                    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                except Exception as e:
                    print(f"  run error: {e}")
                    continue
                got = proc.stdout
                if expects_error:
                    if proc.returncode == 0:
                        print(f"  EXPECTED ERROR but compiled successfully")
                        print(f"  stdout: {got[:400]}")
                    else:
                        print(f"  expected error, got error (rc={proc.returncode}) — PASS?")
                else:
                    if proc.returncode != 0:
                        print(f"  UNEXPECTED ERROR (rc={proc.returncode})")
                        print(f"  stderr: {proc.stderr[:400]}")
                    else:
                        # diff
                        if got.strip() == expected.strip():
                            print("  Actually PASS now (maybe stale results?)")
                        else:
                            print(f"  DIFF (expected vs got):")
                            # simple line diff
                            exp_lines = expected.strip().splitlines()
                            got_lines = got.strip().splitlines()
                            max_len = max(len(exp_lines), len(got_lines))
                            for i in range(max_len):
                                e = exp_lines[i] if i < len(exp_lines) else "<EOF>"
                                g = got_lines[i] if i < len(got_lines) else "<EOF>"
                                if e != g:
                                    print(f"    [{i}] exp: {e}")
                                    print(f"    [{i}] got: {g}")
                                    if i > 5:
                                        print("    ...")
                                        break

if __name__ == "__main__":
    main()
