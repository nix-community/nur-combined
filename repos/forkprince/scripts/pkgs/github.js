async function getURL(url) {
    return fetch(url, {
        headers: process.env.GITHUB_TOKEN && {
            Authorization: `token ${process.env.GITHUB_TOKEN}`,
        }
    });
}

async function getReleases(repo) {
    const releases = await (await getURL(`https://api.github.com/repos/${repo}/releases`)).json();

    return releases;
}

module.exports = {
    getURL,
    getReleases
}