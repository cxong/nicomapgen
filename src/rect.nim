import std/sets

import ./algo
import ./map

func popFirst[T](o: var OrderedSet[T]): T =
  for elem in o:
    o.excl elem
    return elem

proc genFilled*(tile: map.Tile, x = 0, y = 0, w = 0, h = 0): iterator(l: var map.Layer): AlgoUpdateResult =
  ## Fill a rectangle starting from the middle going out
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

proc gen*(tile: map.Tile, x = 0, y = 0, w = 0, h = 0): iterator(l: var map.Layer): AlgoUpdateResult =
  ## Draw a rectangle from top-left, clockwise
  return iterator(l: var map.Layer): AlgoUpdateResult =
    let ww = if w == 0: l.w else: w
    let hh = if h == 0: l.h else: h
    let right = x + ww - 1
    let bottom = y + hh - 1
    # Top
    for tx in x..<x+ww:
      l.setTile(tx, y, tile)
      yield AlgoUpdateResult(x: tx, y: y, layer: l)
    # Right (skip first tile)
    for ty in y+1..<y+hh:
      l.setTile(right, ty, tile)
      yield AlgoUpdateResult(x: right, y: ty, layer: l)
    # Bottom (skip first tile)
    if hh > 1:
      for tx in countdown(right - 1, x):
        l.setTile(tx, bottom, tile)
        yield AlgoUpdateResult(x: tx, y: bottom, layer: l)
    # Left (skip first and last tile)
    if ww > 1:
      for ty in countdown(bottom - 1, 1):
        l.setTile(x, ty, tile)
        yield AlgoUpdateResult(x: x, y: ty, layer: l)
