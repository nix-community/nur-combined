export const KEYS = {
  CONNECTED: '_connected_minos',
  CONNECTED_GHOST: '_connected_ghost',
  UNCONNECTED: '_unconnected_minos',
  UNCONNECTED_GHOST: '_unconnected_ghost',
  JSTRIS_CONNECTED: '_connected_jstris'
}

export class Validator {
  constructor(file) {
    this.file = file;
    this.allowed = false;
    this.blocked = false;
  }

  isAllowed() {
    return this.allowed && !this.blocked;
  }

  blockMime(type) {
    if (this.file.type == type) this.blocked = true;
    return this;
  }

  dimension(w, h) {
    if (this.file.image.width == w && this.file.image.height == h)
      this.allowed = true;
    return this;
  }

  filename(key) {
    if (this.file.name.indexOf(key) != -1) {
      this.allowed = true;
      return this;
    }
    // If the file matches some other key, block it (since it'll want to use
    // a different importer)
    for (let key of Object.values(KEYS))
      if (this.file.name.indexOf(key) != -1)
        this.blocked = true;
    return this;
  }
}
