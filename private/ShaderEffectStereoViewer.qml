import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real zoom: 1
    property real corner_radius: 0.22

    fragmentShader: "
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;
// Tunable parameters
uniform float zoom;  // How much to zoom (out) for the effect ~ 0.5 - 1.0
uniform float corner_radius;  // Corner radius as a fraction of the image height

///////////////////////////////////////////////////////////////////////////////
// Stereo Viewer Toy Transition by Ted Schundler                             //
// BSD License: Free for use and modification by anyone with credit          //
//                                                                           //
// Inspired by ViewMaster / Image3D image viewer devices.                    //
// This effect is similar to what you see when you press the device's lever. //
// There is a quick zoom in / out to make the transition \"valid\" for GLSL.io //
///////////////////////////////////////////////////////////////////////////////

const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 c00 = vec2(0.0, 0.0); // the four corner points
const vec2 c01 = vec2(0.0, 1.0);
const vec2 c11 = vec2(1.0, 1.0);
const vec2 c10 = vec2(1.0, 0.0);

// Check if a point is within a given corner
bool in_corner(vec2 p, vec2 corner, vec2 radius) {
  // determine the direction we want to be filled
  vec2 axis = (c11 - corner) - corner;

  // warp the point so we are always testing the bottom left point with the
  // circle centered on the origin
  p = p - (corner + axis * radius);
  p *= axis / radius;
  return (p.x > 0.0 && p.y > -1.0) || (p.y > 0.0 && p.x > -1.0) || dot(p, p) < 1.0;
}

// Check all four corners
// return a float for v2 for anti-aliasing?
bool test_rounded_mask(vec2 p, vec2 corner_size) {
  return
      in_corner(p, c00, corner_size) &&
      in_corner(p, c01, corner_size) &&
      in_corner(p, c10, corner_size) &&
      in_corner(p, c11, corner_size);
}

// Screen blend mode - https://en.wikipedia.org/wiki/Blend_modes
// This more closely approximates what you see than linear blending
vec4 screen(vec4 a, vec4 b) {
  return 1.0 - (1.0 - a) * (1.0 -b);
}

// Given RGBA, find a value that when screened with itself
// will yield the original value.
vec4 unscreen(vec4 c) {
  return 1.0 - sqrt(1.0 - c);
}

// Grab a pixel, only if it isn't masked out by the rounded corners
vec4 sample_with_corners(sampler2D tex, vec2 p, vec2 corner_size) {
  p = (p - 0.5) / zoom + 0.5;
  if (!test_rounded_mask(p, corner_size)) {
    return black;
  }
  return unscreen(texture2D(tex, p));
}

// special sampling used when zooming - extra zoom parameter and don't unscreen
vec4 simple_sample_with_corners(sampler2D tex, vec2 p, vec2 corner_size, float zoom_amt) {
  p = (p - 0.5) / (1.0 - zoom_amt + zoom * zoom_amt) + 0.5;
  if (!test_rounded_mask(p, corner_size)) {
    return black;
  }
  return texture2D(tex, p);
}

// Basic 2D affine transform matrix helpers
// These really shouldn't be used in a fragment shader - I should work out the
// the math for a translate & rotate function as a pair of dot products instead

mat3 rotate2d(float angle, float aspect) {
  float s = sin(angle);
  float c = cos(angle);
  return mat3(
    c, s ,0.0,
    -s, c, 0.0,
    0.0, 0.0, 1.0);
}

mat3 translate2d(float x, float y) {
  return mat3(
    1.0, 0.0, 0,
    0.0, 1.0, 0,
    -x, -y, 1.0);
}

mat3 scale2d(float x, float y) {
  return mat3(
    x, 0.0, 0,
    0.0, y, 0,
    0, 0, 1.0);
}

// Split an image and rotate one up and one down along off screen pivot points
vec4 get_cross_rotated(vec3 p3, float angle, vec2 corner_size, float aspect) {
  angle = angle * angle; // easing
  angle /= 2.4; // works out to be a good number of radians

  mat3 center_and_scale = translate2d(-0.5, -0.5) * scale2d(1.0, aspect);
  mat3 unscale_and_uncenter = scale2d(1.0, 1.0/aspect) * translate2d(0.5,0.5);
  mat3 slide_left = translate2d(-2.0,0.0);
  mat3 slide_right = translate2d(2.0,0.0);
  mat3 rotate = rotate2d(angle, aspect);

  mat3 op_a = center_and_scale * slide_right * rotate * slide_left * unscale_and_uncenter;
  mat3 op_b = center_and_scale * slide_left * rotate * slide_right * unscale_and_uncenter;

  vec4 a = sample_with_corners(srcSampler, (op_a * p3).xy, corner_size);
  vec4 b = sample_with_corners(srcSampler, (op_b * p3).xy, corner_size);

  return screen(a, b);
}

// Image stays put, but this time move two masks
vec4 get_cross_masked(vec3 p3, float angle, vec2 corner_size, float aspect) {
  angle = 1.0 - angle;
  angle = angle * angle; // easing
  angle /= 2.4;

  vec4 img;

  mat3 center_and_scale = translate2d(-0.5, -0.5) * scale2d(1.0, aspect);
  mat3 unscale_and_uncenter = scale2d(1.0 / zoom, 1.0 / (zoom * aspect)) * translate2d(0.5,0.5);
  mat3 slide_left = translate2d(-2.0,0.0);
  mat3 slide_right = translate2d(2.0,0.0);
  mat3 rotate = rotate2d(angle, aspect);

  mat3 op_a = center_and_scale * slide_right * rotate * slide_left * unscale_and_uncenter;
  mat3 op_b = center_and_scale * slide_left * rotate * slide_right * unscale_and_uncenter;

  bool mask_a = test_rounded_mask((op_a * p3).xy, corner_size);
  bool mask_b = test_rounded_mask((op_b * p3).xy, corner_size);

  if (mask_a || mask_b) {
    img = sample_with_corners(dstSampler, p3.xy, corner_size);
    return screen(mask_a ? img : black, mask_b ? img : black);
  } else {
    return black;
  }
}

void main() {
  float a;
  vec2 p = qt_TexCoord0;
  vec3 p3 = vec3(p.xy, 1.0); // for 2D matrix transforms

  float aspect = 1.0;
  // corner is warped to represent to size after mapping to 1.0, 1.0
  vec2 corner_size = vec2(corner_radius / aspect, corner_radius);

  if (progress <= 0.0) {
    // 0.0: start with the base frame always
    gl_FragColor = texture2D(srcSampler, p);
  } else if (progress < 0.1) {
    // 0.0-0.1: zoom out and add rounded corners
    a = progress / 0.1;
    gl_FragColor = simple_sample_with_corners(srcSampler, p, corner_size * a, a);
  } else if (progress < 0.48) {
    // 0.1-0.48: Split original image apart
    a = (progress - 0.1)/0.38;
    gl_FragColor = get_cross_rotated(p3, a, corner_size, aspect);
  } else if (progress < 0.9) {
    // 0.48-0.52: black
    // 0.52 - 0.9: unmask new image
    gl_FragColor = get_cross_masked(p3, (progress - 0.52)/0.38, corner_size, aspect);
  } else if (progress < 1.0) {
    // zoom out and add rounded corners
    a = (1.0 - progress) / 0.1;
    gl_FragColor = simple_sample_with_corners(dstSampler, p, corner_size * a, a);
  } else {
    // 1.0 end with base frame
    gl_FragColor = texture2D(dstSampler, p);
  }
}

"

}

