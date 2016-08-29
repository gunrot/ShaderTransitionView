import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real size: 0.04
    property real zoom: 30.0
    property real colorSeparation: 0.3

    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;
// Custom parameters
uniform float size;
uniform float zoom;
uniform float colorSeparation;

void main() {

  float inv = 1. - progress;
  vec2 disp = size*vec2(cos(zoom*p.x), sin(zoom*p.y));
  vec4 texTo = texture2D(dstSampler, qt_TexCoord0 + inv*disp);
  vec4 texFrom = vec4(
    texture2D(srcSampler, qt_TexCoord0 + progress*disp*(1.0 - colorSeparation)).r,
    texture2D(srcSampler, qt_TexCoord0 + progress*disp).g,
    texture2D(srcSampler, qt_TexCoord0 + progress*disp*(1.0 + colorSeparation)).b,
    1.0);
  gl_FragColor = texTo*progress + texFrom*inv;
}
"

}

