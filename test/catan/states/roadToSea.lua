return {
  bank = {
    brick = 19,
    grain = 19,
    lumber = 19,
    ore = 19,
    wool = 19
  },
  buildmap = {
    {
      [-2] = {
        N = {
          kind = "settlement",
          player = "red"
        }
      }
    }
  },
  devcards = {
    blue = {},
    red = {},
    white = {},
    yellow = {}
  },
  drawpile = {
    "victorypoint",
    "knight",
    "knight",
    "roadbuilding",
    "monopoly",
    "monopoly",
    "knight",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "knight",
    "knight",
    "yearofplenty",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "knight",
    "victorypoint",
    "victorypoint",
    "yearofplenty"
  },
  harbormap = {
    {
      {
        S = "wool"
      },
      {
        N = "wool"
      },
      [-2] = {
        N = "grain"
      }
    },
    {
      {
        N = "generic"
      },
      [-1] = {
        N = "ore"
      },
      [-3] = {
        S = "grain"
      }
    },
    {
      [-1] = {
        S = "generic"
      },
      [-2] = {
        S = "ore"
      }
    },
    [-1] = {
      nil,
      {
        S = "generic"
      },
      {
        N = "generic"
      },
      [-2] = {
        S = "lumber"
      }
    },
    [-2] = {
      nil,
      {
        S = "generic"
      },
      [0] = {
        N = "lumber",
        S = "brick"
      }
    },
    [-3] = {
      [2] = {
        N = "brick"
      },
      [3] = {
        N = "generic"
      }
    },
    [0] = {
      [-2] = {
        N = "generic"
      },
      [-3] = {
        S = "generic"
      }
    }
  },
  hexmap = {
    {
      "mountains",
      [-1] = "pasture",
      [-2] = "mountains",
      [0] = "pasture"
    },
    {
      [-1] = "hills",
      [-2] = "forest",
      [0] = "fields"
    },
    [-1] = {
      "hills",
      "hills",
      [-1] = "desert",
      [0] = "fields"
    },
    [-2] = {
      "forest",
      "fields",
      [0] = "forest"
    },
    [0] = {
      "fields",
      "pasture",
      [-1] = "pasture",
      [-2] = "forest",
      [0] = "mountains"
    }
  },
  lastdiscard = {},
  numbermap = {
    {
      9,
      [-1] = 3,
      [-2] = 8,
      [0] = 6
    },
    {
      [-1] = 11,
      [-2] = 4,
      [0] = 12
    },
    [-1] = {
      4,
      8,
      [0] = 9
    },
    [-2] = {
      6,
      3,
      [0] = 2
    },
    [0] = {
      5,
      10,
      [-1] = 10,
      [-2] = 5,
      [0] = 11
    }
  },
  phase = "placingInitialRoad",
  player = "red",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {},
    red = {},
    white = {},
    yellow = {}
  },
  roadcredit = {},
  roadmap = {},
  robber = {
    q = -1,
    r = -1
  },
  round = 1,
  version = 2
}