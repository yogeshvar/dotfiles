-- ============================================================================
-- Minimal Neovim — sensible defaults + 3 things:
--   1. find a file        (Space Space, or Cmd+P from the terminal, or Ctrl-p)
--   2. search all files   (Space /  — global "grep")
--   3. a file tree        (Space e  — toggle the sidebar)
--
-- This replaces LazyVim. The old config still lives in lua/ but is not loaded.
-- To go back to LazyVim: restore init.lua from git (it was just `require("config.lazy")`).
-- ============================================================================

-- Leader must be set before plugins load.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ---- sensible options ------------------------------------------------------
local opt = vim.opt
opt.number = true            -- line numbers
opt.mouse = "a"              -- mouse works everywhere
opt.clipboard = "unnamedplus"-- yank to the system clipboard
opt.ignorecase = true        -- case-insensitive search...
opt.smartcase = true         -- ...unless you type a capital
opt.termguicolors = true     -- true color
opt.signcolumn = "yes"
opt.expandtab = true         -- spaces, not tabs
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.scrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.undofile = true          -- persistent undo
opt.cursorline = true

-- ---- bootstrap lazy.nvim (plugin manager) ----------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ---- plugins (only what you asked for) -------------------------------------
require("lazy").setup({
  -- Dracula colorscheme (matches your terminal + tmux)
  { "Mofiqul/dracula.nvim", priority = 1000, lazy = false,
    config = function() vim.cmd.colorscheme("dracula") end },

  -- Fuzzy finder: powers both file search and global (live grep) search.
  -- Dirs to keep OUT of every search:
  { "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      winopts = { height = 0.85, width = 0.85, preview = { layout = "vertical" } },
      -- file search (Space Space)
      files = {
        rg_opts = [[--files --color=never -g "!.git" -g "!node_modules" -g "!.next" ]]
               .. [[-g "!dist" -g "!build" -g "!.turbo" -g "!coverage"]],
        fd_opts = [[--color=never --type f --exclude .git --exclude node_modules ]]
               .. [[--exclude .next --exclude dist --exclude build]],
      },
      -- global search (Space /)
      grep = {
        rg_opts = [[--column --line-number --no-heading --color=always --smart-case ]]
               .. [[-g "!.git" -g "!node_modules" -g "!.next" -g "!dist" -g "!build" ]]
               .. [[-g "!.turbo" -g "!coverage"]],
      },
    } },

  -- File tree sidebar (like VSCode's explorer)
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = { width = 34 },
      renderer = { group_empty = true },
      hijack_directories = { enable = true, auto_open = true }, -- `nvim .` opens the tree
      filters = {
        git_ignored = true,          -- hide node_modules, dist, etc. (from .gitignore)
        dotfiles = true,             -- hide .git and other dot-folders (toggle with H)
        custom = { "^\\.git$", "node_modules" },
      },
    } },
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

-- ---- keymaps ---------------------------------------------------------------
local map = vim.keymap.set

-- 1. FIND A FILE  (Space Space / Ctrl-p / terminal Cmd+P)
map("n", "<leader><leader>", "<cmd>FzfLua files<cr>",       { desc = "Find file" })
map("n", "<C-p>",            "<cmd>FzfLua files<cr>",       { desc = "Find file" })

-- 2. GLOBAL SEARCH across the project  (Space / or Ctrl-f)
map("n", "<leader>/",        "<cmd>FzfLua live_grep<cr>",   { desc = "Search in all files" })
map("n", "<C-f>",            "<cmd>FzfLua live_grep<cr>",   { desc = "Search in all files" })

-- 3. FILE TREE  (Space e toggles the sidebar; Space o focuses it)
map("n", "<leader>e",        "<cmd>NvimTreeToggle<cr>",     { desc = "Toggle file tree" })
map("n", "<leader>o",        "<cmd>NvimTreeFocus<cr>",      { desc = "Focus file tree" })

-- handy extras
map("n", "<leader>b",        "<cmd>FzfLua buffers<cr>",     { desc = "Open buffers" })
map("n", "<leader>w",        "<cmd>write<cr>",              { desc = "Save file" })
map("n", "<leader>q",        "<cmd>quit<cr>",               { desc = "Close window" })
map("n", "<Esc>",            "<cmd>nohlsearch<cr>",         { desc = "Clear search highlight" })

-- move between splits with Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")

-- ---- built-in cheat sheet  (Space ?  — like tmux's Ctrl-b ?) ---------------
local cheatsheet = {
  "  NEOVIM CHEAT SHEET                         press  q  to close",
  "  ============================================================",
  "  Leader key = Space",
  "",
  "  FIND / SEARCH",
  "    Space Space    find a file         (also Cmd+P or Ctrl-p)",
  "    Space /        search in all files (also Ctrl-f)",
  "    Space b        switch open buffers",
  "",
  "  FILE TREE (sidebar)",
  "    Space e        toggle the tree",
  "    Space o        jump into the tree",
  "    in tree: Enter/click open · a new · r rename · d delete",
  "",
  "  WINDOWS",
  "    Ctrl h/j/k/l   move between splits",
  "    Space w        save file      Space q   close window",
  "",
  "  VIM BASICS",
  "    i  insert mode         Esc  back to normal mode",
  "    :w save   :q quit   :wq save & quit",
  "    /text  search in file    n / N  next / previous match",
  "    u  undo    Ctrl-r  redo",
  "    dd delete line    yy copy line    p paste",
  "",
  "  HELP",
  "    Space ?        show this cheat sheet",
}

local function show_cheatsheet()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, cheatsheet)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  local width, height = 66, #cheatsheet
  vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal", border = "rounded", title = " help ", title_pos = "center",
  })
  for _, k in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", k, "<cmd>close<cr>", { buffer = buf, nowait = true })
  end
end
map("n", "<leader>?", show_cheatsheet, { desc = "Cheat sheet" })
