/*
 * Copyright (c) 2011-2015, 2time.net | Sven Otto
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package tests.textureTest;

import tests.utils.Shader;
import duellkit.DuellKit;
import types.Data;
import types.DataType;
import gl.GL;
import gl.GLDefines;

class TextureTest extends OpenGLTest
{
    inline static private var sizeOfFloat: Int = 4;
    inline static private var sizeOfShort: Int = 2;

    inline static private var positionAttributeCount: Int = 4;
    inline static private var colorAttributeCount: Int = 4;
    inline static private var texCoordAttributeCount: Int = 2;

    inline static private var positionAttributeIndex: Int = 0;
    inline static private var colorAttributeIndex: Int = 1;
    inline static private var texCoordAttributeIndex: Int = 2;

    inline static private var indexCount: Int = 6;

    inline static private var vertexShader =
    "
            attribute highp   vec4  a_Position;
            attribute lowp    vec4  a_Color;
            attribute highp   vec2  a_TexCoord;

            uniform highp     float u_Tint;
            uniform highp     float u_TexScalar;

            varying lowp      vec4  v_Color;
            varying highp     vec2  v_TexCoord;

            void main()
            {
                gl_Position = a_Position;
                v_Color = a_Color * u_Tint;
                v_TexCoord = a_TexCoord * u_TexScalar;
            }
        ";

    inline static private var fragmentShader =
    "
            uniform sampler2D       s_TextureA;
            uniform sampler2D       s_TextureB;

            varying lowp      vec4  v_Color;
            varying highp     vec2  v_TexCoord;

            void main()
            {
                if (v_TexCoord.x > 0.5) {
                    gl_FragColor = texture2D(s_TextureB, v_TexCoord) * v_Color;
                } else {
                    gl_FragColor = texture2D(s_TextureA, v_TexCoord) * v_Color;
                }
            }
        ";

    private var textureShader: Shader;

    private var vertexBuffer: GLBuffer;
    private var indexBuffer: GLBuffer;

    private var texture1: GLTexture;
    private var texture2: GLTexture;

    var textureWidth: UInt = 16;
    var textureHeight: UInt = 16;

    // Create OpenGL objectes (Shaders, Buffers, Textures) here
    override private function onCreate(): Void
    {
        super.onCreate();

        configureOpenGLState();
        createShader();
        createBuffers();
        createTextures();
    }

    // Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        destroyTexture();
        destroyBuffers();
        destroyShader();

        super.onDestroy();
    }

    private function configureOpenGLState(): Void
    {
        GL.clearColor(0.0, 0.4, 0.6, 1.0);
    }

    private function createShader()
    {
        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color", "a_TexCoord"], ["u_Tint", "u_TexScalar", "s_TextureA", "s_TextureB"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createBuffers()
    {
        /// VertexBuffer also called Array Buffer

        var vertexCount: Int = 4;
        var vertexBufferSize: Int = vertexCount * (sizeOfFloat * positionAttributeCount + sizeOfFloat * colorAttributeCount + sizeOfFloat * texCoordAttributeCount);
        var vertexBufferData: Data = new Data(vertexBufferSize);
                                            //  x    y    z    w    r    g    b    a    u    v
        var vertexBufferValues: Array<Float> = [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,     // vertex 0
                                                0.5, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,     // vertex 1
                                                0.5, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,     // vertex 3
                                                0.0, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0];    // vertex 2

        vertexBufferData.writeFloatArray(vertexBufferValues, DataType.DataTypeFloat32);
        vertexBufferData.offset = 0;

        vertexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bufferData(GLDefines.ARRAY_BUFFER, vertexBufferData, GLDefines.STATIC_DRAW);
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);


        /// IndexBuffer also called Element (Array) Buffer

        var indexBufferSize: Int = indexCount * sizeOfShort;
        var indexBufferData: Data = new Data(indexBufferSize);

        var indexBufferValues: Array<Int> = [0, 3, 1, 1, 2, 0];  // These indices reference the vertices above.

        indexBufferData.writeIntArray(indexBufferValues, DataType.DataTypeUInt16);
        indexBufferData.offset = 0;

        indexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.bufferData(GLDefines.ELEMENT_ARRAY_BUFFER, indexBufferData, GLDefines.STATIC_DRAW);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
    }

    private function destroyBuffers(): Void
    {
        GL.deleteBuffer(indexBuffer);
        GL.deleteBuffer(vertexBuffer);
    }

    private function createTextures(): Void
    {
        var textureData1: Data = createtextureData(255, 0, 0);
        texture1 = createTexture(textureData1, GLDefines.TEXTURE0);

        var textureData2: Data = createtextureData(0, 255, 0);
        texture2 = createTexture(textureData2, GLDefines.TEXTURE1);
    }

    private function createTexture(textureData: Data, activeTexture: Int): GLTexture
    {
        /// Create, configure and upload opengl texture
        var texture: GLTexture = GL.createTexture();

        GL.activeTexture(activeTexture);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

        // Configure Filtering Mode
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MAG_FILTER, GLDefines.NEAREST);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MIN_FILTER, GLDefines.NEAREST);

        // Configure wrapping
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_S, GLDefines.CLAMP_TO_EDGE);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_T, GLDefines.CLAMP_TO_EDGE);

        // Copy data to gpu memory
        GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
        GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGBA, textureWidth, textureHeight, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, textureData);

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);

        return texture;
    }

    private function createtextureData(r: Int, g: Int, b: Int): Data
    {
        /// Create RGBA raw pixel data

        var red: UInt = 0;
        var green: UInt = 0;
        var blue: UInt =  0;
        var alpha: UInt = 255;

        var textureDataSize: UInt = textureWidth * textureHeight * 4;
        var textureData: Data = new Data(textureDataSize);

        textureData.offset = 0;

        for (y in 0...textureHeight)
        {
            for (x in 0...textureWidth)
            {
                if (x % 2 == y % 2) // Checkerboard
                {
                    red = y * x;
                    green = y * x;
                    blue = y * x;
                }
                else
                {
                    red = r;
                    green = g;
                    blue = b;
                }

                textureData.writeInt(red, DataType.DataTypeUInt8);
                textureData.offset++;
                textureData.writeInt(green, DataType.DataTypeUInt8);
                textureData.offset++;
                textureData.writeInt(blue, DataType.DataTypeUInt8);
                textureData.offset++;
                textureData.writeInt(alpha, DataType.DataTypeUInt8);
                textureData.offset++;
            }
        }

        textureData.offset = 0;

        return textureData;
    }

    private function destroyTexture(): Void
    {
        GL.deleteTexture(texture1);
        GL.deleteTexture(texture2);
    }

    override private function render()
    {
        var currentTime = DuellKit.instance().time;
        var tween = (Math.sin(currentTime) + 1.0) / 2.0;

        GL.clear(GLDefines.COLOR_BUFFER_BIT);

        GL.useProgram(textureShader.shaderProgram);

        GL.activeTexture(GLDefines.TEXTURE0);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture1);

        GL.activeTexture(GLDefines.TEXTURE1);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture2);

        //var tint: Float = 0.5 + 0.5 * tween;
        var tint: Float = 1.0;

        GL.uniform1f(textureShader.uniformLocations[0], tint);

        var cord: Float = tween;
        GL.uniform1f(textureShader.uniformLocations[1], cord);

        GL.uniform1i(textureShader.uniformLocations[2], 0);

        GL.uniform1i(textureShader.uniformLocations[3], 1);

        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, indexBuffer);

        GL.enableVertexAttribArray(positionAttributeIndex); // 0
        GL.enableVertexAttribArray(colorAttributeIndex);    // 1
        GL.enableVertexAttribArray(texCoordAttributeIndex); // 2

        GL.disableVertexAttribArray(3);
        GL.disableVertexAttribArray(4);
        GL.disableVertexAttribArray(5);
        GL.disableVertexAttribArray(6);
        GL.disableVertexAttribArray(7);

        var stride: Int = positionAttributeCount * sizeOfFloat + colorAttributeCount * sizeOfFloat + texCoordAttributeCount * sizeOfFloat;

        var attributeOffset: Int = 0;
        GL.vertexAttribPointer(positionAttributeIndex, positionAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        attributeOffset = positionAttributeCount * sizeOfFloat;
        GL.vertexAttribPointer(colorAttributeIndex, colorAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        attributeOffset = positionAttributeCount * sizeOfFloat + colorAttributeCount * sizeOfFloat;
        GL.vertexAttribPointer(texCoordAttributeIndex, texCoordAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        var indexOffset: Int = 0;
        GL.drawElements(GLDefines.TRIANGLES, indexCount, GLDefines.UNSIGNED_SHORT, indexOffset);

        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
        GL.useProgram(GL.nullProgram);
    }
}