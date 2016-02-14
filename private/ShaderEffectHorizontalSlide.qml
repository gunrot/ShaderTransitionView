import QtQuick 2.0

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property bool forward: true

    fragmentShader: "
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;

uniform bool forward;

varying highp vec2 qt_TexCoord0;

void main() {

    float pr = forward ? 1.0 - progress : progress;

    if( qt_TexCoord0.x <= pr ) {
        gl_FragColor = forward ?
            texture2D(srcSampler, qt_TexCoord0 + vec2(progress,0.0)) :
            texture2D(dstSampler, qt_TexCoord0 + vec2((1.0-progress),0.0));
    } else {
        gl_FragColor = forward ?
            texture2D(dstSampler, qt_TexCoord0 - vec2((1.0 - progress),0.0)) :
            texture2D(srcSampler, qt_TexCoord0 - vec2(progress,0.0));
    }
}
"

}

