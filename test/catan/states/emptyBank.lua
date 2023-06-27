return {
  bank = {
    brick = 0,
    grain = 0,
    lumber = 0,
    ore = 0,
    wool = 0
  },
  buildmap = {
    {
      [-1] = {
        N = {
          kind = "settlement",
          player = "yellow"
        },
        S = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    {
      [-1] = {
        S = {
          kind = "city",
          player = "red"
        }
      }
    },
    [-1] = {
      {
        S = {
          kind = "settlement",
          player = "blue"
        }
      },
      [-1] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      },
      [0] = {
        S = {
          kind = "settlement",
          player = "yellow"
        }
      }
    },
    [0] = {
      [-1] = {
        S = {
          kind = "settlement",
          player = "blue"
        }
      },
      [-2] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      }
    }
  },
  devcards = {
    blue = {},
    red = {
      {
        kind = "yearofplenty",
        roundBought = 3
      }
    },
    white = {},
    yellow = {}
  },
  dice = {
    2,
    4
  },
  drawpile = {
    "yearofplenty",
    "monopoly",
    "monopoly",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "knight",
    "victorypoint",
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
      "forest",
      [-1] = "pasture",
      [-2] = "fields",
      [0] = "pasture"
    },
    {
      [-1] = "forest",
      [-2] = "fields",
      [0] = "hills"
    },
    [-1] = {
      "fields",
      "hills",
      [-1] = "mountains",
      [0] = "forest"
    },
    [-2] = {
      "forest",
      "mountains",
      [0] = "pasture"
    },
    [0] = {
      "desert",
      "mountains",
      [-1] = "hills",
      [-2] = "pasture",
      [0] = "fields"
    }
  },
  lastdiscard = {},
  numbermap = {
    {
      12,
      [-1] = 3,
      [-2] = 10,
      [0] = 6
    },
    {
      [-1] = 4,
      [-2] = 8,
      [0] = 11
    },
    [-1] = {
      5,
      10,
      [-1] = 2,
      [0] = 4
    },
    [-2] = {
      3,
      8,
      [0] = 6
    },
    [0] = {
      nil,
      9,
      [-1] = 9,
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
      brick = 2,
      grain = 1,
      lumber = 19,
      ore = 18,
      wool = 12
    },
    red = {
      brick = 16,
      grain = 15,
      lumber = 0,
      ore = 0,
      wool = 4
    },
    white = {
      brick = 1,
      ore = 1,
      wool = 2
    },
    yellow = {
      grain = 3,
      wool = 1
    }
  },
  roadcredit = {},
  roadmap = {
    {
      [-1] = {
        NE = "yellow"
      },
      [0] = {
        NE = "red",
        NW = "red"
      }
    },
    {
      [0] = {
        NW = "red"
      }
    },
    [-1] = {
      {
        W = "yellow"
      },
      {
        W = "blue"
      },
      [0] = {
        NW = "white"
      }
    },
    [0] = {
      [-1] = {
        NW = "white"
      },
      [0] = {
        W = "blue"
      }
    }
  },
  robber = {
    q = 0,
    r = 1
  },
  round = 4,
  version = 2
}