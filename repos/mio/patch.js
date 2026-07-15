const fs = require('fs');
let code = fs.readFileSync('by-name/om/omnimux/src/src/App.tsx', 'utf8');

// Add draggedTabIndex state
code = code.replace(
  /const \[tabs, setTabs\] = useState<Tab\[\]>\(\[\{ id: 'qc', type: 'quick-connect' \}\]\);/,
  `const [tabs, setTabs] = useState<Tab[]>([{ id: 'qc', type: 'quick-connect' }]);\n  const [draggedTabIndex, setDraggedTabIndex] = useState<number | null>(null);`
);

// Replace drag event handlers
code = code.replace(
  /onDragStart=\{\(e\) => \{[\s\S]*?setData\('application\/omnimux-tab', index.toString\(\)\);[\s\S]*?\}\}/,
  `onDragStart={(e) => {
                  setDraggedTabIndex(index);
                  e.dataTransfer.setData('text/plain', index.toString());
                  // Fix huge ghost image on Wayland WebKitGTK
                  const img = new Image();
                  img.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
                  e.dataTransfer.setDragImage(img, 0, 0);
                }}`
);

code = code.replace(
  /onDrop=\{\(e\) => \{[\s\S]*?setTabs\(newTabs\);\s*\}\}/,
  `onDrop={(e) => {
                  e.preventDefault();
                  if (draggedTabIndex === null || draggedTabIndex === index) return;
                  
                  const newTabs = [...tabs];
                  const [removed] = newTabs.splice(draggedTabIndex, 1);
                  newTabs.splice(index, 0, removed);
                  setTabs(newTabs);
                  setDraggedTabIndex(null);
                }}
                onDragEnd={() => setDraggedTabIndex(null)}`
);

fs.writeFileSync('by-name/om/omnimux/src/src/App.tsx', code);
