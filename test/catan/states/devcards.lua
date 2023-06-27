return {
  bank = {
    brick = 0,
    grain = 17,
    lumber = 14,
    ore = 12,
    wool = 17
  },
  buildmap = {
    {
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
      },
      [0] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    {
      [-1] = {
        S = {
          kind = "settlement",
          player = "yellow"
        }
      },
      [-2] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      }
    },
    [-1] = {
      [-1] = {
        S = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
    [0] = {
      [-1] = {
        S = {
          kind = "settlement",
          player = "yellow"
        }
      },
      [-2] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      }
    }
  },
  devcards = {
    blue = {},
    red = {
      {
        kind = "roadbuilding",
        roundBought = 3
      },
      {
        kind = "monopoly",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3,
        roundPlayed = 4
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
        kind = "knight",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      },
      {
        kind = "yearofplenty",
        roundBought = 3
      },
      {
        kind = "knight",
        roundBought = 3
      }
    },
    white = {},
    yellow = {}
  },
  drawpile = {
    "knight",
    "victorypoint",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "monopoly",
    "knight",
    "victorypoint",
    "yearofplenty",
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
      [-1] = "fields",
      [-2] = "mountains",
      [0] = "desert"
    },
    {
      [-1] = "hills",
      [-2] = "mountains",
      [0] = "forest"
    },
    [-1] = {
      "fields",
      "pasture",
      [-1] = "forest",
      [0] = "fields"
    },
    [-2] = {
      "forest",
      "pasture",
      [0] = "hills"
    },
    [0] = {
      "forest",
      "fields",
      [-1] = "mountains",
      [-2] = "pasture",
      [0] = "hills"
    }
  },
  lastdiscard = {},
  numbermap = {
    {
      12,
      [-1] = 3,
      [-2] = 10
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
      6,
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
      brick = 3,
      grain = 1
    },
    red = {
      brick = 13,
      grain = 0,
      lumber = 2,
      ore = 3,
      wool = 2
    },
    white = {
      brick = 1,
      grain = 1,
      ore = 2
    },
    yellow = {
      brick = 2,
      lumber = 3,
      ore = 2
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        W = "red"
      },
      [-1] = {
        W = "white"
      },
      [0] = {
        W = "blue"
      }
    },
    {
      [-1] = {
        W = "white"
      },
      [0] = {
        W = "yellow"
      }
    },
    [-1] = {
      [0] = {
        W = "blue"
      }
    },
    [0] = {
      [-1] = {
        W = "red"
      },
      [0] = {
        W = "yellow"
      }
    }
  },
  robber = {
    q = 2,
    r = -2
  },
  round = 5,
  version = 2
}