shader_type spatial;
render_mode cull_disabled;
const float SPEED = 0.50;
const float K = 2.0*PI;
const float A = 0.20;
const vec3 C = vec3(196.0, 73.0, 57.0);
uniform float scale = 1.0;

void vertex() {
	VERTEX.z += scale*A*sin(K*(VERTEX.x-SPEED*TIME));
}

void fragment() {
	ALBEDO = C/255.0;
}