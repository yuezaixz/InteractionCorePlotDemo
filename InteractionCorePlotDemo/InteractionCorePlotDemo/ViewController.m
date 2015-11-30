//
//  ViewController.m
//  InteractionCorePlotDemo
//
//  Created by 吴迪玮 on 15/11/30.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "ViewController.h"

#define TEST_LINE_COLOR [CPTColor colorWithComponentRed:243/255.0 green:103/255.0 blue:53/255.0 alpha:1.0]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) NSMutableArray *plotData;

@end

@implementation ViewController{
    CPTXYGraph *graph;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initChart];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initChart {
    // 创建hostView
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.size.height, (self.view.frame.size.width - 285)/2, 285, 100)];
    [self.view addSubview:hostView];
    
    graph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
    graph.paddingTop = 10.0;
    graph.paddingBottom = 0.0;
    graph.paddingLeft = 0.0;
    graph.paddingRight = 0.0;
    
    NSArray *chartLayers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:CPTGraphLayerTypeAxisLabels],
                            [NSNumber numberWithInt:CPTGraphLayerTypeMajorGridLines],
                            [NSNumber numberWithInt:CPTGraphLayerTypeMinorGridLines],
                            [NSNumber numberWithInt:CPTGraphLayerTypeAxisLines],
                            [NSNumber numberWithInt:CPTGraphLayerTypeAxisTitles],
                            [NSNumber numberWithInt:CPTGraphLayerTypePlots],
                            nil];
    graph.topDownLayerOrder = chartLayers;
    
    hostView.hostedGraph = graph;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // x y 轴
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 2.0;
    majorGridLineStyle.lineColor = [CPTColor colorWithComponentRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        x.axisLineStyle               = majorGridLineStyle;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.majorIntervalLength         = CPTDecimalFromDouble(1);
        x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-10.0);
        x.minorTicksPerInterval       = 0;
        x.labelingPolicy = CPTAxisLabelingPolicyNone;
        x.plotSpace = plotSpace;
    }
    
    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = CPTDecimalFromDouble(10);
        y.minorTicksPerInterval       = 1;
        y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
        y.majorGridLineStyle          = nil;
        y.axisLineStyle               = majorGridLineStyle;
        y.minorTickLineStyle          = majorGridLineStyle;
        y.majorTickLineStyle          = majorGridLineStyle;
        y.tickDirection = CPTSignPositive; //CPTSignNegative  左  CPTSignPositive  右
        y.minorTickLength = 3;
        y.majorTickLength = 5;
        y.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0.0];
        y.delegate = self;
    }
    
    {
        CPTScatterPlot *footScatterPlot = [[CPTScatterPlot alloc] init];
        footScatterPlot.identifier = @"scatterPlot";
        //
        //        CPTGradient *areaGradient = [ CPTGradient gradientWithBeginningColor :FOOT_FILL_COLOR endingColor :FOOT_FILL_COLOR];
        //        // 创建一个颜色填充：以颜色渐变进行填充
        //        CPTFill *areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
        
        CPTMutableLineStyle *neartrateScatterLineStyle = [footScatterPlot.dataLineStyle mutableCopy];
        neartrateScatterLineStyle.lineWidth              = 2.0;
        neartrateScatterLineStyle.lineJoin               = kCGLineJoinRound;
        neartrateScatterLineStyle.lineGradient           = [CPTGradient gradientWithBeginningColor:FOOT_BACK_LINE_COLOR endingColor:FOOT_BACK_LINE_COLOR];
        footScatterPlot.interpolation = CPTScatterPlotInterpolationCurved;
        footScatterPlot.dataLineStyle = neartrateScatterLineStyle;
        footScatterPlot.dataSource    = self;
        //        footScatterPlot.areaFill = areaGradientFill;
        footScatterPlot.areaBaseValue = CPTDecimalFromString ( @"-10.0" );
        
        [graph addPlot:footScatterPlot];
    }
    
}

- (void)initData{
    NSArray *sampleArray = @[@23,@43,@65,@23,@46,@56,@23,@43,@65,@23,@54,@23,@23,@15,@75,@23];
    
    NSInteger maxValue = 0;
    
    if (sampleArray.count > 0) {
        self.plotData = [sampleArray copy];
        maxValue = [[sampleArray valueForKeyPath:@"@max.integerValue"] integerValue];
    }
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.momentumAnimationCurve = CPTAnimationCurveCubicIn;
    plotSpace.bounceAnimationCurve = CPTAnimationCurveBackIn;
    plotSpace.momentumAcceleration = 20000.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(60)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-10.0) length:CPTDecimalFromDouble(maxValue+20)];
    
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(self.plotData.count+10)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-10.0) length:CPTDecimalFromDouble(maxValue+20)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    NSArray *exclusionRangesY = [NSArray arrayWithObjects:
                                 [self CPTPlotRangeFromFloat:maxValue+8 length:15], nil];
    y.labelExclusionRanges = exclusionRangesY;
    
    [graph reloadDataIfNeeded];
    [footScatterPlot reloadPlotData];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.plotData count]+10;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if(fieldEnum == CPTScatterPlotFieldY) {
        if (index<10) {
            return @0;
        }
        if ([plot.identifier isEqual:@"scatterPlot"]) {
            return [self.plotData objectAtIndex:index-10];
        }
        return nil;
    }
    else if (fieldEnum == CPTScatterPlotFieldX) {
        return @(index);
    }
    else if (fieldEnum == CPTRangePlotFieldHigh || fieldEnum == CPTRangePlotFieldLow) {
        return @(60);
    }
    else {
        
        return @(index);
    }
}

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle * positiveStyle = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    formatter.numberStyle = NSNumberFormatterRoundCeiling;
    CGFloat labelOffset             = axis.labelOffset;
    NSDecimalNumber * zero          = [NSDecimalNumber zero];
    
    NSMutableSet * newLabels        = [NSMutableSet set];
    
    for (NSDecimalNumber * tickLocation in locations) {
        CPTTextStyle *theLabelTextStyle;
        
        if ([tickLocation isGreaterThanOrEqualTo:zero]) {
            if (!positiveStyle) {
                CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor colorWithComponentRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1.0];
                positiveStyle  = newStyle;
            }
            
            theLabelTextStyle = positiveStyle;
        }
        else {
            continue;
        }
        
        NSString * labelString      = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation       = tickLocation.decimalValue;
        newLabel.offset             = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}

@end
