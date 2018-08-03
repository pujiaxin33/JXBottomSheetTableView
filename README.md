# JXBottomSheetTableView
A highly packaged, easy to use custom bottom sheet UITableView.

**The better scheme**
Less limit and easy to use, check below:
https://github.com/pujiaxin33/JXBottomSheetView

# Features

- Simple: `JXBottomSheetTableView` is subclass of UITableView, so you can use `JXBottomSheetTableView` just like UITableView;
- Adaptive based on contentSize: Whether you are adding or deleting item.
- Solve big problem: When the TableView scrolls to the top, it can still scroll through the contents without breaking the gesture;

# Preview
- scroll up & scroll down

![Scrolling](https://github.com/pujiaxin33/JXBottomSheetTableView/blob/master/JXBottomSheetTableView/Gif/Scrolling.gif)

- Manual trigger

![Trigger](https://github.com/pujiaxin33/JXBottomSheetTableView/blob/master/JXBottomSheetTableView/Gif/ManualTrigger.gif)

- Data source changed

![Changed](https://github.com/pujiaxin33/JXBottomSheetTableView/blob/master/JXBottomSheetTableView/Gif/Changed.gif)

# Usage

- displayState

Set it to decide which state use for initialize.

- defaultMininumDisplayHeight

When you scroll down, the `JXBottomSheetTableView` mininum display height. when the `contentSize.height` less than it, the mininum display height equal to `contentSize.height`.
If you want to hide  `JXBottomSheetTableView`, set defaultMininumDisplayHeight zero.

- defaultMaxinumDisplayHeight

When you scroll up, the `JXBottomSheetTableView` maxinum display height. 

- triggerDistance

The distance of determine whether to trigger state  when scrolling.

- isTriggerImmediately

If `true`,scroll distance equal to `triggerDistance`, trigger state imemediately.
if `false`,when user did end drag to trigger state.

# Use case

```swift
let tableView = JXBottomSheetTableView.init(frame: CGRect.zero, style: .plain)
tableView.displayState = .maxDisplay
tableView.defaultMininumDisplayHeight = 150
tableView.defaultMaxinumDisplayHeight = 400
tableView.showsVerticalScrollIndicator = false
tableView.showsHorizontalScrollIndicator = false
tableView.separatorStyle = .none
tableView.delegate = self
tableView.dataSource = self
tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
view.addSubview(tableView)
```
- Tips: If `UIViewController view` add it, should call below code:

```swift
if #available(iOS 11.0, *) {
tableView.contentInsetAdjustmentBehavior = .never
}else {
self.automaticallyAdjustsScrollViewInsets = false
}
```











