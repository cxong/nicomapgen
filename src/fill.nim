import std/sets

import ./map

func popFirst[T](o: var OrderedSet[T]): T =
  for elem in o:
    o.excl elem
    return elem

type
  AlgoUpdateResult* = object
    x*, y*: int
    layer*: map.Layer

proc fillAlgo*(tile: map.Tile): iterator(l: var map.Layer): AlgoUpdateResult =
  return iterator(l: var map.Layer): AlgoUpdateResult =
    var boundary = toOrderedSet([(x: l.w div 2, y: l.h div 2)])
    while boundary.len > 0:
      let (x, y) = boundary.popFirst
      l.setTile(x, y, tile)
      yield AlgoUpdateResult(x: x, y: y, layer: l)
      # add neighbours to boundary
      for (nx, ny) in l.neighbors(x, y):
        if l.getTile(nx, ny) != tile:
          boundary.incl((nx, ny))
