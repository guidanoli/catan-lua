return {
  bank = {
    brick = 15,
    grain = 13,
    lumber = 8,
    ore = 12,
    wool = 15
  },
  buildmap = {
    {
      {
        S = {
          kind = "city",
          player = "red"
        }
      },
      [-2] = {
        N = {
          kind = "city",
          player = "yellow"
        }
      }
    },
    {
      [-1] = {
        S = {
          kind = "settlement",
          player = "white"
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
          player = "yellow"
        }
      }
    },
    [-1] = {
      [-2] = {
        S = {
          kind = "settlement",
          player = "white"
        }
      },
      [0] = {
        N = {
          kind = "city",
          player = "yellow"
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
          player = "blue"
        }
      },
      [-3] = {
        S = {
          kind = "city",
          player = "yellow"
        }
      }
    }
  },
  devcards = {
    blue = {},
    red = {},
    white = {},
    yellow = {
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
        kind = "monopoly",
        roundBought = 3
      },
      {
        kind = "victorypoint",
        roundBought = 3
      }
    }
  },
  dice = {
    1,
    2
  },
  drawpile = {
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "monopoly",
    "victorypoint",
    "knight",
    "yearofplenty",
    "victorypoint",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "yearofplenty",
    "victorypoint",
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
      "mountains",
      [-1] = "fields",
      [-2] = "forest",
      [0] = "pasture"
    },
    {
      [-1] = "pasture",
      [-2] = "hills",
      [0] = "mountains"
    },
    [-1] = {
      "fields",
      "forest",
      [-1] = "fields",
      [0] = "fields"
    },
    [-2] = {
      "pasture",
      "desert",
      [0] = "mountains"
    },
    [0] = {
      "hills",
      "forest",
      [-1] = "hills",
      [-2] = "forest",
      [0] = "pasture"
    }
  },
  lastdiscard = {},
  longestroad = "red",
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
      [-1] = 2,
      [0] = 9
    },
    [-2] = {
      3,
      [0] = 6
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
  player = "blue",
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
      lumber = 4,
      ore = 5,
      wool = 1
    },
    red = {
      brick = 0,
      grain = 1,
      lumber = 2,
      ore = 1,
      wool = 1
    },
    white = {
      ore = 1,
      wool = 2
    },
    yellow = {
      brick = 2,
      grain = 4,
      lumber = 5,
      ore = 0,
      wool = 0
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        NE = "blue",
        NW = "blue",
        W = "blue"
      },
      {
        W = "red"
      },
      [-2] = {
        NE = "yellow",
        NW = "yellow"
      }
    },
    {
      {
        W = "blue"
      },
      [-2] = {
        NW = "yellow"
      },
      [0] = {
        NW = "white"
      }
    },
    {
      [0] = {
        W = "yellow"
      }
    },
    [-1] = {
      {
        W = "red"
      },
      {
        NE = "blue",
        NW = "blue",
        W = "red"
      },
      {
        NE = "red",
        NW = "red"
      },
      [-1] = {
        NE = "yellow",
        W = "white"
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
      nil,
      {
        NW = "blue"
      },
      {
        NW = "red"
      },
      [-1] = {
        NE = "blue",
        W = "yellow"
      },
      [-2] = {
        NE = "yellow",
        NW = "yellow",
        W = "yellow"
      }
    }
  },
  robber = {
    q = -2,
    r = 2
  },
  round = 5,
  version = 2
}