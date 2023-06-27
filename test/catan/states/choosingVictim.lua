return {
  bank = {
    brick = 19,
    grain = 16,
    lumber = 17,
    ore = 17,
    wool = 6
  },
  buildmap = {
    {
      [-1] = {
        S = {
          kind = "settlement",
          player = "blue"
        }
      },
      [0] = {
        S = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
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
          player = "red"
        }
      }
    },
    [-1] = {
      [-1] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      },
      [0] = {
        S = {
          kind = "settlement",
          player = "white"
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
      [0] = {
        S = {
          kind = "settlement",
          player = "yellow"
        }
      }
    }
  },
  devcards = {
    blue = {},
    red = {
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
        kind = "roadbuilding",
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
        roundBought = 4
      },
      {
        kind = "yearofplenty",
        roundBought = 4
      },
      {
        kind = "monopoly",
        roundBought = 4
      }
    },
    white = {},
    yellow = {}
  },
  dice = {
    5,
    2
  },
  drawpile = {
    "monopoly",
    "knight",
    "victorypoint",
    "roadbuilding",
    "knight",
    "knight",
    "knight",
    "knight",
    "knight",
    "yearofplenty",
    "victorypoint",
    "knight",
    "victorypoint",
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
  hasbuilt = false,
  hexmap = {
    {
      "forest",
      [-1] = "forest",
      [-2] = "desert",
      [0] = "fields"
    },
    {
      [-1] = "pasture",
      [-2] = "fields",
      [0] = "forest"
    },
    [-1] = {
      "mountains",
      "pasture",
      [-1] = "forest",
      [0] = "pasture"
    },
    [-2] = {
      "fields",
      "fields",
      [0] = "mountains"
    },
    [0] = {
      "pasture",
      "hills",
      [-1] = "hills",
      [-2] = "mountains",
      [0] = "hills"
    }
  },
  lastdiscard = {
    blue = 5,
    white = 5,
    yellow = 5
  },
  numbermap = {
    {
      12,
      [-1] = 3,
      [0] = 6
    },
    {
      [-1] = 4,
      [-2] = 8,
      [0] = 11
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
  phase = "choosingVictim",
  player = "yellow",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {
      grain = 1,
      lumber = 1,
      wool = 3
    },
    red = {
      grain = 1,
      lumber = 1,
      ore = 0,
      wool = 2
    },
    white = {
      grain = 1,
      ore = 2,
      wool = 3
    },
    yellow = {
      brick = 0,
      ore = 0,
      wool = 5
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        W = "blue"
      },
      [0] = {
        W = "blue"
      }
    },
    {
      [-1] = {
        W = "red"
      },
      [0] = {
        W = "red"
      }
    },
    [-1] = {
      {
        W = "white"
      },
      [0] = {
        W = "white"
      }
    },
    [0] = {
      {
        W = "yellow"
      },
      [0] = {
        W = "yellow"
      }
    }
  },
  robber = {
    q = 1,
    r = 0
  },
  round = 5,
  version = {
    major = 2,
    minor = 0,
    patch = 0
  }
}