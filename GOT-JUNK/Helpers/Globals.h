//
//  Globals.h
//  GOT-JUNK
//
//  Created by David Block on 2014-11-05.
//  Copyright (c) 2014 David Block. All rights reserved.
//

#ifndef GOT_JUNK_Globals_h
#define GOT_JUNK_Globals_h

//#define LOGGING 

#ifdef LOGGING
    #define NSLog( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
    #define NSLog( s, ... )
#endif

#endif
