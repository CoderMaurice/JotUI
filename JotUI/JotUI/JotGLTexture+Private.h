//
//  JotGLTexture+Private.h
//  JotUI
//
//  Created by Adam Wulf on 1/3/16.
//  Copyright © 2016 Adonit. All rights reserved.
//

#ifndef JotGLTexture_Private_h
#define JotGLTexture_Private_h


#import "ShaderHelper.h"

extern tex_programInfo_t quad_program[NUM_TEX_PROGRAMS];

@interface JotGLTexture ()

-(void) bindForRenderToQuadWithCanvasSize:(CGSize)canvasSize forProgram:(tex_programInfo_t*)program;

@end


#endif /* JotGLTexture_Private_h */
