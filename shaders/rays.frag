#version 310 es

precision mediump float;   // default precision

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform TimeBlock {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float duration;
};

layout(binding = 1) uniform sampler2D src;

float easeInOut(float factor) {
    if (factor < .5) {
        return pow(factor, 3.) * 4.;
    } else {
        return pow(factor - 1., 3.) * 4. + 1.;
    }
}

vec4 getShifted(float factor) {
    return texture(src, (qt_TexCoord0 - vec2(.5, .5)) / vec2(factor, 1. + (factor - 1.) * 1.25) + vec2(.5, .5));
}

// Thx ChatGPT for this one
vec3 increaseSaturation(vec3 color, float amount) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 result = mix(vec3(luminance), color, 1.0 + amount);
    return clamp(result, 0.0, 1.0);
}

void main() {
    float position = time / duration;
    vec4 rightPlaced = texture(src, qt_TexCoord0);

    vec4 shifted = vec4(0.);
    for (float shift = 0.; shift < .3; shift += .01) {
        vec4 current = getShifted(1. + shift * position);
        shifted += current*.25;
    }
    shifted *= .1;
    shifted.xyz = increaseSaturation(shifted.xyz, 1.); 

    vec4 bg = vec4(0., 0., 0., min(min(easeInOut(qt_TexCoord0.y * 2.5), easeInOut((-qt_TexCoord0.y + 1.) * 2.5)), 1.) * .65);

    fragColor = bg + shifted*(1. - rightPlaced.a) + rightPlaced*rightPlaced.a;
    fragColor *= min(min(easeInOut(position * 10.), easeInOut((-position + 1.) * 2.5)), 1.);
}
