#import <UIKit/UIKit.h>

@interface MyTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {


}

@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, strong) NSArray * sectionTitles;

- (IBAction)addStampCell:(id)sender;

#pragma mark - user defined runtime attributes
@property(nonatomic, strong) NSString *idNameCell;
@property(nonatomic, strong) NSString *idTimeCell;
@property(nonatomic, strong) NSString *idAddCell;

@property(nonatomic, strong) NSMutableArray *timeStampDataSource;
@property(nonatomic, strong) NSMutableArray *timeStamps;
@end
