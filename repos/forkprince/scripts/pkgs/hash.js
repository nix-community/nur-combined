const { slug } = require("./text");

module.exports = async (url, unpack = false) => {
  const filename = slug(url) || "download";

  const args = ["store", "prefetch-file", encodeURI(url), "--json", "--name", filename];

  if (unpack) args.push("--unpack");

  const proc = Bun.spawn(["nix", ...args], { stdout: "pipe", stderr: "pipe" });

  const output = await new Response(proc.stdout).text();

  const exit = await proc.exited;
  if (exit !== 0) {
    const error = await new Response(proc.stderr).text();
    throw new Error(`Failed to prefetch file: ${error}`);
  }

  const result = JSON.parse(output);
  return result.hash;
}
