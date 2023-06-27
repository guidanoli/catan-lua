return {
  bank = {
    brick = 12,
    grain = 15,
    lumber = 12,
    ore = 14,
    wool = 15
  },
  buildmap = {
    {
      [-2] = {
        S = {
          kind = "city",
          player = "red"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "blue"
        }
      }
    },
    [-1] = {
      {
        N = {
          kind = "settlement",
          player = "white"
        }
      },
      {
        N = {
          kind = "settlement",
          player = "blue"
        }
      },
      [-1] = {
        N = {
          kind = "city",
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
    [-2] = {
      {
        N = {
          kind = "city",
          player = "red"
        }
      },
      {
        N = {
          kind = "settlement",
          player = "red"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "red"
        }
      }
    },
    [0] = {
      {
        N = {
          kind = "settlement",
          player = "white"
        }
      },
      {
        N = {
          kind = "settlement",
          player = "yellow"
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
    "knight",
    "knight",
    "monopoly",
    "knight",
    "roadbuilding",
    "roadbuilding",
    "victorypoint",
    "victorypoint",
    "victorypoint",
    "knight",
    "knight",
    "monopoly",
    "victorypoint",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "knight",
    "knight",
    "knight",
    "yearofplenty",
    "knight",
    "knight",
    "knight",
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
      "pasture",
      [-1] = "mountains",
      [-2] = "forest",
      [0] = "hills"
    },
    {
      [-1] = "pasture",
      [-2] = "forest",
      [0] = "fields"
    },
    [-1] = {
      "hills",
      "fields",
      [-1] = "fields",
      [0] = "forest"
    },
    [-2] = {
      "forest",
      "fields",
      [0] = "desert"
    },
    [0] = {
      "pasture",
      "mountains",
      [-1] = "pasture",
      [-2] = "hills",
      [0] = "mountains"
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
      6,
      3
    },
    [0] = {
      5,
      10,
      [-1] = 10,
      [-2] = 5,
      [0] = 11
    }
  },
  phase = "end",
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
      brick = 5,
      grain = 3,
      lumber = 6,
      ore = 3,
      wool = 2
    },
    white = {
      brick = 1,
      lumber = 0,
      ore = 1
    },
    yellow = {
      grain = 1,
      lumber = 1,
      wool = 1
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        W = "yellow"
      },
      [-1] = {
        W = "red"
      },
      [0] = {
        NW = "blue"
      }
    },
    [-1] = {
      {
        NW = "white",
        W = "red"
      },
      {
        NE = "blue"
      },
      [-1] = {
        NE = "red",
        NW = "red",
        W = "red"
      },
      [0] = {
        NE = "yellow",
        W = "red"
      }
    },
    [-2] = {
      {
        NE = "red"
      },
      {
        NE = "red"
      },
      [0] = {
        NE = "red"
      }
    },
    [0] = {
      {
        NW = "white"
      },
      [-1] = {
        NE = "red",
        NW = "red"
      }
    }
  },
  robber = {
    q = 1,
    r = 0
  },
  round = 3,
  version = 2,
  winner = "red"
}