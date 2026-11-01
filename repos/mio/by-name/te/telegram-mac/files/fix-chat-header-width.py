from pathlib import Path

path = Path("packages/ChatUI/Sources/ChatUI/ChatHeaderBubblesView.swift")
source = path.read_text()
old = """        let titleWidth = (titleView.textLayout?.attributedString.size().width ?? 0)
            + (statusControl?.frame.width ?? 0) + (leftStatusControl?.frame.width ?? 0)
            + (titleImageView?.image?.backingSize.width ?? 0)"""
new = """        let titleTextWidth: CGFloat = titleView.textLayout?.attributedString.size().width ?? 0
        let statusControlWidth: CGFloat = statusControl?.frame.width ?? 0
        let leftStatusControlWidth: CGFloat = leftStatusControl?.frame.width ?? 0
        let titleImageWidth: CGFloat = titleImageView?.image?.backingSize.width ?? 0
        let titleWidth = titleTextWidth + statusControlWidth + leftStatusControlWidth + titleImageWidth"""
if old not in source:
    raise SystemExit(f"expected expression not found in {path}")
path.write_text(source.replace(old, new, 1))
