const fs = require('fs');
let code = fs.readFileSync('by-name/om/omnimux/src/src/App.tsx', 'utf8');

// Replace useState with useRef for draggedTabIndex
code = code.replace(
  /const \[draggedTabIndex, setDraggedTabIndex\] = useState<number \| null>\(null\);/,
  `const draggedTabIndex = useRef<number | null>(null);`
);

// Replace onDragStart
code = code.replace(
  /onDragStart=\{\(e\) => \{[\s\S]*?\}\}/,
  `onDragStart={(e) => {
                  draggedTabIndex.current = index;
                  e.dataTransfer.setData('text/plain', index.toString());
                  const canvas = document.createElement('canvas');
                  canvas.width = 1;
                  canvas.height = 1;
                  e.dataTransfer.setDragImage(canvas, 0, 0);
                }}`
);

// Replace onDrop
code = code.replace(
  /onDrop=\{\(e\) => \{[\s\S]*?setTabs\(newTabs\);\s*setDraggedTabIndex\(null\);\s*\}\}/,
  `onDrop={(e) => {
                  e.preventDefault();
                  if (draggedTabIndex.current === null || draggedTabIndex.current === index) return;
                  
                  const newTabs = [...tabs];
                  const [removed] = newTabs.splice(draggedTabIndex.current, 1);
                  newTabs.splice(index, 0, removed);
                  setTabs(newTabs);
                  draggedTabIndex.current = null;
                }}`
);

// Replace onDragEnd
code = code.replace(
  /onDragEnd=\{\(\) => setDraggedTabIndex\(null\)\}/,
  `onDragEnd={() => { draggedTabIndex.current = null; }}`
);

fs.writeFileSync('by-name/om/omnimux/src/src/App.tsx', code);
