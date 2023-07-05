# tailwind-classes-fold for Neovim

`tailwind-classes-fold` is a Neovim plugin that improves the readability of your Tailwind CSS classes by applying folding to lines with multiple classes.

## Features

- Automatically folds lines with Tailwind classes
- Hotkey to toggle folding


## Installation

To install `tailwind-classes-fold`, use your favorite Neovim package manager. For example:

```lua

plug:

Plug 'wwnbb/tailwind-classes-fold'

packer:

use 'wwnbb/tailwind-classes-fold'

setup keybinding
...
local tcf = require("tailwind-classes-fold")
tcf.setup()
keyset('n', 'zt', function()
  tcf.toggle_conceal()
end)


```
