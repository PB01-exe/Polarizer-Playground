shader_type spatial;
const float SPEED = 0.50;
const float K = 2.0*PI;
const float A = 0.25;

void vertex() {
	VERTEX.z += A*sin(K*(VERTEX.x-SPEED*TIME));
}



void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
