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
uniform vec2 resolution;
varying highp vec2 qt_TexCoord0;

vec2 zoom(vec2 uv, float amount)
{
  return 0.5 + ((uv - 0.5) * amount);
}

void main() {

  vec2 uv = qt_TexCoord0;;
  vec2 r =  2.0*vec2(qt_TexCoord0 - 0.5);
  float pro = progress / 0.8;
  float z = (pro) * 0.2;
  float t = 0.0;
  if (pro > 1.0)
  {
    z = 0.2 + (pro - 1.0) * 5.;
    t = clamp((progress - 0.8) / 0.07,0.0,1.0);
  }
  if (length(r) < 0.5+z)
  {
      //uv = zoom(uv, 0.9 - 0.1 * pro);
  }
  else if (length(r) < 0.8+z*1.5)
  {
      uv = zoom(uv, 1.0 - 0.15 * pro);
      t = t * 0.5;
  }
  else if (length(r) < 1.2+z*2.5)
  {
      uv = zoom(uv, 1.0 - 0.2 * pro);
      t = t * 0.2;
  }
  else
      uv = zoom(uv, 1.0 - 0.25 * pro);
  gl_FragColor = mix(texture2D(srcSampler, uv), texture2D(dstSampler, uv), t);
}
"

}

