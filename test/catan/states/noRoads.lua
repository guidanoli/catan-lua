return {
  bank = {
    brick = 13,
    grain = 16,
    lumber = 13,
    ore = 15,
    wool = 15
  },
  buildmap = {
    {
      [-1] = {
        N = {
          kind = "settlement",
          player = "white"
        }
      },
      [-2] = {
        N = {
          kind = "settlement",
          player = "blue"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    {
      [-1] = {
        N = {
          kind = "settlement",
          player = "white"
        }
      },
      [-2] = {
        N = {
          kind = "settlement",
          player = "yellow"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
    [0] = {
      [-1] = {
        N = {
          kind = "settlement",
          player = "yellow"
        }
      },
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
  dice = {
    3,
    1
  },
  drawpile = {
    "roadbuilding",
    "victorypoint",
    "yearofplenty",
    "victorypoint",
    "knight",
    "knight",
    "yearofplenty",
    "knight",
    "monopoly",
    "knight",
    "victorypoint",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "monopoly",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "knight"
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
      "pasture",
      [-1] = "mountains",
      [-2] = "fields",
      [0] = "hills"
    },
    {
      [-1] = "mountains",
      [-2] = "pasture",
      [0] = "desert"
    },
    [-1] = {
      "fields",
      "forest",
      [-1] = "pasture",
      [0] = "forest"
    },
    [-2] = {
      "pasture",
      "hills",
      [0] = "forest"
    },
    [0] = {
      "mountains",
      "hills",
      [-1] = "fields",
      [-2] = "forest",
      [0] = "fields"
    }
  },
  lastdiscard = {},
  longestroad = "red",
  numbermap = {
    {
      12,
      [-1] = 3,
      [-2] = 8,
      [0] = 6
    },
    {
      [-1] = 11,
      [-2] = 4
    },
    [-1] = {
      4,
      10,
      [-1] = 2,
      [0] = 9
    },
    [-2] = {
      3,
      8,
      [0] = 6
    },
    [0] = {
      5,
      9,
      [-1] = 10,
      [-2] = 5,
      [0] = 11
    }
  },
  phase = "playingTurns",
  player = "red",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {
      ore = 1
    },
    red = {
      brick = 6,
      lumber = 5,
      ore = 2
    },
    white = {
      grain = 1,
      ore = 1,
      wool = 3
    },
    yellow = {
      grain = 2,
      lumber = 1,
      wool = 1
    }
  },
  roadcredit = {},
  roadmap = {
    {
      [-1] = {
        NW = "white"
      },
      [-2] = {
        NE = "blue"
      },
      [0] = {
        NW = "red"
      }
    },
    {
      [-1] = {
        NW = "white"
      },
      [-2] = {
        NE = "yellow"
      },
      [0] = {
        NW = "blue"
      }
    },
    [-1] = {
      [-1] = {
        NW = "red",
        W = "red"
      },
      [3] = {
        NW = "red"
      }
    },
    [-2] = {
      {
        W = "red"
      },
      {
        W = "red"
      },
      {
        NE = "red",
        NW = "red"
      },
      [0] = {
        NW = "red",
        W = "red"
      }
    },
    [-3] = {
      {
        NE = "red"
      },
      {
        NE = "red"
      },
      {
        NE = "red"
      }
    },
    [0] = {
      [-1] = {
        NW = "yellow"
      },
      [-2] = {
        NW = "red",
        W = "red"
      }
    }
  },
  robber = {
    q = 2,
    r = 0
  },
  round = 3,
  version = 2
}