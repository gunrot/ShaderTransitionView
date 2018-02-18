
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height
    property variant luma: img
    Image {
        anchors.fill: parent
        id: img
        fillMode: Image.Stretch
        source: "luma/square.png"
        visible:false
        layer.enabled: true
    }
        
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
// Author: gre
// License: MIT

uniform sampler2D luma;

vec4 transition(vec2 uv) {
  return mix(
    getToColor(uv),
    getFromColor(uv),
    step(progress, texture2D(luma, uv).r)
  );
}

    void main () {
        float r = ratio;
        gl_FragColor = transition(vec2(qt_TexCoord0.x,qt_TexCoord0.y));
    }
"
}
