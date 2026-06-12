{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "azure";
  repo = "duckdb-azure";
  rev = "2ad247d4ca090cd2110f2e35531ab6fcdb80c186";
  hash = "sha256-EcEaWa3+Q5OdbasrXqKJMNwKTw9QIYk8PiRq+sYh8ao=";
}
