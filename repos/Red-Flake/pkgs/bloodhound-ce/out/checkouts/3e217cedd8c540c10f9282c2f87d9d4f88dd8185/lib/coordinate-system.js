"use strict";

module.exports = {
  adjust: adjust,
  undo: undo
};

function adjust(g) {
  var rankDir = g.graph().rankdir.toLowerCase();
  if (rankDir === "lr" || rankDir === "rl") {
    swapWidthHeight(g);
  }
}

function undo(g) {
  var rankDir = g.graph().rankdir.toLowerCase();
  if (rankDir === "bt" || rankDir === "rl") {
    reverseY(g);
  }

  if (rankDir === "lr" || rankDir === "rl") {
    swapXY(g);
    swapWidthHeight(g);
  }
}

function swapWidthHeight(g) {
  g.nodes().forEach(v => swapWidthHeightOne(g.node(v)));
  g.edges().forEach(e => swapWidthHeightOne(g.edge(e)));
}

function swapWidthHeightOne(attrs) {
  var w = attrs.width;
  attrs.width = attrs.height;
  attrs.height = w;
}

function reverseY(g) {
  g.nodes().forEach(v => reverseYOne(g.node(v)));

  g.edges().forEach(function(e) {
    var edge = g.edge(e);
    edge.points.forEach(reverseYOne);
    if (edge.hasOwnProperty("y")) {
      reverseYOne(edge);
    }
  });
}

function reverseYOne(attrs) {
  attrs.y = -attrs.y;
}

function swapXY(g) {
  g.nodes().forEach(v => swapXYOne(g.node(v)));

  g.edges().forEach(function(e) {
    var edge = g.edge(e);
    edge.points.forEach(swapXYOne);
    if (edge.hasOwnProperty("x")) {
      swapXYOne(edge);
    }
  });
}

function swapXYOne(attrs) {
  var x = attrs.x;
  attrs.x = attrs.y;
  attrs.y = x;
}
