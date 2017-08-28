# Elm iOS

## Bringing the wonders of Elm to the iOS platform

## Current Status

I have shown that it is possible to use Elm to create native mobile apps, succeeding in my stated goal for the summer. That said, the project is still in an early alpha stage and definitely should not be used for production apps yet. Currently, the project supports only a small subset of the UIKit elements, meaning that it does not have the full expressive power of an app written purely in Obj-C/Swift.

Looking ahead, I intend to actively maintain the project, however, new development will slow down while I am at university. If you are interested in contributing, read the section below.

## Usage

Included in the package is a CLI script called `elm-ios.py`. This script is a wrapper around `elm-make` that should be used for compiling Elm iOS apps. The options and flags behave identically to `elm-make` except for in the following regards.

1. A new flag called `--name` has been added for specifying the bundle identifier for your app. The bundle identifier is typically written using reverse domain name notation, e.g. `com.palmerpaul.MyAwesomeApp`.
2. The `--output` flag is ignored.

When you run the script, it will create an Xcode project in the `ios/` directory with your compiled Elm program and static assets. From there, you can open the `<NAME_OF_YOUR_APP>.xcworkspace` file to run or modify the project using Xcode. Note that each time the script is run it will clean the `ios/` directory, so to prevent data loss, try not to store anything important in there.

In order to make this process successfully work, there are two naming restrictions that we have established.

1. The Elm module that you compile must be named `Main`. This means that the first line of the Elm file that you pass to `elm-ios.py` should be `module Main exposing (..)`. (Once this project is properly integrated with the Elm compiler, this restriction will likely be lifted.)
2. All static assets that you want to bundle with your app must be in a directory named `assets/` located in your project directory (where your `elm-package.json` file lives).

_Pro Tip: Once you install the package, I recommend moving the `elm-ios.py` script from the elm-ios package directory to your project directory to make it easier to run._

## Examples

Below are some examples that I created to demonstrate the capabilities of this project. If you make something cool with Elm iOS, please let me know so that it can be featured here.

- [Basic Counter](https://github.com/pzp1997/elm-ios/blob/master/examples/BasicCounter.elm)
- [Elm Image](https://github.com/pzp1997/elm-ios/blob/master/examples/ElmImage.elm)
- [Tick](https://github.com/pzp1997/elm-ios/blob/master/examples/Tick.elm)

## Documentation

There is no documentation for this project yet. This decision was made somewhat intentionally in order to emphasize the experimental nature of this project. For the time being, in lieu of documentation here are some high-level tips to help you should you choose to experiment with this project.

Currently, there are five elements available to you: `row`, `column`, `label`, `button`, `image`. `row` and `column` accept a list of attributes and a list of children, while the others accept only a list of attributes.

These five elements accept most of the attributes of their corresponding UIKit element (those that are not allowed violate the principles of the Elm architecture), so the [UIKit documentation](https://developer.apple.com/documentation/uikit) is a good place to look for details about them. `row` and `column` correspond to `UIView`, and `label`, `button`, and `image` correspond to `UILabel`, `UIButton`, and `UIImageView` respectively.

Since we use [Yoga](https://facebook.github.io/yoga/) as our layout engine, all flexbox properties should be supported. For more details about layout attributes, consult the Yoga documentation.

In addition to this advice, you can look at the examples for guidance. If you are genuinely stuck on something, feel free to open a GitHub issue.

## Limitations

There are some limitations to this project. I do not believe that any of these limitations are insurmountable given sufficient time to work on them.

- Many UIKit elements are missing, i.e. UINavigationBar, UITabBar, UITableView, UITextView, UISlider, UISwitch, etc.
- There is no way to interact with the device APIs
- Keyed nodes are not supported
- "Attributed text" (text with fine-grained styling) is not supported

## Blog Posts

Throughout the summer, I authored a series of blog posts giving status updates on the project. These blog posts can be a useful resource to those who are interested in understanding the reasoning behind some of the major design choices that I made.

- [July 7th](https://groups.google.com/forum/m/#!topic/elm-dev/D03BAaPsh70)
- [June 23rd](https://groups.google.com/forum/m/#!topic/elm-dev/h14CL_5ARUo)
- [June 9th](https://groups.google.com/forum/m/#!topic/elm-dev/mzU6oBCelH4)

## History

This project started as a [Google Summer of Code project](https://summerofcode.withgoogle.com/projects/#4964906492231680). After trying out Elm for about a week, I realized that I wanted to spend my summer working with the Elm Software Foundation. When searching for project ideas, I stumbled across [ohanhi/elm-native-ui](https://github.com/ohanhi/elm-native-ui) which is a library that uses React Native to create mobile Elm apps. After meeting with Ossi and Evan to discuss the possibility of working on that project for the summer, we decided that it would be best to try to create an Elm iOS solution that does not rely on third-party frameworks. I submitted a [proposal](https://drive.google.com/file/d/0BwjaN8fv6J6TWVdsRHhSVTZGa2s/view?usp=sharing) for what would ultimately become this project and was accepted for the Google Summer of Code program.

This repo is comprised of work from three other repos (although all further development on elm-ios will happen here). The Elm code and JavaScript Kernel code, which now live in `src/`, were originally developed in [pzp1997/virtual-dom](https://github.com/pzp1997/virtual-dom). The Swift code for the app template, which now lives in `AppTemplate`, originated in [pzp1997/elm-ios-bridge](https://github.com/pzp1997/elm-ios-bridge). Lastly, the examples from `examples/` were mainly developed in [pzp1997/elm-ios-examples](https://github.com/pzp1997/elm-ios-examples). If you are interested in the early commit history of the project, you should definitely take a look at those repos.

## Contributing

If you are interested in contributing, contact me _before_ you start working on the project. Doing so makes it easier for me to help you, allows us to use our resources most effectively, and ensures that your efforts will not be in vain. There are plenty of tasks of varying difficulty and time commitment that you can help out with. Please contact me for more info.

## Acknowledgements

First and foremost, I would like to thank Evan Czaplicki for mentoring me this summer. Your advice and insights during our weekly planning sessions were incredibly helpful. I would also like to thank Matthew Griffith for providing me with a space to work and making me feel welcome in the Elm community. Last but certainly not least, I would like to thank my parents for supporting me, being there for me whenever I would discover a serious bug or design flaw, and for always rooting for me.

## Contact Info

Palmer Paul<br>
pzpaul2002@yahoo.com<br>
palmerpa on the [elm-lang Slack](https://elmlang.herokuapp.com/)
