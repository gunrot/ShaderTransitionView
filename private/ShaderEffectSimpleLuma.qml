import QtQuick 2.0


//Source code from: http://transitions.glsl.io/
ShaderEffect {

    anchors.fill: parent

    Image {
        anchors.fill: parent
        id: img
        fillMode: Image.Stretch
        source: "luma/square.png"
        visible:false
        layer.enabled: true
    }
    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property variant luma: img

    fragmentShader: "
#ifdef GL_ES
precision mediump float;
#endif
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;

uniform sampler2D luma;

void main() {
gl_FragColor = mix(
                    texture2D(srcSampler, qt_TexCoord0),
                    texture2D(dstSampler, qt_TexCoord0),
                    step(texture2D(luma, qt_TexCoord0).r, progress)
                   );
}
"
}
