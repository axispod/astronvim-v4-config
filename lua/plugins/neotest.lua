local prefix = "<Leader>r"
return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              [prefix] = { desc = "󰗇 Tests" },
              [prefix .. "r"] = { function() require("neotest").run.run() end, desc = "Run test" },
              [prefix .. "d"] = { function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug test" },
              [prefix .. "a"] = {
                function() require("neotest").run.run(vim.fn.expand "%") end,
                desc = "Run all tests in file",
              },
              [prefix .. "A"] = {
                function() require("neotest").run.run(vim.fn.getcwd()) end,
                desc = "Run all tests in project",
              },
              [prefix .. "s"] = { function() require("neotest").summary.toggle() end, desc = "Test Summary" },
              [prefix .. "o"] = { function() require("neotest").output.open() end, desc = "Output hover" },
              [prefix .. "O"] = { function() require("neotest").output_panel.toggle() end, desc = "Output window" },
              ["]T"] = { function() require("neotest").jump.next() end, desc = "Next test" },
              ["[T"] = { function() require("neotest").jump.prev() end, desc = "previous test" },
            },
          },
        },
      },
      {
        "folke/neodev.nvim",
        opts = function(_, opts)
          opts.library = opts.library or {}
          if opts.library.plugins ~= true then
            opts.library.plugins = require("astrocore").list_insert_unique(opts.library.plugins, { "neotest" })
          end
          opts.library.types = true
        end,
      },
    },
    opts = function()
      return {
        -- your neotest config here
        adapters = {
          require "neotest-jest",
          require "neotest-rust",
          require "neotest-python",
        },
      }
    end,
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, vim.api.nvim_create_namespace "neotest")
      require("neotest").setup(opts)
    end,
  },
  {
    "catppuccin/nvim",
    optional = true,
    ---@type CatppuccinOptions
    opts = { integrations = { neotest = true } },
  },
}
