#!/usr/bin/env python3
'''Package build tests.

These tests build the packages defined in NUR-Kapack.
'''
import pytest
import shlex
import subprocess

def run_cmd_handle_failure(cmd, input=None):
    p = subprocess.Popen(shlex.split(cmd), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='utf-8')
    out, err = p.communicate(input=input)
    if p.returncode != 0:
        print(f'process failed: {cmd}')
        if input: print(f"stdin:\n--- BEGIN OF STDIN LOG ---\n{input}\n--- END OF STDIN LOG---")
        if out: print(f"stdout: {out}")
        if err: print(f"stderr: {err}")
        raise Exception(f'Process failed (returned {p.returncode})')
    return p

def test_build(request, attribute, graph):
    # build dependencies and push them to cachix
    cachix_name = request.config.getoption("--cachix-name")
    debug_str = "true" if request.config.getoption("--debug-build") else "false"
    if request.config.getoption("--push-deps-on-cachix"):
        echo_cmd = f'echo "entered nix-shell of attribute {attribute}"'
        run_cmd_handle_failure(f"nix-shell -A {attribute} --arg debug {debug_str} --command '{echo_cmd}'")

        input_paths = '\n'.join(graph[attribute]["inputs"])
        run_cmd_handle_failure(f"cachix push {cachix_name}", input=input_paths)

    # build the package
    run_cmd_handle_failure(f"nix-build -A {attribute} --arg debug {debug_str}")

    # push the package to cachix
    if request.config.getoption("--push-on-cachix"):
        derivation = graph[attribute]["derivation"]
        run_cmd_handle_failure(f"cachix push {cachix_name}", input=derivation)

