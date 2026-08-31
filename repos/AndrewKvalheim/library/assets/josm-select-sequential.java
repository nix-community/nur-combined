package im.kvalhe.andrew.josm.select_sequential;

import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.OptionalInt;
import java.util.Set;
import java.util.stream.IntStream;
import javax.swing.JMenu;
import org.apache.commons.text.WordUtils;
import org.openstreetmap.josm.actions.JosmAction;
import org.openstreetmap.josm.data.osm.DataSet;
import org.openstreetmap.josm.data.osm.Node;
import org.openstreetmap.josm.data.osm.OsmPrimitive;
import org.openstreetmap.josm.data.osm.Way;
import org.openstreetmap.josm.gui.MainApplication;
import org.openstreetmap.josm.gui.MainMenu;
import org.openstreetmap.josm.plugins.Plugin;
import org.openstreetmap.josm.plugins.PluginInformation;
import org.openstreetmap.josm.tools.Shortcut;

public class SelectSequentialPlugin extends Plugin {
  public SelectSequentialPlugin(PluginInformation info) {
    super(info);

    JMenu selectionMenu = MainApplication.getMenu().selectionMenu;

    MainMenu.add(selectionMenu, new SelectSequentialAction(true, true));
    MainMenu.add(selectionMenu, new SelectSequentialAction(true, false));
    MainMenu.add(selectionMenu, new SelectSequentialAction(false, true));
    MainMenu.add(selectionMenu, new SelectSequentialAction(false, false));
  }

  private transient Set<Node> diff = new LinkedHashSet<>();

  private static String noun(boolean front) { return front ? "front" : "rear"; }
  private static String verb(boolean grow) { return grow ? "grow" : "shrink"; }

  private class SelectSequentialAction extends JosmAction {
    public static final boolean treeMode = false;
    private final boolean front;
    private final boolean grow;

    public SelectSequentialAction(boolean front, boolean grow) {
      super(
          String.format("%s %s", WordUtils.capitalize(verb(grow)), noun(front)),
          String.format("%s%s", verb(grow), noun(front)),
          String.format("%s selection at %s", WordUtils.capitalize(verb(grow)),
                        noun(front)),
          Shortcut.registerShortcut(
              String.format("tools:%s%s", verb(grow), noun(front)),
              String.format("Selection: %s %s",
                            WordUtils.capitalize(verb(grow)), noun(front)),
              front ? (grow ? KeyEvent.VK_RIGHT : KeyEvent.VK_LEFT)
                    : (grow ? KeyEvent.VK_DOWN : KeyEvent.VK_UP),
              Shortcut.SHIFT),
          true);
      this.front = front;
      this.grow = grow;
    }

    @Override
    public void actionPerformed(ActionEvent event) {
      DataSet data = getLayerManager().getActiveDataSet();
      Collection<Node> selection = data.getSelectedNodes();

      if (!selection.isEmpty()) {
        int d = this.grow ? (this.front ? 1 : -1) : 0;

        diff.clear();

        for (Node node : selection) {
          for (Way way : node.getParentWays()) {
            List<Node> sequence = way.getNodes();
            OptionalInt terminus =
                IntStream
                    .range(0 - Math.min(0, d), sequence.size() - Math.max(0, d))
                    .filter(i -> selection.contains(sequence.get(i)))
                    .reduce(this.front ? Integer::max : Integer::min);

            if (terminus.isPresent())
              diff.add(sequence.get(terminus.getAsInt() + d));
          }
        }
      }

      if (this.grow) {
        data.addSelected(diff);
        diff.clear();
      } else {
        data.clearSelection(diff);
      }
    }

    @Override
    protected void updateEnabledState() {
      updateEnabledStateOnCurrentSelection();
    }

    @Override
    protected void
    updateEnabledState(Collection<? extends OsmPrimitive> selection) {
      boolean hasSelection = selection != null && !selection.isEmpty();

      setEnabled(hasSelection || (this.grow && !diff.isEmpty()));
    }
  }
}
