import QtQuick 2.0


//GLSL Source code from: https://github.com/gl-transitions/gl-transitions
ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width / height

    vertexShader: "
uniform highp mat4 qt_Matrix;

attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;

varying highp vec2 qt_TexCoord0;

void main()
{
qt_TexCoord0 = vec2(qt_MultiTexCoord0.x, 1.0 - qt_MultiTexCoord0.y);
gl_Position = qt_Matrix *qt_Vertex;
}

"
    fragmentShader: "
#ifdef GL_ES
precision highp float;
#endif
varying vec2 qt_TexCoord0;
uniform float progress;
uniform float ratio;
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
vec4 getFromColor (vec2 uv) {
return texture2D(srcSampler, uv);
}
vec4 getToColor (vec2 uv) {
return texture2D(dstSampler, uv);
}
// Author: @Flexi23
// License: MIT

// inspired by http://www.wolframalpha.com/input/?i=cannabis+curve

vec4 transition (vec2 uv) {
if(progress == 0.0){
return getFromColor(uv);
}
vec2 leaf_uv = (uv - vec2(0.5))/10./pow(progress,3.5);
leaf_uv.y += 0.35;
float r = 0.18;
float o = atan(leaf_uv.y, leaf_uv.x);
return mix(getFromColor(uv), getToColor(uv), 1.-step(1. - length(leaf_uv)+r*(1.+sin(o))*(1.+0.9 * cos(8.*o))*(1.+0.1*cos(24.*o))*(0.9+0.05*cos(200.*o)), 1.));
}

void main () {
float r = ratio;
gl_FragColor = transition(vec2(qt_TexCoord0.x,qt_TexCoord0.y));
}
"
}
