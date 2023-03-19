const HtmlWebpackPlugin = require("html-webpack-plugin");
// const path = require('path');

module.exports = {
  plugins: [
    new HtmlWebpackPlugin({
      title: "Webpack Output",
    }),
  ],
};

