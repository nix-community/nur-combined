function slug(text) {
    return decodeURIComponent(text.split("/").pop() || "")
        .replace(/[\s%]+/g, "-")
        .toLowerCase();
}

function apply(template, substitutions) {
    if (!template || !substitutions) return template;

    let replaced = template;

    for (const [i, sub] of substitutions.entries())
        replaced = replaced.replace(new RegExp(`\\{${i}\\}`, "g"), sub);

    return replaced;
}

module.exports = {
    slug,
    apply
}