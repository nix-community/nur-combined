function guard(handler, fallback, callback) {
  return async function (...params) {
    try {
      return await handler(...params);
    } catch (error) {
      if (callback) callback(error);
      return fallback;
    }
  };
}

module.exports = {
  guard
};
