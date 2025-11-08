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

vec3 computeBlinnPhong(vec3 ambientColor, vec3 diffuseColor, vec3 specularColor, vec3 normal, vec3 light, vec3 halfway) {
		vec3 intensityAmbient =  ambientColor * ambientLightColor; 

		vec3 intensityDiffuse = diffuseColor *  lightColor * max(dot(normal,light),0.0); 

		vec3 intensitySpecular = specularColor *  lightColor * pow(max(dot(halfway,normal),0.0),shininess); 

		return intensityAmbient + intensityDiffuse + intensitySpecular;
}

void main() {
	//TODO: BLINN-PHONG SHADING
	//Use Blinn-Phong reflection model
	//Hint: Similar to Phong shader, but use halfway vector instead.
	
	//Before applying textures, assume that materialDiffuseColor/materialSpecularColor/materialAmbientColor are the default diffuse/specular/ambient color.
	//For textures, you can first use texture2D(textureMask, uv) as the billard balls' color to verify correctness, then use mix(...) to re-introduce color.
	//Finally, mix textureNumberMask too so numbers appear on the billard balls and are black.
	vec3 normal = normalize(vertexNormal);
	vec3 light = normalize(mat3(viewMatrix)*(-lightDirection));
	vec3 eye = normalize(-vertexCoords);
	vec3 halfway = normalize((light + eye));

	vec3 blinnPhongBlack = computeBlinnPhong(materialAmbientColor, materialDiffuseColor, materialSpecularColor, normal, light, halfway);
	vec3 blinnPhongWhite = computeBlinnPhong(maskLightColor, maskLightColor, maskLightColor, normal, light, halfway);

	//Placeholder color
	vec4 blackWhiteMix = mix(vec4(blinnPhongBlack, 1.0), vec4(blinnPhongWhite, 1.0), texture2D(textureMask, textureCoords));
	gl_FragColor = mix(vec4(0.0,0.0,0.0, 1.0), blackWhiteMix, texture2D(textureNumberMask, textureCoords));
}