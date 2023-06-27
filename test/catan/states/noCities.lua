return {
  bank = {
    brick = 18,
    grain = 13,
    lumber = 17,
    ore = 16,
    wool = 16
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
          player = "blue"
        }
      }
    },
    {
      [-1] = {
        S = {
          kind = "city",
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
          kind = "city",
          player = "red"
        }
      }
    },
    [-1] = {
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
          kind = "city",
          player = "red"
        }
      },
      [-2] = {
        S = {
          kind = "city",
          player = "red"
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
    red = {},
    white = {},
    yellow = {}
  },
  dice = {
    2,
    5
  },
  drawpile = {
    "monopoly",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "roadbuilding",
    "yearofplenty",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "victorypoint",
    "knight",
    "knight",
    "knight",
    "roadbuilding",
    "knight",
    "yearofplenty",
    "knight",
    "knight",
    "monopoly",
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
      [-2] = "pasture",
      [0] = "hills"
    },
    {
      [-1] = "hills",
      [-2] = "fields",
      [0] = "mountains"
    },
    [-1] = {
      "fields",
      "hills",
      [-1] = "desert",
      [0] = "mountains"
    },
    [-2] = {
      "pasture",
      "forest",
      [0] = "forest"
    },
    [0] = {
      "pasture",
      "fields",
      [-1] = "pasture",
      [-2] = "mountains",
      [0] = "forest"
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
      lumber = 1,
      wool = 1
    },
    red = {
      brick = 0,
      grain = 4,
      lumber = 0,
      ore = 2,
      wool = 0
    },
    white = {
      grain = 1,
      ore = 1,
      wool = 1
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
        NE = "red",
        W = "blue"
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
        W = "yellow"
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
        NE = "red"
      }
    },
    [0] = {
      {
        W = "yellow"
      },
      [-1] = {
        W = "red"
      },
      [0] = {
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