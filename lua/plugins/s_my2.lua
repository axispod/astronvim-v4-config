if true then return {} end-- Disabled 

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

-- local FileType = {
--     provider = function()
--         return string.upper(vim.bo.filetype)
--     end,
--     hl = { fg = utils.get_highlight("Type").fg, bold = true },
-- }

local FileEncoding = {
    provider = function()
        local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
        return enc ~= 'utf-8' and enc:upper()
    end
}

local FileFormat = {
    provider = function()
        local fmt = vim.bo.fileformat
        return fmt ~= 'unix' and fmt:upper()
    end
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
          right = { " ", "" }, -- separator for the right side of the statusline
          tab = { "", "" },
        },
        -- add new colors that can be used by heirline
        colors = function(hl)
          local get_hlgroup = require("astroui").get_hlgroup
          -- use helper function to get highlight group properties
          local comment_fg = get_hlgroup("Comment").fg
          hl.git_branch_fg = comment_fg
          hl.git_added = comment_fg
          hl.git_changed = comment_fg
          hl.git_removed = comment_fg
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
      opts.statusline = {
        -- default highlight for the entire statusline
        hl = { fg = "fg", bg = "bg" },
        -- each element following is a component in astroui.status module

        -- add the vim mode component
        { ViMode, ViModeSeparator },
        -- add a section for the currently opened file information
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
        -- add a component for the current git branch if it exists and use no separator for the sections
        status.component.git_branch({
          git_branch = { padding = { left = 1 } },
          surround = { separator = "none" },
        }),
        -- add a component for the current git diff if it exists and use no separator for the sections
        status.component.git_diff({
          padding = { left = 1 },
          surround = { separator = "none" },
        }),
        -- fill the rest of the statusline
        -- the elements after this will appear in the middle of the statusline
        status.component.fill(),
        -- add a component to display if the LSP is loading, disable showing running client names, and use no separator
        status.component.lsp({
          lsp_client_names = false,
          surround = { separator = "none", color = "bg" },
        }),
        -- fill the rest of the statusline
        -- the elements after this will appear on the right of the statusline
        status.component.fill(),
        -- add a component for the current diagnostics if it exists and use the right separator for the section
        status.component.diagnostics({ surround = { separator = "right" } }),
        -- add a component to display LSP clients, disable showing LSP progress, and use the right separator
        status.component.lsp({
          lsp_progress = false,
          surround = { separator = "right" },
        }),
        -- NvChad has some nice icons to go along with information, so we can create a parent component to do this
        -- all of the children of this table will be treated together as a single component
        -- {
        --   -- define a simple component where the provider is just a folder icon
        --   status.component.builder({
        --     -- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
        --     { provider = require("astroui").get_icon("FolderClosed") },
        --     -- add padding after icon
        --     padding = { right = 1 },
        --     -- set the foreground color to be used for the icon
        --     hl = { fg = "bg" },
        --     -- use the right separator and define the background color
        --     surround = { separator = "right", color = "folder_icon_bg" },
        --   }),
        --   -- add a file information component and only show the current working directory name
        --   status.component.file_info({
        --     -- we only want filename to be used and we can change the fname
        --     -- function to get the current working directory name
        --     filename = {
        --       fname = function(nr)
        --         return vim.fn.getcwd(nr)
        --       end,
        --       padding = { left = 1 },
        --     },
        --     -- disable all other elements of the file_info component
        --     filetype = false,
        --     file_icon = false,
        --     file_modified = false,
        --     file_read_only = false,
        --     -- use no separator for this part but define a background color
        --     surround = {
        --       separator = "none",
        --       color = "file_info_bg",
        --       condition = false,
        --     },
        --   }),
        -- },
        { FileFormat, FileEncoding },
        -- the final component of the NvChad statusline is the navigation section
        -- this is very similar to the previous current working directory section with the icon
        { -- make nav section with icon border
          -- define a custom component with just a file icon
          status.component.builder({
            { provider = require("astroui").get_icon("ScrollText") },
            -- add padding after icon
            padding = { right = 1 },
            -- set the icon foreground
            hl = { fg = "bg" },
            -- use the right separator and define the background color
            -- as well as the color to the left of the separator
            surround = {
              separator = "right",
              color = { main = "nav_icon_bg", left = "file_info_bg" },
            },
          }),
          -- add a navigation component and just display the percentage of progress in the file
          status.component.nav({
            -- add some padding for the percentage provider
            percentage = { padding = { right = 1 } },
            -- disable all other providers
            ruler = false,
            scrollbar = false,
            -- use no separator and define the background color
            surround = { separator = "none", color = "file_info_bg" },
          }),
        },
      }
    end,
  },
}

