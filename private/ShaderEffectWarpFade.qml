import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0


    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;
void main() {
  float x = progress;
  x=smoothstep(.0,1.0,(x*2.0+qt_TexCoord0.x-1.0));
  gl_FragColor = mix(texture2D(srcSampler, (qt_TexCoord0-.5)*(1.-x)+.5), texture2D(dstSampler, (qt_TexCoord0-.5)*x+.5), progress);
}
"

}

