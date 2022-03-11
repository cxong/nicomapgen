import nico
import nico/backends/common
import std/strutils

import ./def
import ./map
import ./shop

const orgName = "congusbongus"
const appName = "nicomapgen"

var buttonDown = false
var m = map.initTileMap(16, 16)
var algo = shop.gen()
const ScreenW = 16*16
const ScreenH = 16*16
const ScreenScale = 3
# Add black since first colour is always transparent and this matches the transparent pixels in PNGs
const PaletteDawnbringer = "000000140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6"

func loadPaletteFromHexString*(s: string): Palette =
  var palette: Palette
  for i in 0..<s.len/6:
    let strI = i*6
    let r = strutils.fromHex[uint8](s[strI..<strI+2])
    let g = strutils.fromHex[uint8](s[strI+2..<strI+4])
    let b = strutils.fromHex[uint8](s[strI+4..<strI+6])
    palette.data[i] = common.RGB(r, g, b)
    palette.size += 1
  return palette

proc gameInit() =
  let palette = loadPaletteFromHexString(PaletteDawnbringer)
  setPalette(palette)
  loadFont(0, "font.png")
  loadSpriteSheet(SheetFloor, "Objects/Floor.png", SpriteW, SpriteH)
  loadSpriteSheet(SheetWall, "Objects/Wall.png", SpriteW, SpriteH)
  loadSpriteSheet(SheetPlayer, "Characters/Player0.png", SpriteW, SpriteH)
  m.init()

proc gameUpdate(dt: float32) =
  if not finished(algo):
    var res = algo(m)
    res.layer.updateTile(res.x, res.y)

proc gameDraw() =
  cls()
  map.drawTileMap()
  setColor(if buttonDown: 7 else: 3)
  printc("welcome to " & appName, screenWidth div 2, screenHeight div 2)
  setSpritesheet(SheetPlayer)
  spr(0, screenWidth div 2, screenHeight div 2)

nico.init(orgName, appName)
nico.createWindow(appName, ScreenW, ScreenH, ScreenScale, false)
nico.run(gameInit, gameUpdate, gameDraw)
