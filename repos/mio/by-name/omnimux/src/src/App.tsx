import { useEffect, useRef, useState } from "react";
import { Terminal } from "xterm";
import "xterm/css/xterm.css";
import { FitAddon } from "xterm-addon-fit";

function App() {
  const terminalRef = useRef<HTMLDivElement>(null);
  const [hosts, setHosts] = useState(["localhost", "server1", "server2"]);
  const [activeHost, setActiveHost] = useState("localhost");

  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.innerHTML = "";
      const term = new Terminal({
        theme: {
          background: "#1e1e1e",
        },
      });
      const fitAddon = new FitAddon();
      term.loadAddon(fitAddon);
      term.open(terminalRef.current);
      fitAddon.fit();

      term.writeln(`Welcome to OmniMux!`);
      term.writeln(`Connecting to ${activeHost}...`);
      term.writeln(`Running: ssh ${activeHost} -t 'tmux a || tmux new'`);
      term.writeln(``);
      term.writeln(`(This is a UI placeholder. The Tauri Rust backend needs to handle the SSH/PTY stream.)`);

      const handleResize = () => {
        fitAddon.fit();
      };
      window.addEventListener("resize", handleResize);

      return () => {
        window.removeEventListener("resize", handleResize);
        term.dispose();
      };
    }
  }, [activeHost]);

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100vh" }}>
      <div style={{ display: "flex", backgroundColor: "#333", padding: "10px", gap: "10px" }}>
        {hosts.map(host => (
          <button
            key={host}
            onClick={() => setActiveHost(host)}
            style={{
              padding: "5px 15px",
              backgroundColor: activeHost === host ? "#007acc" : "#555",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: "pointer",
            }}
          >
            {host}
          </button>
        ))}
        <button
          onClick={() => {
            const newHost = prompt("Enter new host:");
            if (newHost) setHosts([...hosts, newHost]);
          }}
          style={{
            padding: "5px 15px",
            backgroundColor: "#2ea043",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
          }}
        >
          + Add Host
        </button>
      </div>
      <div ref={terminalRef} style={{ flex: 1, overflow: "hidden", padding: "10px" }}></div>
    </div>
  );
}

export default App;
