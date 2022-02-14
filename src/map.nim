import std/tables
import nico

import ./def

type
  Tile {.pure.} = enum
    Nothing, Grass, Wood

const TileSprites = {Nothing: 20, Grass: 133, Wood: 127}.toTable
const TileIsWall = {Nothing: false, Grass: false, Wood: true}.toTable

type
  Layer = object
    tiles: seq[Tile]
    w: int
    h: int

func newLayer(w, h: int): Layer =
  return Layer(tiles: newSeq[Tile](w * h), w: w, h: h)

func getTile(l: Layer, x, y: int): Tile =
  return l.tiles[x + y*l.w]

func setTile(l: var Layer, x, y: int, tile: Tile) =
  l.tiles[x + y*l.w] = tile

func isOutside(l: Layer, x, y: int): bool =
  return x < 0 or x >= l.w or y < 0 or y >= l.h

func isSameTile(l: Layer, x, y: int, tile: Tile, isWall: bool): bool =
  # Walls don't extend to edge
  if l.isOutside(x, y):
    return not isWall
  return l.getTile(x, y) == tile

# 16-tile indices
# first is centre,
# then 8 tiles from top clockwise,
# then h/v,
# then 4 end tiles from top clockwise,
# then isolated tile
const FloorSheetStride = 21
# Corresponds to this sprite arrangement:
# ┏ ┳ ┓ ╻   ▪
# ┣ ╋ ┫ ┃ ╺ ━ ╸
# ┗ ┻ ┛ ╹
const Floor16Indices = @[
  1+FloorSheetStride,
  1, 2, 2+FloorSheetStride, 2+FloorSheetStride*2, 1+FloorSheetStride*2, FloorSheetStride*2, FloorSheetStride, 0,
  5+FloorSheetStride, 3+FloorSheetStride,
  3, 6+FloorSheetStride, 3+FloorSheetStride*2, 4+FloorSheetStride,
  5,
]

func getFloorTile(l: Layer, x, y: int, tile: Tile): int =
  let up = l.isSameTile(x, y-1, tile, false)
  let right = l.isSameTile(x+1, y, tile, false)
  let down = l.isSameTile(x, y+1, tile, false)
  let left = l.isSameTile(x-1, y, tile, false)
  if up and right and down and left:
    return Floor16Indices[0]
  if not up and right and down and left:
    # upper edge
    return Floor16Indices[1]
  if not up and not right and down and left:
    # upper right corner
    return Floor16Indices[2]
  if up and not right and down and left:
    # right edge
    return Floor16Indices[3]
  if up and not right and not down and left:
    # bottom right corner
    return Floor16Indices[4]
  if up and right and not down and left:
    # bottom edge
    return Floor16Indices[5]
  if up and right and not down and not left:
    # bottom left corner
    return Floor16Indices[6]
  if up and right and down and not left:
    # left edge
    return Floor16Indices[7]
  if not up and right and down and not left:
    # upper left corner
    return Floor16Indices[8]
  if not up and right and not down and left:
    # horizontal
    return Floor16Indices[9]
  if up and not right and down and not left:
    # vertical
    return Floor16Indices[10]
  if not up and not right and down and not left:
    # upper end
    return Floor16Indices[11]
  if not up and not right and not down and left:
    # right end
    return Floor16Indices[12]
  if up and not right and not down and not left:
    # bottom end
    return Floor16Indices[13]
  if not up and right and not down and not left:
    # left end
    return Floor16Indices[14]
  if not up and not right and not down and not left:
    # isolated
    return Floor16Indices[15]
  raise newException(Defect, "unexpected; could not get tile type")

# 13-tile indices
# first is centre,
# then 4 corners from top-right clockwise,
# then h/v,
# then 4 end tiles from top clockwise,
# then isolated tile,
# then flat tile
const WallSheetStride = 20
# Corresponds to this sprite arrangement:
# ┏ ━ ┓ █ ┳
# ┃ ▪   ┣ ╋ ┫
# ┗   ┛   ┻
const Wall13Indices = @[
  4+WallSheetStride,
  2, 2+WallSheetStride*2, WallSheetStride*2, 0,
  1, WallSheetStride,
  4, 5+WallSheetStride, 4+WallSheetStride*2, 3+WallSheetStride,
  1+WallSheetStride,
  3,
]

func getWallTile(l: Layer, x, y: int, tile: Tile): int =
  let up = l.isSameTile(x, y-1, tile, true)
  let right = l.isSameTile(x+1, y, tile, true)
  let down = l.isSameTile(x, y+1, tile, true)
  let left = l.isSameTile(x-1, y, tile, true)
  if up and right and down and left:
    return Wall13Indices[0]
  if not up and not right and down and left:
    # upper right corner
    return Wall13Indices[1]
  if up and not right and not down and left:
    # bottom right corner
    return Wall13Indices[2]
  if up and right and not down and not left:
    # bottom left corner
    return Wall13Indices[3]
  if not up and right and down and not left:
    # upper left corner
    return Wall13Indices[4]
  if not up and right and not down and left:
    # horizontal
    return Wall13Indices[5]
  if up and not right and down and not left:
    # vertical
    return Wall13Indices[6]
  if not up and right and down and left:
    # upper edge
    return Wall13Indices[7]
  if up and not right and down and left:
    # right edge
    return Wall13Indices[8]
  if up and right and not down and left:
    # bottom edge
    return Wall13Indices[9]
  if up and right and down and not left:
    # left edge
    return Wall13Indices[10]
  if not up and not right and not down and not left:
    # isolated
    return Wall13Indices[11]
  return Wall13Indices[12]

type
  TileMap* = object
    w*: int
    h*: int
    ground: Layer
    walls: Layer

func getMsetT(l: Layer, x, y: int): int =
  let tile = l.getTile(x, y)
  let isWall = TileIsWall[tile]
  let baseSprite = TileSprites[tile]
  if tile == Nothing:
    return baseSprite
  let spriteOffset = (if isWall: getWallTile(l, x, y, tile) else: getFloorTile(l, x, y, tile))
  return baseSprite + spriteOffset

proc newTileMap*(w, h: int): TileMap =
  var m = TileMap(w: w, h: h, ground: newLayer(w, h), walls: newLayer(w, h))
  newMap(0, m.w, m.h, SpriteW, SpriteH)
  newMap(1, m.w, m.h, SpriteW, SpriteH)
  for y in 0..<m.h:
    for x in 0..<m.w:
      m.ground.setTile(x, y, Grass)
      m.walls.setTile(x, y, Nothing)
      if ((x == 1 or x == 14) and 1 <= y and y <= 14) or ((y == 1 or y == 14) and 1 <= x and x <= 14):
        m.walls.setTile(x, y, Wood)
  return m

proc init*(m: var TileMap) =
  setMap(0)
  for y in 0..<m.h:
    for x in 0..<m.w:
      let t = m.ground.getMsetT(x, y)
      mset(x, y, t)
  setMap(1)
  for y in 0..<m.h:
    for x in 0..<m.w:
      let t = m.walls.getMsetT(x, y)
      mset(x, y, t)

proc drawTileMap*() =
  setMap(0)
  setSpritesheet(SheetFloor)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
  setMap(1)
  setSpritesheet(SheetWall)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
