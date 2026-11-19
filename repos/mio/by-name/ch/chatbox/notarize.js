// Apple notarization is skipped: CSC_IDENTITY_AUTO_DISCOVERY is false and the
// mac identity is null, and notarizing would need network access.
exports.default = async function notarize() {};
