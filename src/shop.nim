import ./algo
import ./map
import ./rect

proc gen*(): iterator(m: var map.TileMap): AlgoUpdateResult =
  return iterator(m: var map.TileMap): AlgoUpdateResult =
    let grassAlgo = rect.genFilled(Grass)
    while not finished(grassAlgo):
      yield grassAlgo(m.ground)
    let wallAlgo = rect.gen(Wood, x=1, y=1, w=m.w - 2, h=m.h - 2)
    while not finished(wallAlgo):
      yield wallAlgo(m.walls)
    let roomAlgo = rect.genFilled(WoodFloor, x=2, y=2, w=m.w - 4, h=m.h - 4)
    while not finished(roomAlgo):
      yield roomAlgo(m.ground)
