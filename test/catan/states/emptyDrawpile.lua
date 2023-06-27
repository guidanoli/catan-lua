return {
  bank = {
    brick = 17,
    grain = 12,
    lumber = 17,
    ore = 13,
    wool = 14
  },
  buildmap = {
    {
      [-1] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      },
      [-2] = {
        S = {
          kind = "settlement",
          player = "yellow"
        }
      },
      [-3] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    {
      [-2] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      },
      [-3] = {
        S = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
    {
      [-2] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      },
      [-3] = {
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
      }
    }
  },
  devcards = {
    blue = {},
    red = {
      {
        kind = "monopoly",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "roadbuilding",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "yearofplenty",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "monopoly",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "roadbuilding",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      },
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
    3
  },
  drawpile = {},
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
      [-1] = "mountains",
      [-2] = "fields",
      [0] = "mountains"
    },
    {
      [-1] = "pasture",
      [-2] = "forest",
      [0] = "fields"
    },
    [-1] = {
      "pasture",
      "hills",
      [-1] = "desert",
      [0] = "forest"
    },
    [-2] = {
      "forest",
      "pasture",
      [0] = "fields"
    },
    [0] = {
      "mountains",
      "hills",
      [-1] = "fields",
      [-2] = "pasture",
      [0] = "hills"
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
      brick = 1,
      grain = 1,
      lumber = 1
    },
    red = {
      brick = 1,
      grain = 4,
      ore = 4,
      wool = 4
    },
    white = {
      lumber = 1,
      ore = 1,
      wool = 1
    },
    yellow = {
      grain = 2,
      ore = 1
    }
  },
  roadcredit = {},
  roadmap = {
    {
      [-1] = {
        W = "yellow"
      },
      [-2] = {
        W = "red"
      },
      [0] = {
        W = "red"
      }
    },
    {
      [-1] = {
        W = "white"
      },
      [-2] = {
        W = "blue"
      }
    },
    {
      [-1] = {
        W = "white"
      },
      [-2] = {
        W = "yellow"
      }
    },
    [0] = {
      [0] = {
        W = "blue"
      }
    }
  },
  robber = {
    q = -1,
    r = -1
  },
  round = 3,
  version = 2
}