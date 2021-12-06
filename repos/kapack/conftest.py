#!/usr/bin/env python3
import json
import pytest
import shlex
import subprocess

def run_cmd_parse_json(cmd, input=None, do_print=False):
    '''Run a command and return its parsed JSON output.'''
    p = subprocess.Popen(shlex.split(cmd), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='utf-8')
    out, err = p.communicate(input=input)
    if do_print:
        print(f"cmd: {cmd}")
        #if input: print(f"stdin:\n--- BEGIN OF STDIN LOG ---\n{input}\n--- END OF STDIN LOG---")
        if out: print(f"stdout:\n--- BEGIN OF STDOUT LOG ---\n{out}\n--- END OF STDOUT LOG---")
        if err: print(f"stderr:\n--- BEGIN OF STDERR LOG ---\n{err}\n--- END OF STDERR LOG---")
    if p.returncode != 0:
        print(f'process failed: {cmd}')
        raise Exception(f'Process failed (returned {p.returncode})')

    return json.loads(out)

def determine_attribute_build_order(graph):
    '''Determine the order into which the attributes should be built.

    The idea here is to build attibutes that are needed the most first.
    This is to help error reporting, as if a package is broken,
    all packages that need it will also break because of this.
    '''
    # Traverse dependency graph to count how many times each derivation is needed.
    deriv_dict = dict()
    for key, value in graph.items():
        if value['derivation'] in deriv_dict:
            deriv_dict[value['derivation']] = (1+deriv_dict[value['derivation']][0], key)
        else:
            deriv_dict[value['derivation']] = (1, key)

        for input in value['inputs']:
            if input is not None:
                if input in deriv_dict:
                    deriv_dict[input] = (1+deriv_dict[input][0], "")
                else:
                    deriv_dict[input] = (1, "")

    # Only keep derivation that are attributes. Sort the list by descending number of use.
    l = sorted([(v[0], v[1], k) for k,v in deriv_dict.items() if v[1] != ""], key = lambda x: (-x[0], x[1]))

    # Only keep attribute names instead of a tuple.
    return [x[1] for x in l]

def generate_attributes(debug_str):
    '''Return a dict of attribute names to build.'''
    graph = run_cmd_parse_json(f"nix eval --json --arg debug {debug_str} -f ci.nix 'pkgs-to-build-with-deps'")
    return determine_attribute_build_order(graph)

def generate_attributes_with_inputs(debug_str):
    '''Return a dict of attributes with their inputs.'''
    return run_cmd_parse_json(f"nix eval --json --arg debug {debug_str} -f ci.nix 'pkgs-to-build-with-deps'")

def pytest_generate_tests(metafunc):
    debug_str = "true" if metafunc.config.getoption("--debug-build") else "false"
    if 'attribute' in metafunc.fixturenames:
        metafunc.parametrize('attribute', generate_attributes(debug_str))
    if 'graph' in metafunc.fixturenames:
        metafunc.parametrize('graph', [generate_attributes_with_inputs(debug_str)])

def pytest_addoption(parser):
    parser.addoption("--cachix-name", action="store", default="batsim", help="name on the cachix binary cache to push packages onto")
    parser.addoption("--push-deps-on-cachix", action="store_true", default=False, help="push package build deps on cachix before building it")
    parser.addoption("--push-on-cachix", action="store_true", default=False, help="push a package on cachix after building it")
    parser.addoption("--debug-build", action="store_true", default=False, help="build packages in debug mode")
