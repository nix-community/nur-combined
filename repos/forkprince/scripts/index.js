const path = require("path");

const update = require("./pkgs/update");
const { exists } = require("./pkgs/fs");

const args = process.argv.slice(2);

let force;
let file = null;

for (const arg of args) {
    if (["--force", "-f"].includes(arg)) {
        force = true;
    } else if (["--help", "-h"].includes(arg)) {
        console.log("Usage: update.js [--force|-f] <file>");
        process.exit(0);
    } else if (file) {
        console.error("Error: Multiple files provided. Provide only one file.");
        process.exit(2);
    } else {
        file = arg;
    }
}

if (!file) {
    console.error("Error: no file provided.\nUsage: update.js [--force|-f] <file>");
    process.exit(1);
}

const resolved = path.resolve(process.cwd(), file);

if (!await exists(resolved)) {
    console.error(`Error: file not found: ${resolved}`);
    process.exit(1);
}

const config = require(resolved);

force = force || config.force || false;

console.log(`Updating ${file}...`);

switch (config.source.type) {
    case "github-release": {
        if (config.platforms) {
            console.log(`Updating platforms for ${file}...`);
            await update.github.platforms(resolved, { config, force });
        } else if (config.variants) {
            console.log(`Updating variants for ${file}...`);
            await update.github.variants(resolved, { config, force });
        } else {
            console.log(`Updating single version for ${file}...`);
            await update.github.single(resolved, { config, force });
        }
        break;
    }
    case "api": {
        if (config.platforms) {
            console.log(`Updating platforms for ${file}...`);
            await update.api.platforms(resolved, { config, force });
        } else {
            console.log(`Updating single version for ${file}...`);
            await update.api.single(resolved, { config, force });
        }
        break;
    }
    case "forgejo-release": {
        if (config.platforms) {
            console.log(`Updating platforms for ${file}...`);
            await update.forgejo.platforms(resolved, { config, force });
        } else if (config.variants) {
            console.log(`Updating variants for ${file}...`);
            await update.forgejo.variants(resolved, { config, force });
        } else {
            console.log(`Updating single version for ${file}...`);
            await update.forgejo.single(resolved, { config, force });
        }
        break;
    }
    default: {
        console.error(`Error: unsupported source type: ${config.source.type}`);
        process.exit(1);
    }
}