const update = require("../../file");
const path = require("path");

module.exports = async (file, { config }) => {
  if (config.pnpmHash === undefined) return;

  const name = path.basename(path.dirname(file));

  console.log(`Fetching pnpm hash for ${name}...`);

  const proc = Bun.spawn(
    ["nix", "build", `.#${name}.pnpmDeps`, "--no-link"],
    { cwd: process.cwd(), stdout: "pipe", stderr: "pipe" }
  );

  const stderr = await new Response(proc.stderr).text();

  if (await proc.exited === 0) return console.log(`pnpm hash already valid`);

  const hash = stderr.match(/got:\s*(sha256-[a-zA-Z0-9+/=]+)/m)?.[1];
  if (!hash) console.error(`Failed to get pnpm hash: ${stderr}`)
  else {
    console.log(`Got pnpm hash: ${hash}`);

    await update.single(file, { pnpmHash: hash });

    console.log(`Updated pnpm hash`);
  }
};
