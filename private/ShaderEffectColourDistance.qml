import QtQuick 2.0

/* Source code from: http://transitions.glsl.io/
 * http://transitions.glsl.io/transition/35e8c18557995c77278e by gre
 */

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination
    property real progress: 0.0
    property real interpolationPower: 5.0

    fragmentShader: "
#ifdef GL_ES
precision mediump float;
#endif
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
// default interpolationPower = 5;
uniform float interpolationPower;

varying highp vec2 qt_TexCoord0;

void main() {
  vec4 fTex = texture2D(srcSampler,qt_TexCoord0);
  vec4 tTex = texture2D(dstSampler,qt_TexCoord0);
  gl_FragColor = mix(distance(fTex,tTex)>progress?fTex:tTex,
                     tTex,
                     pow(progress,interpolationPower));
}
"

}

