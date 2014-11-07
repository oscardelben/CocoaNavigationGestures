#import "MyClass.h"

#define kSwipeMinimumLength 0.2

@implementation MyClass

- (void)touchesBeganWithEvent:(NSEvent *)event{
    if(event.type == NSEventTypeGesture){
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if(touches.count == 2){
            self.twoFingersTouches = [[NSMutableDictionary alloc] init];
            
            for (NSTouch *touch in touches) {
                [self.twoFingersTouches setObject:touch forKey:touch.identity];
            }
        }
    }
}


- (void)touchesMovedWithEvent:(NSEvent*)event {
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];
    if(touches.count > 0){
        NSMutableDictionary *beginTouches = [self.twoFingersTouches copy];
        self.twoFingersTouches = nil;
        
        NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
        
        for (NSTouch *touch in touches)
        {
            NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
            
            if (!beginTouch) continue;
            
            float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
            [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
        }
        
        float sum = 0;
        
        for (NSNumber *magnitude in magnitudes)
            sum += [magnitude floatValue];
        
        // See if absolute sum is long enough to be considered a complete gesture
        float absoluteSum = fabsf(sum);
        
        if (absoluteSum < kSwipeMinimumLength) return;
        
        // Handle the actual swipe
        // This might need to be > (i am using flipped coordinates)
        if (sum > 0){
            NSLog(@"go back");
        }else{
            NSLog(@"go forward");
        }
    }
}

@end