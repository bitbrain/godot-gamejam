shader_type canvas_item;

uniform vec2 offset = vec2(0.0, 0.0);

void vertex() {
	VERTEX += offset;
}
