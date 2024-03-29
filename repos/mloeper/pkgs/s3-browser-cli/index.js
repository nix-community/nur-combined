#!/usr/bin/env node
import inquirer from "inquirer";
import inquirer_s3 from "@nesto-software/inquirer-s3";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import fs from "fs";

inquirer.registerPrompt('s3-object', inquirer_s3);

// workaround, see README
const fd3 = fs.createWriteStream(null, {fd: 3});

// note: move into nix env
process.env.AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE = '1';

yargs(hideBin(process.argv))
  .command('*', 'start the interactive s3 key selection', (yargs) => {
    return yargs
      .option('bucket', {
        type: "string",
        describe: 'A bucket to pre-select. When specifying the bucket parameter with the name of a valid S3 account owned by your AWS account, the inquirer-s3 module will start to browse at the root of this bucket'
      })
      .option('objectPrefix', {
        type: "string",
        alias: "key",
        describe: "An S3 object prefix indicating where you'd like to start the browsing inside a bucket",
      })
      .option('enableFolderSelect', {
        type: "boolean",
        alias: "folders",
        describe: " If set, the user is allowed to select an S3 *folder* prefix as a valid result, default false"
      })
      .option('enableFileObjectSelect', {
        type: "boolean",
        alias: "files",
        describe: "If set, the user is allowed to select an S3 object (*files*) as a valid result, default true",
      })
      .option('enableOtherBuckets', {
        type: "boolean",
        alias: "allow-switch",
        describe: "If set, the user should be allowed to navigate to buckets other than the bucket parameter specified, default true",
      })
      .option('redirect', {
        type: "boolean",
        default: false,
        describe: "Use fd3 to write the command output instead of fd1 - ideal for programmatic access such as using jq",
      })
  }, async (argv) => {
    const res = await inquirer.prompt([{
        type: 's3-object',
        name: 'result',
        message: 'Which S3 object would you like to select?',
        bucket: argv.bucket,
        objectPrefix: argv.objectPrefix,
        enableFolderSelect: argv.enableFolderSelect,
        enableFileObjectSelect: argv.enableFileObjectSelect,
        enableOtherBuckets: argv.enableOtherBuckets,
    }]);

    let out = "";
    if (res && res.result) {
        out = JSON.stringify(res.result);
    } else {
        out = "{}";
    }

    // check if user wants to access the output programmatically
    if (argv.redirect) {
        fd3.write(out);
        console.log("Wrote result to fd3. If you do not poll fd3, the program hangs idefinitely.");
    } else {
        console.log(out);
    }
  })
  .strict()
  .parse();