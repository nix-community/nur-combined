// RPG Maker MV and its plugins often use Windows-style filename casing.
// Resolve local URLs at the browser API boundary, including encrypted assets.
;(function() {
  'use strict';

  var fs = require('fs');
  var path = require('path');
  var nodeUrl = require('url');
  var directories = new Map();
  // NW.js changes cwd to the package directory before loading the page.
  // Capture it now, before any plugin can change the working directory.
  var applicationDirectory = process.cwd();

  function resolvePath(filename) {
    // Preserve exact matches, including files whose names differ only in case.
    if (fs.existsSync(filename)) return filename;
    var parent = path.dirname(filename);
    if (parent === filename) return null;
    parent = resolvePath(parent);
    if (parent === null) return null;

    // Game assets are immutable; scan each mismatched directory only once.
    if (!directories.has(parent)) {
      var entries = fs.readdirSync(parent).sort();
      var names = new Map();
      entries.forEach(function(entry) {
        var key = entry.toLowerCase();
        if (!names.has(key)) names.set(key, entry);
      });
      directories.set(parent, names);
    }
    var basename = path.basename(filename);
    var exact = path.join(parent, basename);
    if (fs.existsSync(exact)) return exact;
    var match = directories.get(parent).get(basename.toLowerCase());
    return match === undefined ? null : path.join(parent, match);
  }

  function resolveUrl(value) {
    // Leave native argument conversion and validation to the browser.
    if (typeof value !== 'string' || value === '') return value;
    try {
      var url = new URL(value, document.baseURI);
      var filename;
      var applicationPath;
      if (url.protocol === 'file:') {
        filename = nodeUrl.fileURLToPath(url.href);
      } else if (url.protocol === 'chrome-extension:' &&
                 location.protocol === 'chrome-extension:' && url.host === location.host) {
        // Newer NW.js serves the package directory under its extension origin.
        applicationPath = applicationDirectory;
        var root = nodeUrl.pathToFileURL(applicationPath + path.sep).href;
        filename = nodeUrl.fileURLToPath(new URL(url.pathname.slice(1), root).href);
      } else {
        return value;
      }
      var resolved = resolvePath(filename);
      if (resolved === null || resolved === filename) return value;
      if (applicationPath !== undefined) {
        url.pathname = nodeUrl.pathToFileURL(path.sep + path.relative(applicationPath, resolved)).pathname;
        return url.href;
      }
      return nodeUrl.pathToFileURL(resolved).href + url.search + url.hash;
    } catch (error) {
      // Missing, malformed or unreadable resources keep their normal behavior.
      return value;
    }
  }

  // Audio and video inherit src from HTMLMediaElement. Images made with
  // new Image() share HTMLImageElement.prototype with document-created images.
  [
    HTMLImageElement, HTMLMediaElement, HTMLSourceElement, HTMLScriptElement,
    HTMLIFrameElement, HTMLFrameElement, HTMLEmbedElement, HTMLInputElement,
    HTMLTrackElement
  ].forEach(function(constructor) {
    var prototype = constructor.prototype;
    var descriptor = Object.getOwnPropertyDescriptor(prototype, 'src');
    if (!descriptor || !descriptor.set) return;
    var set = descriptor.set;
    descriptor.set = function(value) {
      return set.call(this, resolveUrl(value));
    };
    Object.defineProperty(prototype, 'src', descriptor);
  });

  var setAttribute = Element.prototype.setAttribute;
  Element.prototype.setAttribute = function(name, value) {
    if (typeof name === 'string' && name.toLowerCase() === 'src' &&
        this instanceof HTMLElement && 'src' in this) {
      value = resolveUrl(value);
    }
    return setAttribute.call(this, name, value);
  };

  var setAttributeNS = Element.prototype.setAttributeNS;
  Element.prototype.setAttributeNS = function(namespace, name, value) {
    if ((namespace == null || namespace === '') && name === 'src' &&
        this instanceof HTMLElement && 'src' in this) {
      value = resolveUrl(value);
    }
    return setAttributeNS.call(this, namespace, name, value);
  };

  var open = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function() {
    var args = Array.prototype.slice.call(arguments);
    if (args.length > 1) args[1] = resolveUrl(args[1]);
    return open.apply(this, args);
  };
})();

