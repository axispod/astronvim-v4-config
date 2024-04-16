local keywords = { "ERROR", "WARN", "FIX", "TODO", "HACK", "PERF" }
return {
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["[w"] = {
                function () require("todo-comments").jump_prev({keywords = keywords}) end,
                desc = "Previous TODO keyword"
              },
              ["]w"] = {
                function () require("todo-comments").jump_next({keywords = keywords}) end,
                desc = "Next TODO keyword"
              }
            }
          }
        }
      }
    },
    -- opts = function(_, opts) opts.highlight.pattern = "[[.*<(KEYWORDS)\\s*:?]]" end,
    opts = {
      pattern = [[\b(KEYWODS)(:|\s)\b]],
      highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        before = "", -- "fg" or "bg" or empty
        keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = "fg", -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*(:|\s)]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]]
      }
    },
  },
}
