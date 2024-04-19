return {
  {
    "luckasRanarison/nvim-devdocs",
    opts = {
      wrap = true,
      float_win = {
        relative = 'editor',
        height = 55,
        width = 150
      },
      previewer_cmd = 'glow',
      cmd_args = { "-s", "dark", "-w", "140" },
      picker_cmd = 'glow',
      picker_cmd_args = { "-s", "dark", "-w", "90" }
    }
  }
}
