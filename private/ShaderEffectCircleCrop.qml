import QtQuick 2.0

/* Source code from: http://transitions.glsl.io/
 * http://transitions.glsl.io/transition/35e8c18557995c77278e by gre
 */

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination


    property real progress: 0.0
    fragmentShader: "
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;


varying highp vec2 qt_TexCoord0;


const float maxRadius = 2.0;

void main() {

  float distX = qt_TexCoord0.x - 0.5;
  float distY = qt_TexCoord0.y - 0.5;
  float dist = sqrt(distX * distX + distY * distY);

  float step = 2.0 * abs(progress - 0.5);
  step = step * step * step;

  if (dist < step * maxRadius)
  {
    if (progress < 0.5)
      gl_FragColor = texture2D(srcSampler, qt_TexCoord0);
    else
      gl_FragColor = texture2D(dstSampler, qt_TexCoord0);
  }
  else
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
"

}

