# About
This is a little script for DragonRuby Game Toolkit
At the time of writing, this is not actually a Smaug package (check out smaug.dev) but the idea is that it will be one.

# Usage
## Installation
### With Smaug
Install with smaug (once it's on there, if it's not at the time you're reading this)
Run `ruby smaug/inline-require/inline_require.rb [OPTIONS]`

### Just use directly (It's just 1 file)
download `inline_require.rb` to your project's root directory

Run `ruby inline_require.rb [OPTIONS]`
## Setup & Assumptions

Here's the important part:
- you'll need to replace all your `require "<<filename>>"` in `main.rb` with `# main_root_require "<<filename>>"` (yes, as a comment)
- then you'll need to end `main.rb` with a line `require 'app/inlined.rb'`
- `app/main.rb` should only have `require` statements

Options:
You can pass `-i <<inlined output path>>` so that it'll output all those `require...`'s in some file besides the default `app/inlined.rb`
- make sure you end `main.rb` ends with a corresponding `require "<<inlined output path>>"`
You can pass `-m <<path to main.rb>>` to specify something besides `app/main.rb`

I haven't tested it with anything but regular ruby (not dragonruby) on a Mac.
# Why?
DragonRuby GTK `require "<<path/to/file>>"` is a little dodgy when doing nested `requires`.
To see the examples files, you'll have to visit on github

## Demonstration of Problem
__Note: the smaug packages in the examples are just ones I have locally, not published (yet)__

In `examples/problem` you'll there's an example of a small project.

We `require` files that themselves `require` other files

- The order they're required in is correct
- And yet if you try and run it, you get that issue with a constant being absent, as if you hadn't required it.

## Solution 1 - an extra require file
In `examples/solution_1_extra_require`
There's only one change between this and `examples/problem`

Changes from `examples/problem`
- It moves the `require 'app/app.rb'` line:
  - from `app/require.rb`
  - to `app/extra_require.rb`

Pro: And so if you run this, it'll work. It shows us the problem
Con: I didn't like the idea of handling it this way, having to keep track of what "depth" things `requires` happen

## Solution 2 - manually inlining everything
In `examples/solution_2_manual_inlining`
We know just doing every `require` in one file, without nested `require`'s works.

Changes from `examples/problem`
- Putting all the requires in `app/main.rb`
- removing and all the other files that do `require`, like
  - `app/require.rb`
  - `smaug.rb`
  - `smaug/pushy/require-in-smaug.rb`
  - `smaug/rspec-mruby/require-in-smaug.rb`

Pro: It works.
Con: I find the nested `requires` more maintainable. (And if you don't, this package may not have much use to you, lol)

## Solution 3a - Using this here package - Before running script
In `examples/solution_3a_using-package_before`

Changes from `examples/problem`
With a little extra setup:
- in `app/main.rb`
  - `# main_root_require "smaug.rb"`
  - `# main_root_require "app/require.rb"`
  - `require app/inlined.rb` (you'll notice this file doesn't exist yet, that's what the script fills out)
- added `smaug/inline-require`
  - so this is what it'd be like if had installed this package in smaug

## Solution 3b - Using this here package - After running script
In `examples/solution_3b_using-package/after`

Changes from `examples/solution_3b_using-package_after`
- `require app/inlined.rb` - this is all filled out now
