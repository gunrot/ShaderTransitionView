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
varying highp vec2 qt_TexCoord0;
/*
  Defocus blur
  (C) Sergey Kosarevsky, 2014
  http://www.linderdaum.com

  This source code is available under MIT license.
*/

void main(void)
{
    float T = progress;

    const float S0 = 1.0/50.0;
    const float S1 = 1.0;
    const float S2 = 1.0/50.0;

    // 2 segments, 1/2 each
    const float Half = 0.5;

    float PixelSize = ( T < Half ) ? mix( S0, S1, T / Half ): mix( S1, S2, (T-Half) / Half );

    vec2 D = vec2(PixelSize,PixelSize);

    // 12-tap Poisson disk coefficients: https://github.com/spite/Wagner/blob/master/fragment-shaders/poisson-disc-blur-fs.glsl
    const int NumTaps = 12;
    vec2 Disk[NumTaps];
    Disk[0] = vec2(-.326,-.406);
    Disk[1] = vec2(-.840,-.074);
    Disk[2] = vec2(-.696, .457);
    Disk[3] = vec2(-.203, .621);
    Disk[4] = vec2( .962,-.195);
    Disk[5] = vec2( .473,-.480);
    Disk[6] = vec2( .519, .767);
    Disk[7] = vec2( .185,-.893);
    Disk[8] = vec2( .507, .064);
    Disk[9] = vec2( .896, .412);
    Disk[10] = vec2(-.322,-.933);
    Disk[11] = vec2(-.792,-.598);

    vec4 C0 = texture2D( srcSampler, qt_TexCoord0 );
    vec4 C1 = texture2D( dstSampler, qt_TexCoord0 );

    for ( int i = 0; i != NumTaps; i++ )
    {
        C0 += texture2D( srcSampler, Disk[i] * D + qt_TexCoord0 );
        C1 += texture2D( dstSampler, Disk[i] * D + qt_TexCoord0 );
    }
    C0 /= float(NumTaps+1);
    C1 /= float(NumTaps+1);

    gl_FragColor = mix( C0, C1, T );
}

"

}

