-- Minimal Neovim configuration used only by vscode-neovim.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Comfortable, predictable editing defaults.
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true

local vscode = require("vscode")
local map = vim.keymap.set

local function action(command)
  return function()
    vscode.action(command)
  end
end

-- Leave Insert mode without reaching for Escape.
map("i", "jk", "<Esc>", { desc = "Exit Insert mode" })

-- Move between VS Code editor groups.
map("n", "<C-h>", action("workbench.action.focusLeftGroup"), { desc = "Focus editor group left" })
map("n", "<C-j>", action("workbench.action.focusBelowGroup"), { desc = "Focus editor group below" })
map("n", "<C-k>", action("workbench.action.focusAboveGroup"), { desc = "Focus editor group above" })
map("n", "<C-l>", action("workbench.action.focusRightGroup"), { desc = "Focus editor group right" })

-- Let VS Code's language tooling own code navigation.
map("n", "gd", action("editor.action.revealDefinition"), { desc = "Go to definition" })
map("n", "gr", action("editor.action.goToReferences"), { desc = "Go to references" })
map("n", "gi", action("editor.action.goToImplementation"), { desc = "Go to implementation" })

-- Interactive, discoverable leader menu.
map({ "n", "x" }, "<Space>", action("whichkey.show"), { desc = "Open Which Key menu" })
