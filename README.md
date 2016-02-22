# endlessTableView

Endless - Infinite &amp; Double Table Together Parallax Animation &amp; Auto Scrolling


## Display Type Visual Examples 

----
![Visual1](http://g.recordit.co/DhtE6kevrL.gif)
----
![Visual2](http://g.recordit.co/mmMIbsPLCR.gif)
----
![Visual3](http://g.recordit.co/uCKOF0zCbd.gif)


Properties
--------------

The EndlessTableView has the following properties (note: for iOS, UITableView when using properties):

    @property (nonatomic) BOOL enableEndlessScrolling 

The default value is YES.

    @property (nonatomic) BOOL enableAutoScrolling;

The default value is NO.

    @property (nonatomic) CGFloat autoScrollValue;

This property can be used to set the table scrolling at a constant speed. A value of 1.0 would scroll the carousel forwards at a rate of one item per second. The autoscroll value can be positive or negative and defaults to 0.0 (stationary). Autoscrolling will stop if the user interacts with the table, and will resume when they stop. The default value is 0.0f.

    @property (nonatomic) CGFloat differenceRateValue;

If attachedTableView and contentSize of this event of an equal, differenceRateValue processing are taken. The default value is 1.0f.

    @property (nonatomic,weak) EndlessTableView *attachedTableView;

The default value is nil.


How to use ?
----------

![Visual4](http://g.recordit.co/ykx1SbnAmZ.gif)
----

```Objective-C
#import "EndlessTableView.h"
...

@property (weak, nonatomic) IBOutlet EndlessTableView *tableViewProduct;
@property (weak, nonatomic) IBOutlet EndlessTableView *tableViewCampaign;

- (void)loadView
{
[super loadView];

self.tableViewProduct.attachedTableView = self.tableViewCampaign;
self.tableViewProduct.enableAutoScrolling = YES;
self.tableViewProduct.differenceRateValue = 1.3f;

[_tableViewProduct reloadData];

[_tableViewCampaign reloadData];

}
```

OR

```Objective-C
#import "EndlessTableView.h"

- (void)loadView
{
[super loadView];

EndlessTableView *tableViewCampaign = [[EndlessTableView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height)];
tableViewCampaign.dataSource = self;
tableViewCampaign.delegate = self;

EndlessTableView *tableViewProduct = [[EndlessTableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height)];
tableViewProduct.dataSource = self;
tableViewProduct.delegate = self;

tableViewProduct.attachedTableView = tableViewCampaign;
tableViewProduct.enableAutoScrolling = YES;
tableViewProduct.differenceRateValue = 1.3f;

}
```

Build and run the project files. Enjoy more examples!