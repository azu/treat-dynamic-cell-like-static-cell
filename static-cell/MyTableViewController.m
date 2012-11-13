#import "MyTableViewController.h"
#import "TimeStampCell.h"
#import "AddStampCell.h"

#define kCellIdentifier @"CellIdentifier"

@interface MyTableViewController ()

@end

@implementation MyTableViewController {
}

@synthesize sectionTitles = _sectionTitles;
@synthesize timeStampDataSource = _timeStampDataSource;
@synthesize timeStamps = _timeStamps;


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self){
        return nil;
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // DataSource init
    [self initDataSource];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)addTimeStamp {
    // タイムスタンプの追加
    [_timeStamps addObject:[NSDate date]];
    // dataSourceにも数を合わせる
    [_timeStampDataSource addObject:@{
    kCellIdentifier: self.idTimeCell
    }];
}

- (void)initDataSource {
    /*
        @[
            // section
            @[
                // cell
                @{
                    kCellIdentifier : @"cell id"
                },
            ],
            // section
            @[
                // cell
                @{
                    kCellIdentifier : @"cell id",
                },
                // cell
                @{
                    kCellIdentifier : @"cell id",
                },
            ],
        ];
    */

    // 最初に1つだけ置いておく
    self.timeStamps = [@[
        [NSDate date]
    ] mutableCopy];
    // timeStampのdataSource
    self.timeStampDataSource = [[NSMutableArray alloc] initWithArray:@[@{
        kCellIdentifier: self.idTimeCell
    }]];

    // セクションタイトル
    self.sectionTitles = @[@"名前", @"タイムスタンプ"];

    [self updateDataSource];
}

- (void)updateDataSource {
    self.dataSource = [[NSMutableArray alloc] initWithArray:@[
    // static
    @[
        @{
        kCellIdentifier: self.idNameCell
        }
    ],
    // dynamic
    [self timeStampAddDataSource]
    ]];
}

// 末尾にAddCellを追加したdataSourceを返す
- (NSArray *)timeStampAddDataSource {
    NSArray *array = [self.timeStampDataSource copy];
    return [array arrayByAddingObject:@{
    kCellIdentifier:self.idAddCell
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // deselect cell
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    //  update visible cells
    [self updateVisibleCells];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Cell Operation
- (void)updateVisibleCells {
    // セルの表示更新
    for (UITableViewCell *cell in [self.tableView visibleCells]){
        [self updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) [indexPath section];
    NSUInteger row = (NSUInteger) [indexPath row];
    // Update Cells
    NSDictionary *dictionary = [self dataForIndexPath:indexPath];
    // タイムスタンプのセル
    if ([[dictionary objectForKey:kCellIdentifier] isEqualToString:self.idTimeCell]){
        NSDate *date = [self.timeStamps objectAtIndex:row];
        NSString *timeStampText = [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]];
        [(TimeStampCell *) cell timeStampLabel].text = timeStampText;
    }
}
//--------------------------------------------------------------//
#pragma mark -- UITableViewDataSource --
//--------------------------------------------------------------//
// セクションタイトル
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:(NSUInteger) section];
}

// Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

// Section -> Row
- (NSInteger)tableView:(UITableView *)tableView
             numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionDataSource = [self.dataSource objectAtIndex:(NSUInteger) section];
    return [sectionDataSource count];
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = (NSUInteger) [indexPath section];
    NSUInteger row = (NSUInteger) [indexPath row];
    return [[self.dataSource objectAtIndex:section]
                             objectAtIndex:row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = [self dataForIndexPath:indexPath];
    NSString *cellIdentifier = [dictionary objectForKey:kCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    // add event
    if ([cellIdentifier isEqualToString:self.idAddCell]){
        [[(AddStampCell *) cell addButton]
                                addTarget:self action:@selector(handleAddCell:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self updateCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)handleAddCell:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    [self addStampCellAndInsert:indexPath];
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}
//--------------------------------------------------------------//
#pragma mark -- UITableViewDelegate --
//--------------------------------------------------------------//

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // ハイライトを外す
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)addStampCellAndInsert:(NSIndexPath *)indexPath {
    [self addTimeStamp];
    [self updateDataSource];
    //テーブルの最後の行にアイテムを追加
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //追加した行へスクロール
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
