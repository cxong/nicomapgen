import nico

import ./def

type
  Map* = object
    w*: int
    h*: int

proc init*(m: Map) =
  newMap(0, 16, 16, SpriteW, SpriteH)
  newMap(1, 16, 16, SpriteW, SpriteH)
  for y in 0..<16:
    for x in 0..<16:
      if ((x == 1 or x == 14) and 1 <= y and y <= 14) or ((y == 1 or y == 14) and 1 <= x and x <= 14):
        setMap(1)
        mset(x, y, 128)
      else:
        setMap(0)
        mset(x, y, 155)

proc draw*(m: Map) =
  setMap(0)
  setSpritesheet(SheetFloor)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
  setMap(1)
  setSpritesheet(SheetWall)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
