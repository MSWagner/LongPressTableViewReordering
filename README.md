# LongPressTableViewReordering

[![CI Status](http://img.shields.io/travis/danielsaidi/LongPressTableViewReordering.svg?style=flat)](https://travis-ci.org/danielsaidi/LongPressTableViewReordering)
[![Version](https://img.shields.io/cocoapods/v/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)
[![License](https://img.shields.io/cocoapods/l/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)
[![Platform](https://img.shields.io/cocoapods/p/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)


## What is this?

`LongPressTableViewReordering` is a Swift library that lets users long
press to reorder cells in a table view. It is a Swift adaption of this
original Objective-C approach, posted on March 24, 2014:

[Read the original post](https://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture)

I will add more features to this lib if I need more in my own projects.



## How does it work?

To add long press reorder functionality to a table view, make the data
source implement `LongPressTableViewReorderer`, then do the following:

First, the protocol requires two backing fields. Just declare them and
leave them without initial values. You will never use these properties
yourself, but the reorderer will use them under the hood.

Now you can call `enableLongPressReorderingForTableView` to let a user 
reorder cells with a long press. Since a protocol extension cannot set
target actions, you must inject a gesture listener that is responsible
to call `longPressReorderGestureChanged` from your class.

If you know a better way to achieve the same result, feel free to help.



## Example Project

The example project is currently empty. I will add a reorderable table
view whenever I manage to find some time in this crazy world of ours.



## Installation


### Cocoapods

This lib is available through [CocoaPods](http://cocoapods.org/). Just
add the following line to your Podfile and run `pod install` to add it
to your project.

```ruby
pod "LongPressTableViewReordering"
```



## Versioning

Versions < 1.0.0 will have breaking changes between minor versions, so
LongPressTableViewReordering 0.3.0 may not be compatible with 0.2.0.



## Author

Daniel Saidi, daniel.saidi@gmail.com



## License

LongPressTableViewReordering is available under the MIT license.
See the LICENSE file for more info.

