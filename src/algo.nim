import ./map

type
  AlgoUpdateResult* = object
    x*, y*: int
    layer*: map.Layer
