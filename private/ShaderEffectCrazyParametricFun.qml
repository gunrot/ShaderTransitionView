import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real a:4
    property real b:1
    property real amplitude:120
    property real smoothness:0.1


    fragmentShader: "
#ifdef GL_ES
precision mediump float;
#endif
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;

// default a = 4
uniform float a;
// default b = 1
uniform float b;
// default amplitude = 120
uniform float amplitude;
// default smoothness = 0.1
uniform float smoothness;

void main() {
  vec2 dir = qt_TexCoord0 - vec2(.5);
  float dist = length(dir);
  float x = (a - b) * cos(progress) + b * cos(progress * ((a / b) - 1.) );
  float y = (a - b) * sin(progress) - b * sin(progress * ((a / b) - 1.));
  vec2 offset = dir * vec2(sin(progress  * dist * amplitude * x), sin(progress * dist * amplitude * y)) / smoothness;
  gl_FragColor = mix(texture2D(srcSampler, qt_TexCoord0 + offset), texture2D(dstSampler, qt_TexCoord0), smoothstep(0.2, 1.0, progress));
}
"

}


