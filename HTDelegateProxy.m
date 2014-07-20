//
//  HTDelegateProxy.m
//  HotelTonight
//
//  Created by Jacob Jennings on 10/21/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//
/*
 Copyright (c) 2012 Hotel Tonight
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "HTDelegateProxy.h"

@interface HTDelegateProxy ()

@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation HTDelegateProxy

@synthesize delegates = _delegates;

- (id)initWithDelegates:(NSArray *)delegates
{
    self = [self init];
    
    if (self)
    {
        [self addDelegates:delegates];
    }
    
    return self;
}

- (id)init
{
    [self configureDelegateProxy];
    
    return self;
}

- (void)configureDelegateProxy
{
    _delegates = [[NSMutableArray alloc] init];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = nil;
    
    for (NSValue *nonRetainedValue in _delegates)
    {
        id delegate = [nonRetainedValue nonretainedObjectValue];
        
        signature = [[delegate class] instanceMethodSignatureForSelector:selector];
        
        if (signature)
        {
            break;
        }
    }
    
    if (signature == nil)
    {
        signature = [[self class] instanceMethodSignatureForSelector:@selector(doNothing:)];
        
        [self logNoMethodSignatureFoundForSelector:selector];
    }
    
	return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
    BOOL voidReturnType = [returnType isEqualToString:@"v"];
    
    for (NSValue *nonRetainedValue in _delegates)
    {
        id delegate = [nonRetainedValue nonretainedObjectValue];
        if ([delegate respondsToSelector:invocation.selector])
        {
            [invocation invokeWithTarget:delegate];
            if (!voidReturnType)
            {
                return;
            }
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    for (NSValue *nonRetainedValue in _delegates)
    {
        id delegate = [nonRetainedValue nonretainedObjectValue];
        if ([delegate respondsToSelector:aSelector])
        {
            if ([delegate isKindOfClass:[UITextField class]]
                && [[UITextField class] instancesRespondToSelector:aSelector])
            {
                continue;
            }
            return YES;
        }
    }
    return NO;
}

- (void)doNothing:(SEL)selector
{
    
}

- (void)logNoMethodSignatureFoundForSelector:(SEL)selector
{
    NSLog(@"[HTDelegateProxy] No method signature found for selector %@", NSStringFromSelector(selector));
}

#pragma mark - Properties

- (NSArray *)delegates
{
    NSMutableArray *delegatesBuilder = [NSMutableArray arrayWithCapacity:[_delegates count]];
    
    for (NSValue *delegateValue in _delegates)
    {
        [delegatesBuilder addObject:[delegateValue nonretainedObjectValue]];
    }
    
    return [NSArray arrayWithArray:delegatesBuilder];
}

- (void)addDelegate:(id)delegate
{
    [_delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
}

- (void)addDelegates:(NSArray *)delegates
{
    for (id delegate in delegates)
    {
        [self addDelegate:delegate];
    }
}

- (void)removeDelegate:(id)delegate
{
    [_delegates removeObject:[NSValue valueWithNonretainedObject:delegate]];
}

- (void)removeAllDelegates
{
    [_delegates removeAllObjects];
}

@end

