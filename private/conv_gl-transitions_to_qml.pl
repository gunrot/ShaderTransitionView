#!/usr/bin/perl
use strict;
use warnings;
use File::chdir;

my %glsl2qmlTypes = (
    "float"  => "real",
    "int"  => "int",
    "bool"  => "bool",
    "ivec2" => "vector2d",
    "vec2" => "vector2d",
    "ivec3" => "vector2d",
    "vec3"  => "vector3d",
    "vec4"  => "vector4d",
);
my %glsl2qmlValues = (
    "ivec2" => "Qt.vector2d",
    "vec2" => "Qt.vector2d",
    "ivec3" => "Qt.vector2d",
    "vec3"  => "Qt.vector3d",
    "vec4"  => "Qt.vector4d",
);


{
    my $outdir=$CWD;
    local $CWD = $ARGV[0];

    my @files = glob('*.glsl');
    my $qrcname = $outdir."/gl-transitions.qrc";
    my $jsname = $outdir."/gl-transitions.js";


    open(my $qrc, '>:encoding(UTF-8)', $qrcname) or die "Could not open file '$qrcname' $!";
    open(my $js, '>:encoding(UTF-8)', $jsname) or die "Could not open file '$jsname' $!";
    print $js q"
function getEffects() {
    return [";
    print $qrc q[
<RCC>
    <qresource prefix="/TransitionEffects">
];
    my $number = 0;
    foreach my $file (@files) {
        print "Reading $file\n";
        open(my $in, '<:encoding(UTF-8)', $file)
          or die "Could not open file '$file' $!";
        my $outname = $file;
        $outname =~ s/(.)([^\.]*).*$/\U$1\E$2/g;
        print $qrc "        <file>$outname.qml</file>\n";
        if ($number > 0) { print $js ",";} 
        print $js "'$outname'";
        
        $outname = $outdir."/".$outname.".qml";
        open(my $out, '>:encoding(UTF-8)',$outname )
          or die "Could not open file '$outname' $!";
        print "Generating $outname\n";
        printTransitionEffect($in,$out);

        close($in);
        close($out);
        $number++;
    }
    print $qrc q[
        <file>luma/square.png</file>
        <file>gl-transitions.js</file>
    </qresource>
</RCC>
];
    close ($qrc);
    print $js q"];
}
";
    close ($js);
    print "Generated $number transition qml files\n";
}
sub printTransitionEffect {
my ($in, $out) = @_;
print $out q[
import QtQuick 2.0

//GLSL Source code from: https://github.com/gl-transitions/gl-transitions

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real ratio: width/height
];
my $text;
while (<$in>) {
    $text.=$_;
    if (m/uniform ([^\s]+) ([^;]+);{0,1}\s*\/[\/\*]\s*=\s*([^\*]+)[\/\*; ]*/)
    {
        if (!exists($glsl2qmlTypes{$1}))
        {
            print $out "unknown $1\n";
        }
        else
        {
            my $type = $1;
            print $out "    property $glsl2qmlTypes{$type} $2: ";
            my $val=$3;
            if ($val =~ m/([^\(]*)\(([^\)]*)/)
            {
                $val=$2;
                if ($val =~ m/,/)
                {
                    print $out "$glsl2qmlValues{$type}($val)\n";
                }
                else
                {
                    $type =~ m/(\d)/;
                    my $dim= $1;
                    print $out "$glsl2qmlValues{$type}(";
                    $dim--;
                    while ($dim > 0) {
                        print $out "$val,";
                        $dim--
                    }
                    print $out "$val";
                    print $out ")\n";
                }
            }
            else
            {
               if ($type eq "bool")
               {
                $val = ($val eq "0") ? "false" : "true";
               }
               print $out "$val\n";
            }
        }
    }
    elsif(m/uniform sampler2D luma;/)
    {
        print $out "    property variant luma: img";
        print $out q[
    Image {
        anchors.fill: parent
        id: img
        fillMode: Image.Stretch
        source: "luma/square.png"
        visible:false
        layer.enabled: true
    }
        ]
    }
}

print $out q[
fragmentShader: "
#ifdef GL_ES
    precision highp float;
#endif
    varying vec2 qt_TexCoord0;
    uniform float progress;
    uniform float ratio;
    uniform sampler2D srcSampler;
    uniform sampler2D dstSampler;
    vec4 getFromColor (vec2 uv) {
        return texture2D(srcSampler, vec2(uv.x,1.0 - uv.y));
    }
    vec4 getToColor (vec2 uv) {
        return texture2D(dstSampler, vec2(uv.x,1.0 - uv.y));
    }
];

$text =~s/\"/\\"/g;
$text =~s/uniform ivec/uniform vec/g;
print $out $text;

print $out q[
    void main () {
        gl_FragColor = transition(vec2(qt_TexCoord0.x,1. - qt_TexCoord0.y));
    }
"
}
]
}
