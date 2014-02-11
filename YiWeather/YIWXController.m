//
//  WXController.m
//  YiWeather
//
//  Created by Yi Wang on 2/3/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIWXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "YIWXManager.h"


@interface YIWXController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation YIWXController

// As date formatters are expensive to create, we’ll instantiate them in our init method and store references to them using these properties.
/*
 -viewDidLoad can actually be called several times in the lifecycle of a view controller. NSDateFormatter objects are expensive to initialize, but by placing them in -init you’ll ensure they’re initialized only once by your view controller.
 */
- (id) init
{
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1  Get and store screen height, we'll need later when displaying weather data in a paged manner
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // 2  Create static image background and add it to the view
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 3 Create blurred bg img using LBBlurredImage, and set alpha to 0 initially so backgroundImageView is visible first
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // 4 create tableview that handles all data presentation. WXController will be delegate and datasource as well as scroll view delegate. Note: we are also setting paginEnable to YES
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 5 Set header of tableview to be same size of our screen. We will take advantage of UITableView's paging, which will page the header and the daily and hourly forecast sections.
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    // 6 Create an inset (or padding) variable so that all of our labels are evenly spaced and centered
    CGFloat inset = 20;
    
    // 7 Create and initialize height variables for various views. Setting these as consts akes it easy to configure and change view setup if required
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    // 8 Create frames for labels and icon view based on constnt and inset variables
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    // 9 Copy icon frame adjust it so text has some room to expand, move it to the right of the icon.
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // 10 Set the current-conditions view as our table header
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 11 Build each required label to display weather data
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    [header addSubview:conditionsLabel];
    
    // 12 Add an image view for a weather icon
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];

    
    
    [[YIWXManager sharedManager] findCurrentLocation];
    
    // Observe the currentCondition key on the YIWXManager singleton
    [[RACObserve([YIWXManager sharedManager], currentCondition)
     // Delivers and changes in the main thread since we are updating the UI
     deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(YIWXCondition *newCondition) {
         // Updates the text labels with weather data; you’re using newCondition for the text and not the singleton. The subscriber parameter is guaranteed to be the new value.
         
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // Uses the mapped image file name to create an image and sets it as the icon for the view.
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
         
     }];
    
    
    [[RACObserve([YIWXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([YIWXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
  
    
    
    
    /********** Cocoa bindings **********/
    
    // The RAC(…) macro helps keep syntax clean. The returned value from the signal is assigned to the text key of the hiloLabel object.
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       // Observe the high and low temperatures of the currentCondition key. Combine the signals and use the latest values for both. The signal fires when either key changes.
                                                       RACObserve([YIWXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([YIWXManager sharedManager], currentCondition.tempLow)
                                                       ]
                             // Reduce the values from your combined signals into a single value; note that the parameter order matches the order of your signals.
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                                              }]
                            // Again, since you’re working on the UI, deliver everything on the main thread.
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// called when our view need to layout subviews
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}



// 1 pragma marks are great way to help organize our code
#pragma mark - UITableViewDataSource

// 2 Our table view has 2 sections, one fo hourly forecasts and one for daily.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     We’re using table cells for headers here instead of the built-in section headers which have sticky-scrolling behavior. The table view is set up with paging enabled and sticky-scrolling behavior would look odd in this context
     */
    // The first section is for the hourly forecast. Use the six latest hourly forecasts and add one more cell for the header.
    if (section == 0) {
        return MIN([[YIWXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    // The next section is for daily forecasts. Use the six latest daily forecasts and add one more cell for the header.
    return MIN([[YIWXManager sharedManager].dailyForecast count], 6) + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // 3 Forecast cell shouldn't be selectable. Give them semi transparent black backgrund and white text
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    
    
    if (indexPath.section == 0) {
        // The first row of each section is the header cell
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        } else {
            // Get the hourly weather and configure the cell using custom configure methods.
            YIWXCondition *weather = [YIWXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
        
    } else if (indexPath.section == 1) {
        // The first row of each section is the header cell
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            // Get the daily weather and configure the cell using another custom configure method.
            YIWXCondition *weather = [YIWXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(YIWXCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(YIWXCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Get the height of the scroll view and the content offset. Cap the offset at 0 so attempting to scroll past the start of the table won’t affect blurring.
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // Divide the offset by the height with a maximum of 1 so that your offset is capped at 100%.
    CGFloat percent = MIN(position / height, 1.0);
    // Assign the resulting value to the blur image’s alpha property to change how much of the blurred image you’ll see as you scroll.
    self.blurredImageView.alpha = percent;
}

@end
