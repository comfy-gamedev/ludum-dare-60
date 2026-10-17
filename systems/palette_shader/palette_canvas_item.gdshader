// NOTE: Shader automatically converted from Godot Engine 4.8.beta1's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform sampler3D lut : filter_nearest;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = c;//texture(lut, c.rgb);
	//COLOR.a = c.a;
}
