
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height
    property real amplitude: 30

    property real speed: 30


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
// author: Paweł Płóciennik
// license: MIT
uniform float amplitude; // = 30
uniform float speed; // = 30

vec4 transition(vec2 p) {
  vec2 dir = p - vec2(.5);
  float dist = length(dir);

  if (dist > progress) {
    return mix(getFromColor( p), getToColor( p), progress);
  } else {
    vec2 offset = dir * sin(dist * amplitude - progress * speed);
    return mix(getFromColor( p + offset), getToColor( p), progress);
  }
}

    void main () {
        gl_FragColor = transition(vec2(qt_TexCoord0.x,1. - qt_TexCoord0.y));
    }
"
}
