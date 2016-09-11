import QtQuick 2.0

//Source code from: http://transitions.glsl.io/

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real slideRatio : width/height

    fragmentShader: "
#ifdef GL_ES
precision medium float;
#endif
// General parameters
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
varying highp vec2 qt_TexCoord0;

/+ code taken from the LibreOffice project and modified o work in qml ShaderEffect
/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */



#define M_PI 3.1415926535897932384626433832795



uniform float slideRatio;


// This function returns the distance between two points, taking into account the slide ratio.
float betterDistance(vec2 p1, vec2 p2)
{
    p1.x *= slideRatio;
    p2.x *= slideRatio;
    return distance(p1, p2);
}

void main()
{
    const float w = 0.5;
    const float v = 0.1;
    const vec2 center = vec2(0.5,0.5);
    // Distance from this fragment to the center, in texture coordinates.
    float dist = betterDistance(center, qt_TexCoord0);

    // We want the ripple to span all of the slide at the end of the transition.
    float t = progress * (sqrt(2.0) * (slideRatio < 1.0 ? 1.0 / slideRatio : slideRatio));

    // Interpolate the distance to the center in function of the time.
    float mixed = smoothstep(t*w-v, t*w+v, dist);

    // Get the displacement offset from the current pixel, for fragments that have been touched by the ripple already.
    vec2 offset = (qt_TexCoord0 - center) * (sin(dist * 64.0 - progress * 16.0) + 0.5) / 32.0;
    vec2 wavyTexCoord = mix(qt_TexCoord0 + offset, qt_TexCoord0, progress);

    // Get the final position we will sample from.
    vec2 pos = mix(wavyTexCoord, qt_TexCoord0, mixed);

    // Sample from the textures and mix that together.
    vec4 leaving = texture2D(srcSampler, pos);
    vec4 entering = texture2D(dstSampler, pos);
    gl_FragColor = mix(entering, leaving, mixed);
}

"

}


