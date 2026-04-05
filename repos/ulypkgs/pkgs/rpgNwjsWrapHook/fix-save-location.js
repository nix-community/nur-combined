StorageManager.localFileDirectoryPath = function() {
  var path = require('path');
  var fs = require('fs');
  var basename = path.basename(path.dirname(path.dirname(process.mainModule.filename)));
  var result;
  if (process.env.XDG_DATA_HOME) {
    result = path.join(process.env.XDG_DATA_HOME, basename, 'save/');
  } else {
    result = path.join(require('os').homedir(), '.local/share', basename, 'save/');
  }
  if (!fs.existsSync(result)) {
    fs.mkdirSync(result, { recursive: true });
  }
  return result;
};
