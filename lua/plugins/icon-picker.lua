local prefix = "<leader>f"
return {
  {
    "ziontee113/icon-picker.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              [prefix .. "i"] = { ":IconPickerNormal<cr>", desc = "Find icon" },
              [prefix .. "I"] = { ":IconPickerYank<cr>", desc = "Yank icon" },
            },
            i = {
              ["<C-y>"] = { "<cmd>IconPickerInsert<cr>" },
            }
          }
        }
      }
    },
    opts = {
      disable_legacy_commands = true
    }
  }
}
