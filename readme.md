# buff.nvim

When you are exploring a new project you must be switching between a lot of files, this plugin allows you to toggle a list of currently open buffers.
Yes, I've heard of ThePrimeagen Harpoon plugin, but the main reason of that plugin is to work with a subset of files, and obviously you must add every single file manually. So having that in mind, this plugin is meant only for those people that want to have a quick list of buffers and switch between them.

# Configuration

<details>
<summary>Lazy.nvim</summary>

```lua
return {
    'kutiny/buff.nvim',
    lazy = true,
    cmd = { 'BuffListToggle' },
    opts = {
        ignore_patterns = {
            "oil:.*", -- useful if you want to hide custom buffers like oil.nvim
        }
    },
    keys = {
        { '<leader>c', function() require('buff').show_buffer_list() end }
    },
}
```
</details>

# How to use

If you copied the configuration from before, you can type <leader>c to toggle the buffer list, move with vimotions and press enter to select one buffer.
If you don't want to select any, you can press the key combination again or just leave that window (it will close automatically.

# Deleting buffers

In order to delete a buffer, you can press `x` on the line of the buffer you want to delete, and that's it, the buffer will be removed if there is no changes pending

