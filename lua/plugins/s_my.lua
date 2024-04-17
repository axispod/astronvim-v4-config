local ViMode = {
    -- get vim current mode, this information will be required by the provider
    -- and the highlight functions, so we compute it only once per component
    -- evaluation and store it as a component attribute
    init = function(self)
        self.mode = vim.fn.mode(1) -- :h mode()
    end,
    -- Now we define some dictionaries to map the output of mode() to the
    -- corresponding string and color. We can put these into `static` to compute
    -- them at initialisation time.
    static = {
        mode_names = { -- change the strings if you like it vvvvverbose!
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
        }
    },
    -- We can now access the value of mode() that, by now, would have been
    -- computed by `init()` and use it to index our strings dictionary.
    -- note how `static` fields become just regular attributes once the
    -- component is instantiated.
    -- To be extra meticulous, we can also add some vim statusline syntax to
    -- control the padding and make sure our string is always at least 2
    -- characters long. Plus a nice Icon.
    provider = function(self)
        return " %2("..self.mode_names[self.mode].."%) "
    end,
    -- Same goes for the highlight. Now the foreground will change according to the current mode.
    hl = function()
        local status = require('astroui.status')
        return { bg = status.hl.mode_bg(), fg="bg", bold = true }
    end,
    --surround = { separator = "left" },
    -- Re-evaluate the component only on ModeChanged event!
    -- Also allows the statusline to be re-evaluated when entering operator-pending mode
    update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
        end),
    },
}

local ViModeSeparator = {
  provider = function()
    return ""
  end,
  hl = function()
      local status = require('astroui.status')
      return { fg = status.hl.mode_bg(), bg="file_info_bg", bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
    end),
  }
}

return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- add new user interface icon
      icons = {
        VimIcon = "",
        ScrollText = "",
        GitBranch = "",
        GitAdd = "",
        GitChange = "",
        GitDelete = "",
      },
      -- modify variables used by heirline but not defined in the setup call directly
      status = {
        -- define the separators between each section
        separators = {
          left = { "", "" }, -- separator for the left side of the statusline
          right = { " ", "" }, -- separator for the right side of the statusline
          tab = { "", "" },
        },
        -- add new colors that can be used by heirline
        colors = function(hl)
          local get_hlgroup = require("astroui").get_hlgroup
          hl.blank_bg = get_hlgroup("Folded").fg
          hl.file_info_bg = get_hlgroup("Visual").bg
          hl.nav_icon_bg = get_hlgroup("String").fg
          hl.nav_fg = hl.nav_icon_bg
          hl.folder_icon_bg = get_hlgroup("Error").fg
          return hl
        end,
        attributes = {
          mode = { bold = true },
        },
        icon_highlights = {
          file_icon = {
            statusline = false,
          },
        },
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require("astroui.status")

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        { ViMode, ViModeSeparator },
        status.component.file_info({
          -- enable the file_icon and disable the highlighting based on filetype
          filename = { fallback = "Empty" },
          -- disable some of the info
          filetype = false,
          file_read_only = false,
          -- add padding
          padding = { right = 1 },
          -- define the section separator
          surround = { separator = "left", condition = false },
        }),
        status.component.git_branch({
          git_branch = { padding = { left = 1 } }
        }),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.virtual_env(),
        --status.component.treesitter(),
        status.component.nav({
          scrollbar = false,
          hl = { fg = 'bg' },
          ruler = { padding = { left = 1 } },
          surround = { color = { main = 'nav_fg' }}
        }),
        status.component.mode({
          surround = {
            separator = "right",
            color = { main = status.hl.mode_bg(), left = 'nav_fg' },
            update = {  "ModeChanged", pattern = "*:*" } },
        }),
      }

      -- opts.winbar = { -- winbar
      --   init = function(self)
      --     self.bufnr = vim.api.nvim_get_current_buf()
      --   end,
      --   fallthrough = false,
      --   { -- inactive winbar
      --     condition = function()
      --       return not status.condition.is_active()
      --     end,
      --     status.component.separated_path(),
      --     status.component.file_info({
      --       file_icon = {
      --         hl = status.hl.file_icon("winbar"),
      --         padding = { left = 0 },
      --       },
      --       filename = {},
      --       filetype = false,
      --       file_read_only = false,
      --       hl = status.hl.get_attributes("winbarnc", true),
      --       surround = false,
      --       update = "BufEnter",
      --     }),
      --   },
      --   { -- active winbar
      --     status.component.breadcrumbs({
      --       hl = status.hl.get_attributes("winbar", true),
      --     }),
      --   },
      -- }
      --
      -- opts.tabline = { -- tabline
      --   { -- file tree padding
      --     condition = function(self)
      --       self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
      --       self.winwidth = vim.api.nvim_win_get_width(self.winid)
      --       return self.winwidth ~= vim.o.columns -- only apply to sidebars
      --         and not require("astrocore.buffer").is_valid(
      --           vim.api.nvim_win_get_buf(self.winid)
      --         ) -- if buffer is not in tabline
      --     end,
      --     provider = function(self)
      --       return (" "):rep(self.winwidth + 1)
      --     end,
      --     hl = { bg = "tabline_bg" },
      --   },
      --   status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
      --   status.component.fill({ hl = { bg = "tabline_bg" } }), -- fill the rest of the tabline with background color
      --   { -- tab list
      --     condition = function()
      --       return #vim.api.nvim_list_tabpages() >= 2
      --     end, -- only show tabs if there are more than one
      --     status.heirline.make_tablist({ -- component for each tab
      --       provider = status.provider.tabnr(),
      --       hl = function(self)
      --         return status.hl.get_attributes(
      --           status.heirline.tab_type(self, "tab"),
      --           true
      --         )
      --       end,
      --     }),
      --     { -- close button for current tab
      --       provider = status.provider.close_button({
      --         kind = "TabClose",
      --         padding = { left = 1, right = 1 },
      --       }),
      --       hl = status.hl.get_attributes("tab_close", true),
      --       on_click = {
      --         callback = function()
      --           require("astrocore.buffer").close_tab()
      --         end,
      --         name = "heirline_tabline_close_tab_callback",
      --       },
      --     },
      --   },
      -- }

      opts.statuscolumn = { -- statuscolumn
        init = function(self)
          self.bufnr = vim.api.nvim_get_current_buf()
        end,
        status.component.foldcolumn(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      }
    end,
  }
}

