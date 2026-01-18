async function getURL(url) {
    return fetch(url, {
        headers: process.env.GITHUB_TOKEN && {
            Authorization: `token ${process.env.GITHUB_TOKEN}`,
        }
    });
}

async function getReleases(repo, skip = false) {
    const url = skip ? `https://api.github.com/repos/${repo}/releases/latest` : `https://api.github.com/repos/${repo}/releases`;

    const releases = await (await getURL(url)).json();

    return skip ? [releases] : releases;
}

module.exports = {
    getURL,
    getReleases
}