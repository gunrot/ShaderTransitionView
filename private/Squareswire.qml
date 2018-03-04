
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height
    property vector2d squares: Qt.vector2d(10,10)
    property vector2d direction: Qt.vector2d(1.0, -0.5)
    property real smoothness: 1.6


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
        return texture2D(srcSampler, vec2(uv.x,1.0 - uv.y));
    }
    vec4 getToColor (vec2 uv) {
        return texture2D(dstSampler, vec2(uv.x,1.0 - uv.y));
    }
// Author: gre
// License: MIT
 
uniform vec2 squares;// = ivec2(10,10)
uniform vec2 direction;// = vec2(1.0, -0.5)
uniform float smoothness; // = 1.6

const vec2 center = vec2(0.5, 0.5);
vec4 transition (vec2 p) {
  vec2 v = normalize(direction);
  v /= abs(v.x)+abs(v.y);
  float d = v.x * center.x + v.y * center.y;
  float offset = smoothness;
  float pr = smoothstep(-offset, 0.0, v.x * p.x + v.y * p.y - (d-0.5+progress*(1.+offset)));
  vec2 squarep = fract(p*vec2(squares));
  vec2 squaremin = vec2(pr/2.0);
  vec2 squaremax = vec2(1.0 - pr/2.0);
  float a = (1.0 - step(progress, 0.0)) * step(squaremin.x, squarep.x) * step(squaremin.y, squarep.y) * step(squarep.x, squaremax.x) * step(squarep.y, squaremax.y);
  return mix(getFromColor(p), getToColor(p), a);
}

    void main () {
        gl_FragColor = transition(vec2(qt_TexCoord0.x,1. - qt_TexCoord0.y));
    }
"
}
