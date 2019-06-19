//
//  ABInstantPanGestureRecognizer.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2018-09-09.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABInstantPanGestureRecognizer : UIPanGestureRecognizer
- (BOOL)isBeingTouched;
@end

NS_ASSUME_NONNULL_END
