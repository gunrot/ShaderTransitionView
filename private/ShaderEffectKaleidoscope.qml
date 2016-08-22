import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real speed: 1
    property real angle: 2
    property real power: 2

    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;

uniform float speed;
uniform float angle;
uniform float power;

void main() {
  vec2 p = qt_TexCoord0;
  vec2 q = p;
  float t = pow(progress, power)*speed;
  p = p -0.5;
  for (int i = 0; i < 7; i++) {
    p = vec2(sin(t)*p.x + cos(t)*p.y, sin(t)*p.y - cos(t)*p.x);
    t += angle;
    p = abs(mod(p, 2.0) - 1.0);
  }
  abs(mod(p, 1.0));
  gl_FragColor = mix(
    mix(texture2D(srcSampler, q), texture2D(dstSampler, q), progress),
    mix(texture2D(srcSampler, p), texture2D(dstSampler, p), progress), 1.0 - 2.0*abs(progress - 0.5));
}

"

}

