Below are a list of TODOs for the project. Before working on any of these, you **must** contact me so we can coordinate. The projects range in difficulty and requisite knowledge, so there should be something for everyone who wants to contribute.

- Keyed nodes
    - Description: Add support for keyed nodes.
    - Categories: JS implementation, minimal Elm/Swift implementation
    - Starting Points: Implementation of `parent` in Native/Element.js
    - Difficulty: 2/5


- Primitives++
    - Description: We need more primitive elements, in order to make the framework fully expressive. Right now we have labels, buttons, and containers. We would like to add switches, sliders, text input, lists/tables, etc.
    - Categories: Minimal Elm/JS/Swift implementation, Elm API design
    - Starting Points: Implementations of existing primitives
    - Difficulty: 1/5 - 3/5 (varies depending on the particular primitive)


- Multithreading
    - Description: Run UIKit rendering methods on main thread and Elm code on a separate thread.
    - Categories: Swift implementation, research/compare different methods
    - Starting Points: Grand Central Dispatch (GCD), NSThreads
    - Difficulty: 4/5


- HTTP requests
    - Description: Make elm-lang/http work with Elm iOS. Believe it or not, `XMLHttpRequest` (XHR) is not part of any formal spec, but rather is considered part of the so called “Browser Object Model” (BOM). Since JavaScriptCore only implements the ECMAScript standard, we need to provide our own Swift implementation for XHR.
    - Categories: Swift implementation, research/compare different methods
    - Starting Points: elm-lang/http, URLSession, AlamoFire
    - Difficulty: 3/5


- Stricter types for attributes
    - Description: Currently, if an improper value is specified for an attribute, it is ignored (mainly applies for enum values that we are representing as Strings). Ideally, we would want the compiler to be able to catch these mistakes.
    - Categories: Elm implementation, Elm API design
    - Starting Points: rtfeldman/elm-css
    - Difficulty 2.5/5


- Attributed text
    - Description: iOS allows you to have fine-grained control over text styling via a mechanism called attributed text. We want to provide similar functionality in Elm iOS. A big component of this project is coming up with a suitable Elm API for doing this.
    - Categories: Elm/Swift implementation, minimal JS implementation, API design
    - Starting Points: Apple docs on attributed text
    - Difficulty: 3.5/5


- Navigation
    - Description: Most iOS apps provide some form of navigation. Currently, the best way to navigate between screens with Elm iOS is using buttons, which requires quite a bit of manual wiring up. Since this issue is currently being worked on for Elm proper, it might be best to wait to see what Evan comes up with and then sync up.
    - Categories: Brainstorming and researching potential methods
    - Starting Points: Current thoughts on Elm navigation/routing, Apple docs on navigation (UITabBar, UINavigationBar)
    - Difficulty: ???
