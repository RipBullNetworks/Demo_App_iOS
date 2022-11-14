//
//  ObserverRemovable.h
//  eRTCApp
//
//  Created by rakesh palotra on 20/10/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ObserverRemovable <NSObject>
-(void) removeObservers;
@end

NS_ASSUME_NONNULL_END
