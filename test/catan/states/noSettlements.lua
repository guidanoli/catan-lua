return {
  bank = {
    brick = 17,
    grain = 19,
    lumber = 15,
    ore = 15,
    wool = 17
  },
  buildmap = {
    {
      {
        S = {
          kind = "settlement",
          player = "red"
        }
      },
      [-1] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      },
      [-2] = {
        S = {
          kind = "settlement",
          player = "blue"
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
      [0] = {
        S = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    [-1] = {
      {
        S = {
          kind = "settlement",
          player = "yellow"
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
          player = "white"
        }
      }
    },
    [0] = {
      {
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
      [0] = {
        S = {
          kind = "settlement",
          player = "blue"
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
    6,
    1
  },
  drawpile = {
    "roadbuilding",
    "victorypoint",
    "knight",
    "victorypoint",
    "knight",
    "monopoly",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "yearofplenty",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "yearofplenty",
    "roadbuilding",
    "knight",
    "knight",
    "knight",
    "monopoly",
    "knight",
    "knight",
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
      "fields",
      [-1] = "forest",
      [-2] = "hills",
      [0] = "hills"
    },
    {
      [-1] = "desert",
      [-2] = "pasture",
      [0] = "pasture"
    },
    [-1] = {
      "mountains",
      "forest",
      [-1] = "fields",
      [0] = "forest"
    },
    [-2] = {
      "forest",
      "mountains",
      [0] = "mountains"
    },
    [0] = {
      "pasture",
      "fields",
      [-1] = "fields",
      [-2] = "pasture",
      [0] = "hills"
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
      [-2] = 4,
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
      ore = 1,
      wool = 1
    },
    red = {
      brick = 1,
      grain = 0,
      lumber = 1,
      ore = 1,
      wool = 1
    },
    white = {
      lumber = 2,
      ore = 1
    },
    yellow = {
      lumber = 1,
      ore = 1
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        NE = "red",
        NW = "red"
      },
      {
        NW = "red"
      },
      [-1] = {
        W = "blue"
      },
      [0] = {
        W = "red"
      }
    },
    {
      {
        W = "red"
      }
    },
    [-1] = {
      {
        W = "white"
      },
      {
        W = "yellow"
      },
      {
        NE = "red"
      },
      [0] = {
        W = "white"
      }
    },
    [0] = {
      {
        NE = "red",
        W = "blue"
      },
      {
        NE = "red",
        NW = "red",
        W = "red"
      },
      [-1] = {
        W = "yellow"
      }
    }
  },
  robber = {
    q = -2,
    r = 2
  },
  round = 3,
  version = 2
}