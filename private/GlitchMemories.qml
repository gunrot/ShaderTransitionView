
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height

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
// author: Gunnar Roth
// based on work from natewave
// license: MIT
vec4 transition(vec2 p) {
  vec2 block = floor(p.xy / vec2(16));
  vec2 uv_noise = block / vec2(64);
  uv_noise += floor(vec2(progress) * vec2(1200.0, 3500.0)) / vec2(64);
  vec2 dist = progress > 0.0 ? (fract(uv_noise) - 0.5) * 0.3 *(1.0 -progress) : vec2(0.0);
  vec2 red = p + dist * 0.2;
  vec2 green = p + dist * .3;
  vec2 blue = p + dist * .5;

  return vec4(mix(getFromColor(red), getToColor(red), progress).r,mix(getFromColor(green), getToColor(green), progress).g,mix(getFromColor(blue), getToColor(blue), progress).b,1.0);
}


    void main () {
        gl_FragColor = transition(vec2(qt_TexCoord0.x,1. - qt_TexCoord0.y));
    }
"
}
