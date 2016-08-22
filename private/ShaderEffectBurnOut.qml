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
uniform float smoothness;

const vec2 center = vec2(0.5, 0.5);
const float M_PI = 3.141592653589;

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float linearInterp(vec2 range, vec2 domain, float x) {
  return mix(range.x, range.y, smoothstep(domain.x, domain.y, clamp(x, domain.x, domain.y)));
}

float getGradient(float r, float dist) {
  float grad = smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)); //, 0.0, 1.0);
  if (r - dist < 0.005 && r - dist > -0.005) {
    return -1.0;
  } else if (r - dist < 0.01 && r - dist > -0.005) {
   return -2.0;
  }
  return grad;
}

float round(float a) {
  return floor(a + 0.5);
}

float getWave(vec2 p){

  // I'd really like to figure out how to make the ends meet on my circle.
  // The left side is where the ends don't meet.

  vec2 _p = p - center; // offset from center
  float rads = atan(_p.y, _p.x);
  float degs = degrees(rads) + 180.0;
  vec2 range = vec2(0.0, M_PI * 30.0);
  vec2 domain = vec2(0.0, 360.0);

  float ratio = (M_PI * 30.0) / 360.0;
  //degs = linearInterp(range, domain, degs);
  degs = degs * ratio;
  float x = progress;
  float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
  float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
  float ease_degs = quadraticInOut(sin(degs));

  float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
  return x + deg_wave_pos;
}

void main() {

  if (progress == 0.0) {
    gl_FragColor = texture2D(srcSampler, qt_TexCoord0);
  } else if (progress == 1.0) {
    gl_FragColor = texture2D(dstSampler, qt_TexCoord0);
  } else {
    float dist = distance(center, qt_TexCoord0);
    float m = getGradient(getWave(qt_TexCoord0), dist);
    if (m == -2.0) {
      //gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
      //gl_FragColor = mix(texture2D(srcSampler, qt_TexCoord0), texture2D(dstSampler, qt_TexCoord0), -1.0);
      gl_FragColor = mix(texture2D(srcSampler, qt_TexCoord0), vec4(0.0, 0.0, 0.0, 1.0), 0.75);
    } else {
      gl_FragColor = mix(texture2D(srcSampler, qt_TexCoord0), texture2D(dstSampler, qt_TexCoord0), m);
    }
  }

}
"

}

