#import "MyClass.h"

#define kSwipeMinimumLength 0.3

@implementation MyClass

@synthesize twoFingersTouches;

// Three fingers gesture, Lion (if enabled) and Leopard
- (void)swipeWithEvent:(NSEvent *)event {
    CGFloat x = [event deltaX];
    //CGFloat y = [event deltaY];
    
    if (x != 0) {
		(x > 0) ? [self goBack] : [self goForward];
	}
}


-(BOOL)recognizeTwoFingerGestures
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"AppleEnableSwipeNavigateWithScrolls"];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
    if (![self recognizeTwoFingerGestures])
        return;
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    self.twoFingersTouches = [[NSMutableDictionary alloc] init];
    
    for (NSTouch *touch in touches) {
        [twoFingersTouches setObject:touch forKey:touch.identity];
    }
}

- (void)endGestureWithEvent:(NSEvent *)event
{
    if (!twoFingersTouches) return;
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    // release twoFingersTouches early
    NSMutableDictionary *beginTouches = [twoFingersTouches copy];
    self.twoFingersTouches = nil;
    
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
    
    for (NSTouch *touch in touches) 
    {
        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
        
        if (!beginTouch) continue;
        
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
    
    // Need at least two points
    if ([magnitudes count] < 2) return;
    
    float sum = 0;
    
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        sum *= -1;
    
    // See if absolute sum is long enough to be considered a complete gesture
    float absoluteSum = fabsf(sum);

    if (absoluteSum < kSwipeMinimumLength) return;

    // Handle the actual swipe
    if (sum > 0) 
    {
        [self goForward];
    } else
    {
        [self goBack];
    }
    
    
}

@end