return {
  bank = {
    brick = 13,
    grain = 14,
    lumber = 15,
    ore = 12,
    wool = 14
  },
  buildmap = {
    {
      [-1] = {
        N = {
          kind = "settlement",
          player = "blue"
        }
      },
      [-2] = {
        N = {
          kind = "settlement",
          player = "white"
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
          kind = "city",
          player = "red"
        }
      },
      [-2] = {
        N = {
          kind = "city",
          player = "red"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "white"
        }
      }
    },
    [0] = {
      {
        N = {
          kind = "settlement",
          player = "blue"
        }
      },
      [0] = {
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
    5,
    6
  },
  drawpile = {
    "yearofplenty",
    "knight",
    "monopoly",
    "knight",
    "knight",
    "victorypoint",
    "victorypoint",
    "knight",
    "roadbuilding",
    "monopoly",
    "knight",
    "knight",
    "victorypoint",
    "victorypoint",
    "knight",
    "knight",
    "yearofplenty",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
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
      "forest",
      [-1] = "fields",
      [-2] = "forest",
      [0] = "mountains"
    },
    {
      [-1] = "hills",
      [-2] = "fields",
      [0] = "pasture"
    },
    [-1] = {
      "forest",
      "pasture",
      [-1] = "mountains",
      [0] = "hills"
    },
    [-2] = {
      "pasture",
      "desert",
      [0] = "hills"
    },
    [0] = {
      "fields",
      "fields",
      [-1] = "mountains",
      [-2] = "forest",
      [0] = "pasture"
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
  player = "red",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {
      grain = 1,
      ore = 1,
      wool = 2
    },
    red = {
      brick = 4,
      grain = 3,
      lumber = 3,
      ore = 5,
      wool = 1
    },
    white = {
      brick = 1,
      lumber = 1
    },
    yellow = {
      brick = 1,
      grain = 1,
      ore = 1,
      wool = 2
    }
  },
  roadcredit = {},
  roadmap = {
    {
      [-1] = {
        NE = "red",
        W = "yellow"
      },
      [-2] = {
        NE = "red",
        NW = "white"
      },
      [0] = {
        W = "blue"
      }
    },
    {
      [-1] = {
        NE = "red",
        NW = "red",
        W = "yellow"
      },
      [-2] = {
        NE = "red",
        NW = "red",
        W = "blue"
      }
    },
    {
      [-1] = {
        W = "white"
      },
      [-2] = {
        W = "red"
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