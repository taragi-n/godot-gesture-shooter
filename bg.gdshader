shader_type canvas_item;

// repeat_enable wajib ada
uniform sampler2D gambar_tekstur : repeat_enable;
uniform vec2 scroll_speed = vec2(1.0, 0.0);
uniform float ukuran_tekstur_asli = 64.0;

void fragment() {
	// 1. Hitung tiling horizontal (X) agar tidak melar
	float lebar_sprite = 1.0 / fwidth(UV.x);
	float jumlah_tiling = lebar_sprite / ukuran_tekstur_asli;

	vec2 auto_uv = UV;
	auto_uv.x *= jumlah_tiling;

	// 2. Tambahkan gerakan scrolling
	vec2 moving_uv = auto_uv + (TIME * scroll_speed);

	// --- RAHASIA FIX GARIS PUTIH ---
	// Kita paksa Y tetap di range 0.05 sampai 0.95
	// supaya tidak menyentuh ujung tekstur yang bikin glitch
	moving_uv.y = clamp(UV.y, 0.01, 0.99);

	// 3. Gambar teksturnya
	COLOR = texture(gambar_tekstur, moving_uv);
}