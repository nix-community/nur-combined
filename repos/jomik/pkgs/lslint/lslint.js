#!/usr/bin/env node

const { spawn } = require("child_process");

const regex = /^ *(ERROR|WARN):: \( *(\d+), *(\d+)\): (.+)$/

const mcpp = spawn("@mcpp@", ["-W0"]);
const linter = spawn("@lslint@", ["-i"]);

let mcppLines = [];

process.stdin.on("data", (code) => {
  mcpp.stdin.write(code);
  mcpp.stdin.end();
});

mcpp.stdout.on("data", (mcppOut) => {
  mcppLines = mcppOut.toString("utf8").split("\n");
  mcppLines.reverse();
  linter.stdin.write(mcppOut);
  linter.stdin.end();
});

linter.stderr.on("data", (lintOut) => {
  const lintLines = lintOut.toString("utf8").split("\n")

  for (const l of lintLines) {
    const matches = l.match(regex);
    if (matches !== null) {
      let [_, type, line, col, msg] = matches;

      const index = mcppLines.findIndex((s, i) => i >= mcppLines.length - line && s.startsWith("#line"));
      if (index !== -1) {
        const directive = parseInt(mcppLines[index].match(/\d+/));
        line = line - 1 - (mcppLines.length - index) + directive;
      }

      console.log(`${type}:: (${line}, ${col}): ${msg}`);
    } else {
      console.log(l);
    }
  }
});

