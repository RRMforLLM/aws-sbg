extends PanelContainer

var ancho_maximo: float = 60
@onready var label: Label = $Label
var tween_actual: Tween

func mostrar_texto(nuevo_texto: String) -> void:
	if tween_actual and tween_actual.is_valid():
		tween_actual.kill()

	hide()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.custom_minimum_size = Vector2.ZERO
	label.text = nuevo_texto
	var font = label.get_theme_font("font")
	var font_size = label.get_theme_font_size("font_size")
	var ancho= font.get_string_size(nuevo_texto, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	if ancho > ancho_maximo:
		#print(ancho)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = ancho_maximo
	else:
		label.custom_minimum_size.x = 0
	label.visible_characters = 0
	label.reset_size()
	show()
	
	tween_actual = create_tween()
	var tiempo_por_letra = 0.03
	var duracion_total = nuevo_texto.length() * tiempo_por_letra
	tween_actual.tween_property(label, "visible_characters", nuevo_texto.length(), duracion_total)
