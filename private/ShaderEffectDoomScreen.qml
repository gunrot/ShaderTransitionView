import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real smoothness: 0.01
    property int barWidth: 10
    property real amplitude: 2
    property real noise: 0.1
    property real frequency: 1

    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;
// Transition parameters --------

// default barWidth = 10
uniform int barWidth; // Number of bars

// default amplitude = 2
uniform float amplitude; // 0 = no variation when going down, higher = some elements go much faster

// default noise = 0.1
uniform float noise; // 0 = no noise, 1 = super noisy

// default frequency = 1
uniform float frequency; // the bigger the value, the shorter the waves

// The code proper --------

float rand(int num) {
  return fract(mod(float(num) * 67123.313, 12.0) * sin(float(num) * 10.3) * cos(float(num)));
}

float wave(int num) {
  float fn = float(num) * frequency * 0.1  * float(barWidth);
  return cos(fn * 0.5) * cos(fn * 0.13) * sin((fn+10.0) * 0.3) / 2.0 + 0.5;
}

float pos(int num) {
  return noise == 0.0 ? wave(num) : mix(wave(num), rand(num), noise);
}

void main() {
  int bar = int(gl_FragCoord.x) / barWidth;
  float scale = 1.0 + pos(bar) * amplitude;
  float phase = progress * scale;
  float posY = 1.0 - qt_TexCoord0.y;
  vec2 p;
  vec4 c;
  if (phase + posY < 1.0) {
    p = vec2(qt_TexCoord0.x, qt_TexCoord0.y + mix(0.0, qt_TexCoord0.y, phase));
    c = texture2D(srcSampler, p);
  } else {
    c = texture2D(dstSampler, qt_TexCoord0);
  }

  // Finally, apply the color
  gl_FragColor = c;
}

"

}

