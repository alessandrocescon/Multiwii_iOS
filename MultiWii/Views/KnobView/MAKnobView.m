//
//  MAKnob.m
//  testanimation
//
//  Created by Eugene Skrebnev on 7/4/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import "MAKnobView.h"
#define HANDLE_OVERLAP 22
@implementation MAKnobView
{
    float _internalValue;
    float _internalMax;
    float _internalMin;
    BOOL wasInited;
    float _savedAngle;
}



-(void)setSpinCount:(float)spinCount
{
    _spinCount = spinCount;
    _internalMin = 0;
    _internalMax = spinCount * 360;
}

-(void) makeInit
{
    if (!wasInited)
    {
        _savedAngle = -1000;
        wasInited = YES;
        UIImage* knob = [UIImage imageNamed:@"knob.png"];
        UIImage* knobActive = [UIImage imageNamed:@"knob_active.png"];
        UIImage* knobHandle = [UIImage imageNamed:@"knob_handle.png"];
        
        self.width  = 90;
        self.height = 80;
        

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _knobView = [[UIImageView alloc] initWithImage:knob];
        _knobViewSelected = [[UIImageView alloc] initWithImage:knobActive];
        _knobHandleView = [[UIImageView alloc] initWithImage:knobHandle];
        
        
        _knobView.center = CGPointMake(_backgroundView.width / 2, _backgroundView.height / 2);
        _knobViewSelected.center = CGPointMake(_backgroundView.width / 2, _backgroundView.height / 2);
        _knobViewSelected.alpha = 0;
        
        _knobHandleView.center = CGPointMake(_backgroundView.width / 2, _backgroundView.height / 2 - _knobView.height / 2 - _knobHandleView.height / 2 + HANDLE_OVERLAP);
        
        
        
        
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.delegate = self;
        UILongPressGestureRecognizer *tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.minimumPressDuration = 0;
        
        [self addSubview:_backgroundView];
        [_backgroundView addSubview:_knobView];
        [_backgroundView addSubview:_knobViewSelected];
        [_backgroundView addSubview:_knobHandleView];
        
        
        [_backgroundView addGestureRecognizer:panGesture];
        [_backgroundView addGestureRecognizer:tapGesture];
        
        self.animateOnActivate = YES;
        
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKnob) name:@"MAKnobViewUpdateNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKnobAnimated) name:@"MAKnobViewUpdateAnimatedNotification" object:nil];
//        self.active = YES;
//        self.controlType = MAKnobControlTypeAngleDetect;
    }
}

-(void) updateKnobAnimated
{
    if (self.settingEntity)
        if (! (fabsf(self.value - self.settingEntity.value) < self.step / 5))
        {
            [self setValue:self.settingEntity.value animated:YES];
        }
}

-(void) updateKnob
{
    if (self.settingEntity)
        if (! (fabsf(self.value - self.settingEntity.value) < self.step / 5))
        {
            [self setValue:self.settingEntity.value animated:NO];
        }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) setActive:(BOOL)active
{
    _active = active;
    NSTimeInterval animateDuration = 0;
    
    if (self.animateOnActivate)
        animateDuration = 0.3;
    
    [UIView animateWithDuration:animateDuration animations:^{
        if (active)
        {
            _knobViewSelected.alpha = 0.7;
        }
        else
        {
            _knobViewSelected.alpha = 0;
        }
    }];
}

-(float)internalValue
{
    return _internalValue;
}

- (void)handleTap:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.active = YES;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.active = NO;
    }
}

