async function getURL(url) {
    if (process.env.GITHUB_TOKEN) return fetch(url, { headers: { "Authorization": `token ${process.env.GITHUB_TOKEN}` } });
    else return fetch(url);
}

async function getReleases(repo) {
    const releases = await (await getURL(`https://api.github.com/repos/${repo}/releases`)).json();

    return releases;
}

module.exports = {
    getURL,
    getReleases
}