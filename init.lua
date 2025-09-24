vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.opt.mouse = ""

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  -- Use the default configuration
  -- virtual_lines = true

  -- Alternatively, customize specific options
  -- virtual_lines = {
  -- --  -- Only show virtual line diagnostics for the current cursor line
  --  current_line = false,
  -- },
})
require("configs.native_lsp")
-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client:supports_method('textDocument/completion') then
--       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--     end
--   end,
-- })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    vim.opt_local.iskeyword:append("$")
  end,
})

vim.api.nvim_create_user_command("FormatFiles", function(opts)
  local args = opts.fargs
  if #args < 2 then
    vim.notify("Usage: :FormatFiles <directory> <file_extension>", vim.log.levels.ERROR)
    return
  end

  local directory = args[1]
  local extension = args[2]

  -- Убираем завершающий слэш, если есть
  if directory:sub(-1) == "/" then
    directory = directory:sub(1, -2)
  end

  -- Шаблон файлов, включая все поддиректории
  local glob_path = string.format("%s/**/*.%s", directory, extension)
  local all_files = vim.fn.glob(glob_path, false, true)

  if vim.tbl_isempty(all_files) then
    vim.notify("No matching files found for pattern: " .. glob_path, vim.log.levels.WARN)
    return
  end

  -- Исключаем директории зависимостей
  local filtered_files = vim.tbl_filter(function(file)
    return not string.find(file, "/node_modules/")
      and not string.find(file, "/vendor/")
      and not string.find(file, "/pkg/mod/")
  end, all_files)

  if vim.tbl_isempty(filtered_files) then
    vim.notify("All matched files are inside excluded directories", vim.log.levels.WARN)
    return
  end

  for _, file in ipairs(filtered_files) do
    vim.cmd("silent edit " .. vim.fn.fnameescape(file))

    -- Проверяем filetype только по расширению
    if vim.bo.filetype == extension then
      vim.lsp.buf.format({ async = false })
      vim.cmd("update")
    end
  end
end, {
  nargs = "*",
  complete = "dir",
})

-- vim.api.nvim_create_user_command("FormatFiles", function(opts)
--   local args = opts.fargs
--   if #args < 2 then
--     vim.notify("Usage: :FormatFiles <directory> <file_extension>", vim.log.levels.ERROR)
--     return
--   end
--
--   local directory = args[1]
--   local extension = args[2]
--
--   -- Убираем возможный завершающий слэш
--   if directory:sub(-1) == "/" then
--     directory = directory:sub(1, -2)
--   end
--
--   -- Глоб-шаблон вида "src/**/*.go"
--   local glob_path = string.format("%s/**/*.%s", directory, extension)
--   local files = vim.fn.glob(glob_path, false, true)
--
--   if vim.tbl_isempty(files) then
--     vim.notify("No matching files found for pattern: " .. glob_path, vim.log.levels.WARN)
--     return
--   end
--
--   for _, file in ipairs(files) do
--     vim.cmd("silent edit " .. vim.fn.fnameescape(file))
--
--     -- Проверяем, что тип соответствует расширению
--     if vim.bo.filetype == extension then
--       vim.lsp.buf.format({ async = false })
--       vim.cmd("update")
--     end
--   end
-- end, {
--   nargs = "*",
--   complete = "dir",
-- })
