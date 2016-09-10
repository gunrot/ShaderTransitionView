import QtQuick 2.0

/* Source code from: http://transitions.glsl.io/
 * http://transitions.glsl.io/transition/f24651a01bf574e90122 by gre
 */

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property vector4d shadow_colour: Qt.vector4d(0.0, 0.0,0.0, 0.8)
    property real bounce: 2.5
    property real shadow: 0.075

    fragmentShader: "
#ifdef GL_ES
precision highp float;
#endif
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
uniform float bounce;
uniform float shadow;
uniform vec4  shadow_colour;

varying highp vec2 qt_TexCoord0;



void main()
{

  float phase = progress * 3.14159265358 * bounce;

  float y = 1.0 - (abs(cos(phase))) * (1.0-sin(progress * (3.14159265358/2.0)));

  if(progress == 0.0)
    gl_FragColor = texture2D(srcSampler,qt_TexCoord0);
  else if(qt_TexCoord0.y > y)
  {
    float d = qt_TexCoord0.y - y;
    if(d>shadow)
      gl_FragColor = texture2D(srcSampler,qt_TexCoord0);
    else
    {
      float a = ((d/shadow)*shadow_colour.a) + (1.0-shadow_colour.a);
      gl_FragColor = mix(shadow_colour,texture2D(srcSampler,qt_TexCoord0),a);
    }
  }
  else
    gl_FragColor = texture2D(dstSampler,vec2(qt_TexCoord0.x,1.0 + qt_TexCoord0.y-y));

}
"

}

