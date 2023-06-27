return {
  bank = {
    brick = 14,
    grain = 12,
    lumber = 13,
    ore = 17,
    wool = 18
  },
  buildmap = {
    {
      {
        S = {
          kind = "settlement",
          player = "red"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "yellow"
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
          player = "white"
        }
      }
    },
    [-1] = {
      [0] = {
        N = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
    [-2] = {
      {
        N = {
          kind = "settlement",
          player = "red"
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
    5,
    2
  },
  drawpile = {
    "knight",
    "victorypoint",
    "victorypoint",
    "knight",
    "monopoly",
    "victorypoint",
    "knight",
    "monopoly",
    "knight",
    "yearofplenty",
    "victorypoint",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "yearofplenty",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "roadbuilding",
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
      "forest",
      [-1] = "mountains",
      [-2] = "mountains",
      [0] = "desert"
    },
    {
      [-1] = "fields",
      [-2] = "fields",
      [0] = "pasture"
    },
    [-1] = {
      "pasture",
      "pasture",
      [-1] = "forest",
      [0] = "forest"
    },
    [-2] = {
      "pasture",
      "hills",
      [0] = "fields"
    },
    [0] = {
      "hills",
      "hills",
      [-1] = "mountains",
      [-2] = "fields",
      [0] = "forest"
    }
  },
  lastdiscard = {
    red = 4
  },
  longestroad = "red",
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
  player = "blue",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {
      brick = 4,
      grain = 1,
      lumber = 2,
      wool = 1
    },
    red = {
      brick = 1,
      grain = 1,
      lumber = 4
    },
    white = {
      grain = 3
    },
    yellow = {
      grain = 2,
      ore = 2
    }
  },
  roadcredit = {},
  roadmap = {
    {
      [0] = {
        NW = "yellow"
      }
    },
    {
      [-2] = {
        NE = "white"
      }
    },
    {
      [-2] = {
        W = "white"
      }
    },
    [-1] = {
      {
        NE = "blue",
        W = "red"
      },
      {
        NW = "blue",
        W = "red"
      },
      [0] = {
        NE = "blue"
      }
    },
    [-2] = {
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
      {
        W = "blue"
      },
      {
        NE = "red"
      },
      [-1] = {
        NE = "yellow"
      }
    }
  },
  robber = {
    q = 2,
    r = 0
  },
  round = 4,
  version = 2
}