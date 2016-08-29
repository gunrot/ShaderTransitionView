import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property vector2d size : Qt.vector2d(10, 10)
    property real smoothness: 0.5


    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;


// Custom parameters
uniform vec2 size;
uniform float smoothness;

float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  float r = rand(floor(size * qt_TexCoord0));
  float m = smoothstep(0.0, -smoothness, r - (progress * (1.0 + smoothness)));
  gl_FragColor = mix(texture2D(srcSampler, qt_TexCoord0), texture2D(dstSampler, qt_TexCoord0), m);
}
"

}

