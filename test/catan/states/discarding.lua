return {
  bank = {
    brick = 17,
    grain = 14,
    lumber = 9,
    ore = 16,
    wool = 12
  },
  buildmap = {
    {
      {
        N = {
          kind = "settlement",
          player = "yellow"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "white"
        }
      }
    },
    [-1] = {
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
    },
    [-2] = {
      {
        N = {
          kind = "settlement",
          player = "blue"
        }
      },
      {
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
          player = "red"
        }
      },
      [0] = {
        N = {
          kind = "settlement",
          player = "white"
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
    "monopoly",
    "knight",
    "knight",
    "knight",
    "yearofplenty",
    "victorypoint",
    "knight",
    "yearofplenty",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "roadbuilding",
    "knight",
    "knight",
    "knight",
    "victorypoint",
    "victorypoint",
    "monopoly",
    "knight",
    "knight",
    "knight",
    "roadbuilding"
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
      [-2] = "hills",
      [0] = "fields"
    },
    {
      [-1] = "mountains",
      [-2] = "forest",
      [0] = "mountains"
    },
    [-1] = {
      "forest",
      "fields",
      [-1] = "hills",
      [0] = "forest"
    },
    [-2] = {
      "hills",
      "forest",
      [0] = "pasture"
    },
    [0] = {
      "pasture",
      "mountains",
      [-1] = "fields",
      [-2] = "desert",
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
      [-1] = 5,
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
      [0] = 11
    }
  },
  phase = "discarding",
  player = "white",
  players = {
    "red",
    "blue",
    "yellow",
    "white"
  },
  rescards = {
    blue = {
      brick = 1,
      lumber = 5,
      wool = 2
    },
    red = {
      brick = 1,
      lumber = 3,
      wool = 1
    },
    white = {
      grain = 4,
      ore = 2,
      wool = 1
    },
    yellow = {
      grain = 1,
      lumber = 2,
      ore = 1,
      wool = 3
    }
  },
  roadcredit = {},
  roadmap = {
    {
      {
        NW = "yellow"
      },
      [0] = {
        NE = "white"
      }
    },
    [-1] = {
      {
        NW = "blue"
      },
      [0] = {
        NE = "yellow"
      }
    },
    [-2] = {
      {
        NW = "blue"
      },
      {
        NE = "red"
      }
    },
    [0] = {
      {
        NW = "red"
      },
      [0] = {
        NE = "white"
      }
    }
  },
  robber = {
    q = 0,
    r = -2
  },
  round = 4,
  version = 2
}