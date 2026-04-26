return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            include = { ".env" },
          },
          grep = {
            hidden = true,
            no_ignore = true,
          },
        },
      },
    },
  },
}
