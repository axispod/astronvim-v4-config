return {
  -- Auto save config
  "okuuva/auto-save.nvim",
  event = { "User AstroFile", "InsertEnter" },
  opts = {
    enabled=true,
    debounce_delay=10000
  },
}

