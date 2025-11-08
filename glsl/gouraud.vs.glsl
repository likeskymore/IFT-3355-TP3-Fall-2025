/*
Uniforms already defined by THREE.js
------------------------------------------------------
uniform mat4 modelMatrix; = object.matrixWorld
uniform mat4 modelViewMatrix; = camera.matrixWorldInverse * object.matrixWorld
uniform mat4 projectionMatrix; = camera.projectionMatrix
uniform mat4 viewMatrix; = camera.matrixWorldInverse
uniform mat3 normalMatrix; = inverse transpose of modelViewMatrix
uniform vec3 cameraPosition; = camera position in world space
attribute vec3 position; = position of vertex in local space
attribute vec3 normal; = direction of normal in local space
attribute vec2 uv; = uv coordinates of current vertex relative to texture coordinates
------------------------------------------------------
*/

//Custom defined Uniforms for TP3
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

out vec3 gouraudBlack;
out vec3 gouraudWhite;
out vec2 textureCoords;

vec3 computeGouraud(vec3 ambientColor, vec3 diffuseColor, vec3 specularColor, vec3 normal, vec3 light, vec3 eye, vec3 reflection) {
		vec3 intensityAmbient =  ambientColor * ambientLightColor; 

		vec3 intensityDiffuse = diffuseColor *  lightColor * max(dot(normal,light),0.0); 

		vec3 intensitySpecular = specularColor *  lightColor * pow(max(dot(reflection,eye),0.0),shininess); 

		return intensityAmbient + intensityDiffuse + intensitySpecular;
}

void main() {
	//TODO: GOURAUD SHADING
	//Use Phong reflection model
	//Hint: Compute shading in vertex shader, then pass it to the fragment shader for interpolation
	
	//Before applying textures, assume that materialDiffuseColor/materialSpecularColor/materialAmbientColor are the default diffuse/specular/ambient color.
	//For textures, you can first use texture2D(textureMask, uv) as the billard balls' color to verify correctness, then use mix(...) to re-introduce color.
	//Finally, mix textureNumberMask too so numbers appear on the billard balls and are black.
	
	vec3 vertexCoords = vec3(modelViewMatrix * vec4(position, 1.0));
	vec3 vertexNormal = normalize(normalMatrix * normal);
	vec3 light = normalize(mat3(viewMatrix) *  (-lightDirection) );
	vec3 eye = normalize( -vertexCoords );
	vec3 reflection = normalize(reflect(-light,vertexNormal));

	gouraudBlack = computeGouraud(materialAmbientColor, materialDiffuseColor, materialSpecularColor, vertexNormal, light, eye, reflection);
	gouraudWhite = computeGouraud(maskLightColor, maskLightColor, maskLightColor, vertexNormal, light, eye, reflection);

	textureCoords = uv;

    // Multiply each vertex by the model-view matrix and the projection matrix to get final vertex position
	vec4 relativeVertexPosition = modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * relativeVertexPosition;
}
