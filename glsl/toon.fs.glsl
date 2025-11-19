/*
Uniforms already defined by THREE.js
------------------------------------------------------
uniform mat4 viewMatrix; = camera.matrixWorldInverse
uniform vec3 cameraPosition; = camera position in world space
------------------------------------------------------
*/

uniform sampler2D textureMask; //Texture mask, color is different depending on whether this mask is white or black.
uniform sampler2D textureNumberMask; //Texture containing the billard ball's number, the final color should be black when this mask is black.
uniform vec3 maskLightColor; //Ambient/Diffuse/Specular Color when textureMask is white
uniform vec3 materialDiffuseColor; //Diffuse color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform vec3 materialSpecularColor; //Specular color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform vec3 materialAmbientColor; //Ambient color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform float shininess; //Shininess factor

uniform vec3 lightDirection; //Direction of directional light in world space
uniform vec3 lightColor; //Color of directional light
uniform vec3 ambientLightColor; //Color of ambient light

in vec3 vertexCoords;
in vec3 vertexNormal;
in vec2 textureCoords;

float quantize(float x, float steps) {
    return floor(x * steps) / steps;
}

vec3 computeToon(vec3 ambientColor, vec3 diffuseColor, vec3 specularColor, vec3 normal, vec3 light, vec3 halfway)
{
    vec3 intensityAmbient = ambientColor * ambientLightColor;

    float diff = max(dot(normal, light), 0.0);
    diff = quantize(diff, 4.0);   
    vec3 intensityDiffuse = diffuseColor * lightColor * diff;

    float spec = max(dot(normal, halfway), 0.0);
    spec = pow(spec, shininess);
    spec = quantize(spec, 3.0);   
    vec3 intensitySpecular = specularColor * lightColor * spec;

    return intensityAmbient + intensityDiffuse + intensitySpecular;
}

void main() {

    vec3 normal = normalize(vertexNormal);
    vec3 light = normalize(mat3(viewMatrix) * (-lightDirection));
    vec3 eye = normalize(-vertexCoords);
    vec3 halfway = normalize(light + eye);

    vec3 toonBlack = computeToon( materialAmbientColor, materialDiffuseColor, materialSpecularColor,
normal, light, halfway
    );

    vec3 toonWhite = computeToon(maskLightColor,maskLightColor, maskLightColor, normal, light, halfway
    );

    vec4 blackWhiteMix = mix(vec4(toonBlack, 1.0), vec4(toonWhite, 1.0), texture2D(textureMask, textureCoords));

    gl_FragColor = mix(vec4(0.0, 0.0, 0.0, 1.0), blackWhiteMix, texture2D(textureNumberMask, textureCoords));
}
