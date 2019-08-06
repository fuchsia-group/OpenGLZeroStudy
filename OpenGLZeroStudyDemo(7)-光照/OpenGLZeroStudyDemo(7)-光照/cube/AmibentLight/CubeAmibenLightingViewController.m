//
//  CubeAmibenLightingViewController.m
//  OpenGLZeroStudyDemo(7)-光照
//
//  Created by glodon on 2019/8/2.
//  Copyright © 2019 glodon. All rights reserved.
//

#import "CubeAmibenLightingViewController.h"
#import "CubeAmibentLightBindObject.h"
#import "CubeManager.h"

@interface CubeAmibenLightingViewController ()
@property (nonatomic ,strong) Vertex * vertexPostion ;
@property (nonatomic ,strong) Vertex * vertexColor ;
@end

@implementation CubeAmibenLightingViewController
-(void)initSubObject{
    //生命周期三秒钟
    __weakSelf
    self.bindObject = [CubeAmibentLightBindObject new];
    self.bindObject.uniformSetterBlock = ^(GLuint program) {
        weakSelf.bindObject->uniforms[MVPMatrix] = glGetUniformLocation(self.shader.program, "u_mvpMatrix");
        weakSelf.bindObject->uniforms[CubeDefaultUniformLocationAmbientLight] = glGetUniformLocation(self.shader.program, "ambientLight");
    };
}

-(void)createShader{
    __weakSelf
    self.shader = [Shader new];
    [self.shader compileLinkSuccessShaderName:self.bindObject.getShaderName completeBlock:^(GLuint program) {
        [self.bindObject BindAttribLocation:program];
    }];
    if (self.bindObject.uniformSetterBlock) {
        self.bindObject.uniformSetterBlock(self.shader.program);
    }
}

-(void)loadVertex{
    //顶点数据缓存
    self.vertexPostion= [Vertex new];
    int vertexNum =[CubeManager getVertexNum];
    [self.vertexPostion allocVertexNum:vertexNum andEachVertexNum:3];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager getCubeVerts][i*3+j];
        }
        [self.vertexPostion setVertex:onevertex index:i];
    }
    [self.vertexPostion bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexPostion enableVertexInVertexAttrib:BeginPosition numberOfCoordinates:3 attribOffset:0];
    
    self.vertexColor = [Vertex new];
    [self.vertexColor allocVertexNum:vertexNum andEachVertexNum:3];
    
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager cubeColors][i*3+j];
        }
        [self.vertexColor setVertex:onevertex index:i];
    }
    [self.vertexColor bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexColor enableVertexInVertexAttrib:CubeAmibentLightBindAttribLocationVertexColor numberOfCoordinates:3 attribOffset:0];
    
}
///消除0x502 操作
-(void)createTextureUnit{
    
}
-(GLKMatrix4)getMVP{
    GLfloat aspectRatio= CGRectGetWidth([UIScreen mainScreen].bounds) / CGRectGetHeight([UIScreen mainScreen].bounds);
    GLKMatrix4 projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    GLKMatrix4 modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 2.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    return GLKMatrix4Multiply(projectionMatrix,modelviewMatrix);
}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    GLKMatrix4  mvp= [self getMVP];
    static GLfloat angle=30;
    
    GLKMatrix4 mode =GLKMatrix4MakeRotation(angle*M_PI/180, 0, 1, 0);
    GLKMatrix4 result=  GLKMatrix4Multiply(mvp,mode);
    glUniformMatrix4fv(self.bindObject->uniforms[MVPMatrix], 1, 0,result.m);
    
    GLKVector4 amibentLighting = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    glUniform4fv(self.bindObject->uniforms[CubeDefaultUniformLocationAmbientLight], 1, amibentLighting.v);

    [VertexElement drawElementIndexWithMode:GL_TRIANGLES indexNum:[CubeManager getVertexElementsNum] indexArr:[CubeManager getVertexElements]];
}



@end
