# LongPressTableViewReordering

[![CI Status](http://img.shields.io/travis/danielsaidi/LongPressTableViewReordering.svg?style=flat)](https://travis-ci.org/danielsaidi/LongPressTableViewReordering)
[![Version](https://img.shields.io/cocoapods/v/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)
[![License](https://img.shields.io/cocoapods/l/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)
[![Platform](https://img.shields.io/cocoapods/p/LongPressTableViewReordering.svg?style=flat)](http://cocoapods.org/pods/LongPressTableViewReordering)


## What is this?

LongPressTableViewReordering is a Swift library, that lets you reorder
cells in a UITableView by long pressing any cell in the table view.



## Acknowledgement

This project is a Swift adaption of the original obj-c approach posted
by Soheil Ahzarpour on raywenderlich.com, March 24, 2014:

[Read the original post](https://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture)

I will add more features to this lib if I need more in my own projects,
but wherever the project goes, it wouldn't have existed without Soheil.



## How does it work?

To add long press reorder functionality to a table view, make the data
source implement the LongPressTableViewReorderer protocol as well. The
protocol (due to Swift limitations) must be a bit tweaked to work, but
it is fairly straightforward.

First, the protocol requires two backing fields. Just declare them and
leave them without an initial value. You will never use the properties
yourself, but the protocol extension will use them under the hood.

Second, call the `enableLongPressReorderingForTableView(...)` function
to enable long press reordering. Since a protocol extension cannot set
a target action, you must inject a gesture listener function as use it
to call `longPressReorderGestureChanged(...)` from your class.

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

