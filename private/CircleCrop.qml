
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height
    property vector4d bgcolor: Qt.vector4d(0.0, 0.0, 0.0, 1.0)

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
// License: MIT
// Author: fkuteken
// ported by gre from https://gist.github.com/fkuteken/f63e3009c1143950dee9063c3b83fb88

uniform vec4 bgcolor; // = vec4(0.0, 0.0, 0.0, 1.0)

vec2 ratio2 = vec2(1.0, 1.0 / ratio);
float s = pow(2.0 * abs(progress - 0.5), 3.0);

vec4 transition(vec2 p) {
  float dist = length((vec2(p) - 0.5) * ratio2);
  return mix(
    progress < 0.5 ? getFromColor(p) : getToColor(p), // branching is ok here as we statically depend on progress uniform (branching won't change over pixels)
    bgcolor,
    step(s, dist)
  );
}

    void main () {
        gl_FragColor = transition(vec2(qt_TexCoord0.x,1. - qt_TexCoord0.y));
    }
"
}
