import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property vector2d size : Qt.vector2d(4, 4)
    property real pause: 0.1
    property real dividerSize: 0.01


    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;


// Custom parameters
uniform vec2 size;
uniform float pause;
uniform float dividerSize;

const vec4 dividerColor = vec4(0.0, 0.0, 0.0, 1.0);
const float randomOffset = 0.1;

float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float getDelta(vec2 p) {
  vec2 rectanglePos = floor(vec2(size) * p);
  vec2 rectangleSize = vec2(1.0 / vec2(size).x, 1.0 / vec2(size).y);

  float top = rectangleSize.y * (rectanglePos.y + 1.0);
  float bottom = rectangleSize.y * rectanglePos.y;
  float left = rectangleSize.x * rectanglePos.x;
  float right = rectangleSize.x * (rectanglePos.x + 1.0);

  float minX = min(abs(p.x - left), abs(p.x - right));
  float minY = min(abs(p.y - top), abs(p.y - bottom));
  return min(minX, minY);
}

float getDividerSize() {
  vec2 rectangleSize = vec2(1.0 / vec2(size).x, 1.0 / vec2(size).y);
  return min(rectangleSize.x, rectangleSize.y) * dividerSize;
}

void showDivider (vec2 p) {
  float currentProg = progress / pause;

  float a = 1.0;
  if(getDelta(p) < getDividerSize()) {
    a = 1.0 - currentProg;
  }

  gl_FragColor = mix(dividerColor, texture2D(srcSampler, p), a);
}

void hideDivider (vec2 p) {
  float currentProg = (progress - 1.0 + pause) / pause;

  float a = 1.0;
  if(getDelta(p) < getDividerSize()) {
    a = currentProg;
  }

  gl_FragColor = mix(dividerColor, texture2D(dstSampler, p), a);
}

void main() {
  vec2 p = qt_TexCoord0;

  if(progress < pause) {
    showDivider(p);
  } else if(progress < 1.0 - pause){
    if(getDelta(p) < getDividerSize()) {
      gl_FragColor = dividerColor;
    } else {
      float currentProg = (progress - pause) / (1.0 - pause * 2.0);
      vec2 q = p;
      vec2 rectanglePos = floor(vec2(size) * q);

      float r = rand(rectanglePos) - randomOffset;
      float cp = smoothstep(0.0, 1.0 - r, currentProg);

      float rectangleSize = 1.0 / vec2(size).x;
      float delta = rectanglePos.x * rectangleSize;
      float offset = rectangleSize / 2.0 + delta;

      p.x = (p.x - offset)/abs(cp - 0.5)*0.5 + offset;
      vec4 a = texture2D(srcSampler, p);
      vec4 b = texture2D(dstSampler, p);

      float s = step(abs(vec2(size).x * (q.x - delta) - 0.5), abs(cp - 0.5));
      gl_FragColor = vec4(mix(b, a, step(cp, 0.5)).rgb * s, 1.0);
    }
  } else {
    hideDivider(p);
  }
}
"

}

