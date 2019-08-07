//
//  LightTextureViewController.m
//  OpenGLZeroStudyDemo(7)-光照
//
//  Created by glodon on 2019/8/6.
//  Copyright © 2019 glodon. All rights reserved.
//

#import "LightTextureViewController.h"
#import "LightTextureBindObject.h"
#import "CubeManager.h"

@interface LightTextureViewController ()

@property (nonatomic ,strong) Vertex * vertexPostion ;
@property (nonatomic ,strong) Vertex * vertexTexture ;
@property (nonatomic ,strong) Vertex * vertexNormal ;
@property (nonatomic ,strong) TextureUnit * texture ;
@end

@implementation LightTextureViewController

-(void)initSubObject{
    //生命周期三秒钟
    __weakSelf
    self.bindObject = [LightTextureBindObject new];
    self.bindObject.uniformSetterBlock = ^(GLuint program) {
        weakSelf.bindObject->uniforms[MVPMatrix] = glGetUniformLocation(self.shader.program, "u_mvpMatrix");
        weakSelf.bindObject->uniforms[Samplers2D] = glGetUniformLocation(self.shader.program, "u_samplers2D");

        weakSelf.bindObject->uniforms[LightTextureUniformLocationModel] = glGetUniformLocation(self.shader.program, "u_model");
        weakSelf.bindObject->uniforms[LightTextureUniformLocationInvermodel] = glGetUniformLocation(self.shader.program, "u_inverModel");
        weakSelf.bindObject->uniforms[LightTextureUniformLocationviewPos] = glGetUniformLocation(self.shader.program, "viewPos");
  
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

-(void)createTextureUnit{
    UIImage *  image = [UIImage imageNamed:@"container2.png"];
    self.texture = [TextureUnit new];
    [self.texture setImage:image IntoTextureUnit:GL_TEXTURE0 andConfigTextureUnit:nil];
    [self.texture bindtextureUnitLocationAndShaderUniformSamplerLocation:self.bindObject->uniforms[Samplers2D]];
}
-(void)loadVertex{
    //顶点数据缓存
    self.vertexPostion= [Vertex new];
    int vertexNum =[CubeManager getTextureNormalVertexNum];
    [self.vertexPostion allocVertexNum:vertexNum andEachVertexNum:3];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j];
        }
        [self.vertexPostion setVertex:onevertex index:i];
    }
    [self.vertexPostion bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexPostion enableVertexInVertexAttrib:BeginPosition numberOfCoordinates:3 attribOffset:0];
    
        self.vertexTexture = [Vertex new];
        [self.vertexTexture allocVertexNum:vertexNum andEachVertexNum:2];
        for (int i=0; i<vertexNum; i++) {
            float onevertex[2];
            for (int j=0; j<2; j++) {
                onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j+6];
            }
            [self.vertexTexture setVertex:onevertex index:i];
        }
        [self.vertexTexture bindBufferWithUsage:GL_STATIC_DRAW];
        [self.vertexTexture enableVertexInVertexAttrib:LightTextureBindAttribLocationTexture numberOfCoordinates:2 attribOffset:0];
    
    self.vertexNormal= [Vertex new];
    [self.vertexNormal allocVertexNum:vertexNum andEachVertexNum:3];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j+3];
        }
        [self.vertexNormal setVertex:onevertex index:i];
    }
    [self.vertexNormal bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexNormal enableVertexInVertexAttrib:LightTextureBindAttribLocationNormal numberOfCoordinates:3 attribOffset:0];
    
    GLKVector3 ambientLigh = GLKVector3Make(1.0, 1.0, 1.0);
    
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
    static GLfloat angle=0;
    angle ++ ;
    //        angle = 45;
    GLKMatrix4 mode =GLKMatrix4MakeRotation(angle*M_PI/180, 0, 1, 0);
    
    glUniformMatrix4fv(self.bindObject->uniforms[MVPMatrix], 1, 0,mvp.m);
    glUniformMatrix4fv(self.bindObject->uniforms[LightTextureUniformLocationModel], 1, 0,mode.m);
    bool isSuccess = YES;
    mode = GLKMatrix4InvertAndTranspose(mode,&isSuccess);
    glUniformMatrix4fv(self.bindObject->uniforms[LightTextureUniformLocationInvermodel], 1, 0,mode.m);
    
    GLKVector3 viewPos = GLKVector3Make(.0, 0.0,2.0);
    glUniform3fv(self.bindObject->uniforms[LightTextureUniformLocationviewPos], 1,viewPos.v);
    
    [self.vertexPostion drawVertexWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:[CubeManager getNormalVertexNum]];
}



@end

