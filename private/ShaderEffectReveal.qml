import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real smoothness: 0.01


    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;

void main() {
  vec4 a = texture2D(srcSampler, qt_TexCoord0); //vec4(0.0, 0.0, 0.0, 0.0);
  vec4 b = texture2D(dstSampler, qt_TexCoord0);
  gl_FragColor = mix(a, b, step(1.0 - qt_TexCoord0.x, progress));
}
"

}

