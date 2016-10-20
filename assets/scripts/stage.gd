extends Spatial

onready var pages_panel = get_node( "pages_panel" )
onready var content_button = pages_panel.get_node( "content_button" )
onready var cancel_button = pages_panel.get_node( "cancel_button" )

const STAGES_INFO = { "A":"Questões de Dispersão e Histograma",
                      "B":"Questões de Causa e Efeito",
                      "C":"Questões de Folha de Verificação e Gráfico de Pareto", 
                      "D":"Questões de Controle de Variáveis", 
                      "E":"Questões de Controle de Atributos" }

var active = false

func _ready():
	pages_panel.load_data( get_name() )
	for stage in STAGES_INFO:
		Globals.set( "score_" + stage, 0 )
	Globals.set( "complete_stages", 0 )

func activate():
	active = true

func deactivate():
	active = false

func select():
	if active: 
		pages_panel.show_panel()
		content_button.show()
		cancel_button.show()

func start():
	content_button.hide()
	cancel_button.hide()

func deselect():
	pages_panel.hide_panel()

func _on_content_button_pressed():
	start()

func _on_cancel_button_pressed():
	deselect()