-(float) mapValue:(float) value inputMin:(float) inMin inputMax:(float) inMax outputMin:(float) outMin outputMax:(float) outMax
{
    return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

-(void) setTransformForInternalValue
{
    _backgroundView.transform = CGAffineTransformMakeRotation(_internalValue / 180. * M_PI);
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    UIView* viewForTranslation;
//    if (self.controlType == MAKnobControlTypePanSpin)
//        viewForTranslation = recognizer.view;
//    else
        viewForTranslation = self.superview;
    
    CGPoint offset = [recognizer translationInView:viewForTranslation];
    float minR = 1;
    float currentAngle = atan2f(offset.y, offset.x) / M_PI * 180;
    float deltaAngle = 0;
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if ((_savedAngle < -900) && ( (minR * minR) < (offset.x * offset.x) + (offset.y * offset.y) ))
            _savedAngle = currentAngle;
        deltaAngle = currentAngle - _savedAngle;
        if (deltaAngle < -300)
            deltaAngle += 360;
        if (deltaAngle > 300)
            deltaAngle -= 360;
//        deltaAngle *= 1.2; //self.spinCount;
        if (_savedAngle > -900)
        {
//            NSLog(@"%f", deltaAngle);
            [self setInternalValue:_internalValue + deltaAngle];
            [self setTransformForInternalValue];
        }
        
    }
            
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        _savedAngle = -1000;
        [self finishValueChanging];        
        
    }
    
    if (_savedAngle > -900)
        _savedAngle = currentAngle;
}
//- (void)handlePan:(UIPanGestureRecognizer*)recognizer
//{
//    UIView* viewForTranslation;
//    if (self.controlType == MAKnobControlTypePanSpin)
//        viewForTranslation = recognizer.view;
//    else
//        viewForTranslation = self.superview;
//    
//    CGPoint offset = [recognizer translationInView:viewForTranslation];
//
//    float currentAngle = atan2f(offset.y, offset.x) / M_PI * 180;
//    NSLog(@"%f", currentAngle);
//    return;
//    if (recognizer.state == UIGestureRecognizerStateChanged)
//    {
//        CGPoint currentTranslationNew = _currentTranslation;
//        if (self.controlType == MAKnobControlTypePanX || self.controlType == MAKnobControlTypePanXY || self.controlType == MAKnobControlTypePanSpin)
//            currentTranslationNew.x += offset.x;
//        
//        if (self.controlType == MAKnobControlTypePanY || self.controlType == MAKnobControlTypePanXY || self.controlType == MAKnobControlTypePanSpin)
//            currentTranslationNew.y += offset.y;
//        
//        
//        float internalValueNew = currentTranslationNew.x + currentTranslationNew.y + _savedTranslation.x + _savedTranslation.y;
//        if ((internalValueNew <= _internalMax) && (internalValueNew >= _internalMin))
//        {
//            [self setInternalValue:internalValueNew];
//            _currentTranslation = currentTranslationNew;
//        }
//
//
//        [self setTransformForInternalValue];
//    }
//    if (recognizer.state == UIGestureRecognizerStateEnded)
//    {
//        if (self.controlType != MAKnobControlTypeAngleDetect)
//        {
//            _savedTranslation.x += _currentTranslation.x;
//            _savedTranslation.y += _currentTranslation.y;
//            _currentTranslation = CGPointMake(0, 0);
//            [self setInternalValue:_currentTranslation.x + _currentTranslation.y + _savedTranslation.x + _savedTranslation.y ];
//        }
//
//        [self finishValueChanging];
//    }
//    
//    if (self.controlType != MAKnobControlTypeAngleDetect)
//    {
//        [recognizer setTranslation:CGPointMake(0, 0) inView:viewForTranslation];
//    }
//}

-(void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

-(void)setValue:(float)value animated:(BOOL)animated
{
    [self willChangeValueForKey:@"value"];
    _value = value;
    _internalValue = [self mapValue:_value
                           inputMin:self.minValue
                           inputMax:self.maxValue
                          outputMin:_internalMin
                          outputMax:_internalMax];

    if (!self.active)//сплошные костыли(
    {
//        _savedTranslation.x = _internalValue;
//        _savedTranslation.y = 0;
        [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
            [self setTransformForInternalValue];
        }];
    }
    
    [self didChangeValueForKey:@"value"];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) mapValueFromInternal
{
    self.value = [self mapValue:_internalValue
                       inputMin:_internalMin
                       inputMax:_internalMax
                      outputMin:self.minValue
                      outputMax:self.maxValue];
}

-(void) setInternalValue:(float) internalVal
{
    if (internalVal < _internalMin)
        internalVal = _internalMin;
    
    if (internalVal > _internalMax)
        internalVal = _internalMax;
    
    _internalValue = internalVal;
    
    [self mapValueFromInternal];
    if (self.discreteChanging)
    {
        float newValueStepping = roundf(self.value / self.step) * self.step;
        
        _internalValue = [self mapValue:newValueStepping
                               inputMin:self.minValue
                               inputMax:self.maxValue
                              outputMin:_internalMin
                              outputMax:_internalMax];
    }
    [self mapValueFromInternal];
    
}

-(void) finishValueChanging
{
    float newValueStepping = roundf(self.value / self.step) * self.step;
    
    _internalValue = [self mapValue:newValueStepping
                           inputMin:self.minValue
                           inputMax:self.maxValue
                          outputMin:_internalMin
                          outputMax:_internalMax];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setTransformForInternalValue];
    }];
    [self mapValueFromInternal];
    
    if (self.settingEntity)
    {
        if (!(fabsf(self.value - self.settingEntity.value) < self.step / 5))
            self.settingEntity.value = self.value;
    }

}

-(void)setSettingEntity:(MWSettingsEntity *)settingEntity
{
    _settingEntity = settingEntity;
    self.minValue = settingEntity.minValue;
    self.maxValue = settingEntity.maxValue;
    self.step = settingEntity.step;
    self.spinCount = ((self.maxValue - self.minValue) / self.step) / 90;
    self.value = settingEntity.value;
    [settingEntity addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew) context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.settingEntity)
        if (! (fabsf(self.value - self.settingEntity.value) < self.step / 5))
        {
            [self updateKnobAnimated];
        }
//            self.value = self.settingEntity.value;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self makeInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self makeInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self makeInit];
    }
    return self;
}

-(void)dealloc
{
    [self.settingEntity removeObserver:self forKeyPath:@"value"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
