shader_type canvas_item;

// --- Uniforms del Outline ---
uniform vec3 outline_color: source_color;
uniform float progress: hint_range(0.0, 1.0);
uniform float width: hint_range(0.0, 0.08, 0.001) = 0.001;

// --- Uniforms del Reemplazo de Color ---
uniform vec4 color_original : source_color;
uniform vec4 color_nuevo : source_color;
uniform float tolerancia : hint_range(0.0, 1.0) = 0.1;

// --- Funciones para el Reemplazo de Color ---
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // 1. Obtener el color actual de la textura
    vec4 color_actual = texture(TEXTURE, UV);
    vec4 color_modificado = color_actual;
    
    // 2. Lógica de Reemplazo de Color (Hue)
    vec3 hsv_actual = rgb2hsv(color_actual.rgb);
    vec3 hsv_original = rgb2hsv(color_original.rgb);
    vec3 hsv_nuevo = rgb2hsv(color_nuevo.rgb);
    
    float dif_hue = abs(hsv_actual.x - hsv_original.x);
    dif_hue = min(dif_hue, 1.0 - dif_hue); 
    
    if (dif_hue <= tolerancia && hsv_actual.y > 0.1) {
        vec3 hsv_final = vec3(hsv_nuevo.x, hsv_nuevo.y, hsv_actual.z);
        color_modificado = vec4(hsv2rgb(hsv_final), color_actual.a);
    }
    
    // 3. Lógica del Outline
    vec4 line_neg_y = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x, UV.y - width)).a);
    vec4 line_pos_y = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x, UV.y + width)).a);
    vec4 line_neg_x = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x - width, UV.y)).a);
    vec4 line_pos_x = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x + width, UV.y)).a);
    
    vec4 outline_y = mix(line_neg_y, line_pos_y, line_pos_y);
    vec4 outline_x = mix(line_neg_x, line_pos_x, line_pos_x);
    vec4 outline = mix(outline_y, outline_x, outline_x);
    
    vec4 mezcla_final = mix(color_modificado, outline, progress * (1.0 - color_modificado.a));
    
    COLOR = mezcla_final * COLOR;
}