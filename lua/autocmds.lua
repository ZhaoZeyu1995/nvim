require "nvchad.autocmds"

-- Bootstrap entry point for a new machine, usable without a UI:
--     nvim --headless "+MasonEnsure" +qa
--
-- Defined here rather than in the Mason plugin spec because that spec loads on
-- VeryLazy, which never fires headless (it waits for a UI) -- the command has
-- to exist before Mason does. Loading Mason kicks off the same install run,
-- and configs.mason_ensure shares its state, so this waits on that one run
-- instead of starting a second.
vim.api.nvim_create_user_command("MasonEnsure", function()
  require("lazy").load { plugins = { "mason.nvim" } }
  require("configs.mason_ensure").install_missing { blocking = true }
end, { desc = "Install any missing Mason packages, waiting for completion" })
