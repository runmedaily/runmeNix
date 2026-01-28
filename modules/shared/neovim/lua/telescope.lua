local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    multi_selection_mode = true,
    find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
    mappings = {
      i = {
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<A-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-l>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
      },
      n = {
        ["q"] = actions.send_to_qflist + actions.open_qflist,
        ["Q"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
      },
    },
  },
})

telescope.load_extension("fzf")

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
