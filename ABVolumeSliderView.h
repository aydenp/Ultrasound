//
//  ABVolumeSliderView.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABInstantPanGestureRecognizer.h"

@protocol ABVolumeSliderViewDelegate <NSObject>
@required
- (void)sliderValueChangedTo:(CGFloat)value;
@optional
- (void)sliderBeingTouchedChangedTo:(BOOL)isBeingTouched;
- (void)userChangedSliderValueTo:(CGFloat)value;
@end

@interface ABVolumeSliderView : UIView
@property (nonatomic, weak) NSObject <ABVolumeSliderViewDelegate>*delegate;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic) CGFloat barAlpha;
@property (nonatomic, weak) UIView *viewToAnimateLayout;
@property (nonatomic, retain, readonly) ABInstantPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, retain) UIColor *knobColour;
@property (nonatomic, assign) BOOL knobHasShadow;
@property (nonatomic, retain) UIColor *trackColour;
@property (nonatomic, retain) UIColor *filledTrackColour;
- (void)setEditable:(BOOL)editable animated:(BOOL)animated;
- (NSLayoutAnchor *)knobVerticalAnchor;
@end
