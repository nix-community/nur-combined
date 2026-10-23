{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).basic-memory,
}:
pkgs.runCommand "basic-memory-packaging-check"
  {
    nativeBuildInputs = [ package ];
    PYTHONPATH = "${package}/${pkgs.python3.sitePackages}:${pkgs.python3Packages.makePythonPath package.propagatedBuildInputs}";
  }
  ''
    export HOME="$TMPDIR/home"
    export BASIC_MEMORY_CONFIG_DIR="$TMPDIR/state"
    export BASIC_MEMORY_HOME="$TMPDIR/notes"
    export BASIC_MEMORY_DEFAULT_PROJECT=main
    export BASIC_MEMORY_AUTO_UPDATE=false
    export BASIC_MEMORY_NO_PROMOS=1
    export BASIC_MEMORY_FORCE_LOCAL=true
    export BASIC_MEMORY_DEFAULT_SEARCH_TYPE=text
    export HF_HUB_OFFLINE=1
    mkdir -p "$HOME" "$BASIC_MEMORY_HOME"
    basic-memory --version | grep -F '${package.version}'
    basic-memory mcp --help >/dev/null
    ${pkgs.python3.interpreter} - <<'PY'
    import asyncio
    import os
    from pathlib import Path

    from fastmcp import Client
    from fastmcp.client.transports import StdioTransport

    async def wait_for_content(path, content):
        async with asyncio.timeout(30):
            while not path.is_file() or content not in path.read_text():
                await asyncio.sleep(0.1)

    async def verify():
        transport = StdioTransport(
            command="${package}/bin/basic-memory",
            args=["mcp", "--project", "main"],
            env=dict(os.environ),
        )
        async with Client(transport) as client:
            names = {tool.name for tool in await client.list_tools()}
            assert {"write_note", "read_note", "edit_note", "search_notes"} <= names
            result = await client.call_tool("write_note", {
                "title": "Packaging Check",
                "directory": "tests",
                "content": "# Packaging Check\n\n## Observations\n- [fact] Persistent memory works\n",
                "project": "main",
            })
            assert not result.is_error, result
            note = Path(os.environ["BASIC_MEMORY_HOME"]) / "tests" / "Packaging Check.md"
            await wait_for_content(note, "Persistent memory works")
            assert list(Path(os.environ["BASIC_MEMORY_HOME"]).rglob("*.md")) == [note]
            result = await client.call_tool("read_note", {
                "identifier": "tests/packaging-check", "project": "main",
            })
            assert not result.is_error, result
            assert "Persistent memory works" in str(result)
            result = await client.call_tool("search_notes", {
                "query": "Packaging", "project": "main",
            })
            assert not result.is_error, result
            assert "Packaging Check" in str(result)
            result = await client.call_tool("edit_note", {
                "identifier": "tests/packaging-check", "operation": "append",
                "content": "\n- [fact] Updates work\n", "project": "main",
            })
            assert not result.is_error, result
            await wait_for_content(note, "Updates work")
        async with Client(transport) as client:
            result = await client.call_tool("read_note", {
                "identifier": "tests/packaging-check", "project": "main",
            })
            assert not result.is_error, result
            assert "Updates work" in str(result)

    asyncio.run(asyncio.wait_for(verify(), timeout=120))
    print("MCP discovery, write, read, search, update and restart checks passed")
    PY
    touch "$out"
  ''
