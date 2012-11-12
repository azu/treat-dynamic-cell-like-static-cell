#import "MyTableViewController.h"
#import "TimeStampCell.h"
#import "AddStampCell.h"

#define kCellIdentifier @"CellIdentifier"

@interface MyTableViewController ()

@end

@implementation MyTableViewController {
@private
    id _sectionTitles;
    NSMutableArray *_timeStampDataSource;
    NSMutableArray *_timeStamps;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)addTimeStamp {
    [self.timeStamps addObject:[NSDate date]];
    // timeStampのdataSource
    [self.timeStampDataSource addObject:@{
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
    self.timeStampDataSource = [@[@{
    kCellIdentifier: self.idTimeCell
    }] mutableCopy];


    self.dataSource = [[NSMutableArray alloc] initWithArray:@[
    // static
    @[
    @{
    kCellIdentifier: self.idNameCell
    }
    ],
    // dynamic
    self.timeStampDataSource
    ]];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    // DataSource init
    self.sectionTitles = @[@"名前", @"タイムスタンプ"];
    [self initDataSource];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Update Navigation
    [self updateNavigationItemAnimated:animated];

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

//--------------------------------------------------------------//
#pragma mark -- ViewOutlets Update --
//--------------------------------------------------------------//

- (void)updateNavigationItemAnimated:(BOOL)animated {
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
#pragma mark - footer timestamp
// タイムスタンプのfooterには追加ボタンを付ける
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSDictionary *dictionary = [[self.dataSource objectAtIndex:section] lastObject];
    // タイムスタンプのセル
    if (![[dictionary objectForKey:kCellIdentifier] isEqualToString:self.idTimeCell]){
        return 0.0f;
    }
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSDictionary *dictionary = [[self.dataSource objectAtIndex:section] lastObject];
    // タイムスタンプのセル
    if (![[dictionary objectForKey:kCellIdentifier] isEqualToString:self.idTimeCell]){
        return nil;
    }
    NSString *cellIdentifier = self.idAddCell;
    AddStampCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[AddStampCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.addButton addTarget:self action:@selector(addStampCell:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
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
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self updateCell:cell atIndexPath:indexPath];

    return cell;
}

//--------------------------------------------------------------//
#pragma mark -- UITableViewDelegate --
//--------------------------------------------------------------//

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // ハイライトを外す
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// タイムスタンプを追加する
- (IBAction)addStampCell:(id)sender {
    [self addTimeStamp];
    [self.tableView reloadData];
}
@end
fgi