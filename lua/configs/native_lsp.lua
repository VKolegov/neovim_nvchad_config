--
-- HTML
--
vim.lsp.config.html = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
}
vim.lsp.enable { "html" }

--
-- CSS
--
vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
}
vim.lsp.enable { "cssls" }

--
-- PHP
--
vim.lsp.config.intelephense = {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
}
-- vim.lsp.enable({'intelephense'})
vim.lsp.config.phpactor = {
  cmd = { "phpactor", "language-server" },
  filetypes = { "php" },
  -- root_dir = vim.fs.dirname(vim.fs.find({ "composer.json", ".git" }, { upward = true })[1]),
}
vim.lsp.enable { "phpactor" }

--
-- SQL
--
vim.lsp.config.sqls = {
  cmd = { "sql-language-server", "start" },
  filetypes = { "sql" },
}
vim.lsp.enable { "sqls" }

--
-- TypeScript / JavaScript
--

local vue_language_server_path = vim.fn.stdpath "data"
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
}
vim.lsp.config.vtsls = {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
}

--
-- Vue
--
vim.lsp.config.vue_ls = {
  on_init = function(client)
    client.handlers["tsserver/request"] = function(_, result, context)
      local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = "vtsls" }
      if #clients == 0 then
        vim.notify("Could not find `vtsls` lsp client, `vue_ls` would not work without it.", vim.log.levels.ERROR)
        return
      end
      local ts_client = clients[1]

      local param = result[1]
      local id, command, payload = unpack(param)

      if not id or not command then
        vim.notify("Malformed tsserver/request: " .. vim.inspect(result), vim.log.levels.ERROR)
        return
      end
      ts_client:exec_cmd({
        title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
        command = "typescript.tsserverRequest",
        arguments = {
          command,
          payload,
        },
      }, { bufnr = context.bufnr }, function(err, r)
        if err then
          vim.notify("Error from tsserverRequest: " .. vim.inspect(err), vim.log.levels.ERROR)
          return
        end
        if not r or not r.body then
          vim.notify("Empty or malformed response from tsserverRequest: " .. vim.inspect(r), vim.log.levels.WARN)
          return
        end

        local response_data = { { id, r.body } }
        ---@diagnostic disable-next-line: param-type-mismatch
        client:notify("tsserver/response", response_data)
      end)
    end
  end,

  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
}
vim.lsp.enable { "vtsls", "vue_ls" }

--
-- Go
--
vim.lsp.config.gopls = {
  cmd = { "gopls", "serve" },
  filetypes = { "go" },
}
vim.lsp.enable { "gopls" }

--
-- Python
--
local function get_conda_python_path()
  local conda_prefix = os.getenv "CONDA_PREFIX"
  if conda_prefix then
    return conda_prefix .. "/bin/python"
  else
    return vim.fn.exepath "python3" -- fallback
  end
end

vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = vim.fs.dirname(
    vim.fs.find({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }, { upward = true })[1]
  ),
  settings = {
    python = {
      pythonPath = get_conda_python_path(),
    },
  },
}

vim.lsp.enable { "pyright" }
