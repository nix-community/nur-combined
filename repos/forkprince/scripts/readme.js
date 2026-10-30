const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const README = path.join(ROOT, "README.md");
const START = "<!-- PACKAGES:START -->";
const END = "<!-- PACKAGES:END -->";

const ATTR_RE = /([\w-]+)\s*=\s*lib\.callPackage\s+\.\/pkgs\/([\w.-]+)\s*(\{(?:[^{}]|\{[^{}]*\})*\})?\s*;/gs;
const ARG_RE = /([\w-]+)\s*=\s*"([^"]*)"/g;

function extract(text, key) {
    const found = new RegExp(`\\b${key}\\s*=\\s*(?:''([\\s\\S]*?)''|"((?:[^"\\\\]|\\\\.)*)")`).exec(text);
    if (!found) return "";

    const raw = found[1] ?? found[2].replace(/\\(.)/g, "$1");
    return raw.replace(/\s+/g, " ").trim();
}

function fill(value, args) {
    const game = args.game ?? "gi";
    const region = args.region ?? "cn";

    return value.replace(/\$\{([^}]+)\}/g, (_, name) => {
        if (name === "title") return `${game.toUpperCase()} (${region})`;
        if (name === "type") return `${game}-${region}`;
        return args[name] ?? "";
    });
}

async function table() {
    const root = await Bun.file(path.join(ROOT, "default.nix")).text();
    const cache = new Map();

    const rows = [];

    for (const [, attr, dir, raw = ""] of root.matchAll(ATTR_RE)) {
        const args = Object.fromEntries([...raw.matchAll(ARG_RE)].map((match) => [match[1], match[2]]));

        if (!cache.has(dir)) cache.set(dir, await Bun.file(path.join(ROOT, "pkgs", dir, "default.nix")).text());

        const text = cache.get(dir);

        const display = fill(extract(text, "pname"), args) || attr;
        const description = fill(extract(text, "description"), args).replace(/\|/g, "\\|");
        const homepage = extract(text, "homepage");

        let cell = description || display;

        if (homepage) {
            cell = `[${display}](${homepage})`;
            if (description) cell += `, ${description[0].toLowerCase()}${description.slice(1)}`;
        }

        rows.push([attr, `| [\`${attr}\`](pkgs/${dir}/default.nix) | ${cell} |`]);
    }

    rows.sort(([left], [right]) => (left < right ? -1 : left > right ? 1 : 0));

    return ["| Package | Description |", "|---|---|", ...rows.map(([, row]) => row)].join("\n") + "\n";
}

async function render(readme) {
    const block = `${START}\n${await table()}${END}`;

    const start = readme.indexOf(START);
    const end = readme.indexOf(END);
    if (start !== -1 && end !== -1) return readme.slice(0, start) + block + readme.slice(end + END.length);

    return `${readme.replace(/\n?$/, "\n")}\n## Packages\n\n${block}\n`;
}

const old = await Bun.file(README).text();
const updated = await render(old);

if (process.argv.includes("--check")) {
    if (updated !== old) {
        console.error("README.md packages table is stale; run `bun scripts/gen-readme.js`");
        process.exit(1);
    }

    console.log("README.md packages table is up to date");
} else {
    await Bun.write(README, updated);
    console.log(`Updated ${README}`);
}
