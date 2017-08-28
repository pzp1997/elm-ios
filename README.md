# Current Status

We have shown that it is possible to use Elm to create native mobile apps, succeeding in our stated goal for the summer.

That said, the project is still in an early alpha stage and definitely should not be used for production apps yet. Currently, the project supports only a small subset of the UIKit elements, meaning that it does not have the full expressive power as an app written purely in Obj-C/Swift.

Looking ahead, I intend to actively maintain the project, however, new development will slow down while I am at university.

# Usage

Included in the package is a script called `elm-ios.py`. This script is a wrapper around `elm-make` and should be used for compiling Elm iOS apps. The options and flags behave identically to `elm-make` except for in the following regards.

1. A new flag called `--name` has been added for specifying the [Bundle Identifier]() for your app.
2. The `--output` flag is ignored.

When you run the script, it will create an Xcode project in the `ios/` directory with your compiled Elm program and any static assets that you specify. From there, you can open the `<NAME_OF_YOUR_APP>.xcworkspace` file to run the project using Xcode.

In order to make this process successfully work, there are two naming restrictions that we have established.

1. The Elm module that you compile must be named `Main`. This means that the first line of the Elm file that you pass to `elm-ios.py` should be `module Main exposing (..)`. Once the project is properly integrated with the Elm compiler, this restriction will likely be lifted.

2. All static assets that you want to bundle with your app must be in a directory named `assets` located in your project directory (where your `elm-package.json` file lives).

*Pro Tip: Once you install the package, I recommend moving the `elm-ios.py` script from the elm-ios package directory to your project directory to make it easier to run.*

# Examples

- [Counter]()
- [Image]()

# Limitations

- Keyed nodes
- Limited API

  - UINavigationBar
  - UITabBar
  - UITableView
  - etc.

- No "attributed text" (fine-grained styling for text)

# History

This project started as a [Google Summer of Code project](). This repo is comprised of work from three other repos. The Elm code and JavaScript Kernel code, which now live in `src/` were originally developed in pzp1997/virtual-dom. The Swift code for the app template, which now live in `AppTemplate`, originated in pzp1997/elm-ios-bridge. Lastly, the examples from `examples/` were mainly developed in pzp1997/elm-ios-examples. If you are interested in the early history of the project, or are a of the project or

# Contributing

If you are interested in contributing, contact me _before_ you start working on the project. Doing so makes it easier for me to help you, allows us to use our resources most effectively, and ensures that your efforts will not be in vain. There are plenty of tasks of varying difficulty and time commitment that you can help out with. Please contact me for more info.

# Acknowledgements

First and foremost, I would like to thank Evan Czaplicki for mentoring me this summer. Your advice and insights during our weekly planning sessions were incredibly helpful. I would also like to thank Matthew Griffith for providing me with a space to work and making me feel welcome in the Elm community. Last but certainly not least, I would like to thank my parents for supporting me, being there for me whenever I would discover a serious bug or design flaw, and for always rooting for me.

# Contact Info

Palmer Paul<br>
pzpaul2002@yahoo.com<br>
palmerpa on the [elm-lang Slack][1]

[1]: https://elmlang.herokuapp.com/
