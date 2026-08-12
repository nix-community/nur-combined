type HeaderMap = {
    [key: string]: string;
};

interface Metadata {
    url: string,
    headers: HeaderMap,
}

if (Deno.args.length != 1) {
    console.error("Please specify the metadata to normalize.");
}
const headerAllowlist = [
    'content-type',
    'x-typescript-types',
    'location',
];

const text = await Deno.readTextFile(Deno.args[0]);
const obj: Metadata = JSON.parse(text);
const headers: HeaderMap = {};
for (const header of headerAllowlist) {
    headers[header] = obj.headers[header];
}
const targetObj = {
    url: obj.url,
    headers,
};
await Deno.writeTextFile(Deno.args[0], JSON.stringify(targetObj));
console.log(`Fixed up metadata file ${Deno.args[0]}`);