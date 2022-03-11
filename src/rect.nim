import std/sets

import ./algo
import ./map

func popFirst[T](o: var OrderedSet[T]): T =
  for elem in o:
    o.excl elem
    return elem

proc gen*(tile: map.Tile, x = 0, y = 0, w = 0, h = 0, fill = true): iterator(l: var map.Layer): AlgoUpdateResult =
  return iterator(l: var map.Layer): AlgoUpdateResult =
    let ww = if w == 0: l.w else: w
    let hh = if h == 0: l.h else: h
    var boundary = toOrderedSet([(x: x + ww div 2, y: y + hh div 2)])
    while boundary.len > 0:
      let (tx, ty) = boundary.popFirst
      l.setTile(tx, ty, tile)
      yield AlgoUpdateResult(x: tx, y: ty, layer: l)
      # add neighbours to boundary
      for (nx, ny) in l.neighbors(tx, ty):
        if nx >= x and nx < x + ww and ny >= y and ny < y + hh and l.getTile(nx, ny) != tile:
          boundary.incl((nx, ny))
