import nico
import nico/backends/common
import std/strutils

const orgName = "congusbongus"
const appName = "nicomapgen"

var buttonDown = false
const SpriteW = 16
const SpriteH = 16
const ScreenW = 16*16
const ScreenH = 16*16
const ScreenScale = 3
const PaletteDawnbringer = "140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6"
const SheetFloor = 0
const SheetWall = 1
const SheetPlayer = 2

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

proc gameUpdate(dt: float32) =
  buttonDown = btn(pcA)

proc gameDraw() =
  cls()
  setMap(0)
  setSpritesheet(SheetFloor)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
  setMap(1)
  setSpritesheet(SheetWall)
  mapDraw(0, 0, SpriteW, SpriteH, 0, 0)
  setColor(if buttonDown: 7 else: 3)
  printc("welcome to " & appName, screenWidth div 2, screenHeight div 2)
  setSpritesheet(SheetPlayer)
  spr(0, screenWidth div 2, screenHeight div 2)

nico.init(orgName, appName)
nico.createWindow(appName, ScreenW, ScreenH, ScreenScale, false)
nico.run(gameInit, gameUpdate, gameDraw)
