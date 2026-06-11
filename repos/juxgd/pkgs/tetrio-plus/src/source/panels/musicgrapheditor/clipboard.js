export const clipboard = {
  copiedTrigger: null,
  copiedNode: null,
  selected: []
};

export const computed = {
  selected() { return clipboard.selected },
  copiedTrigger: {
    get() { return clipboard.copiedTrigger; },
    set(val) { clipboard.copiedTrigger = val; }
  },
  copiedNode: {
    get() { return clipboard.copiedNode; },
    set(val) { clipboard.copiedNode = val; }
  }
};
