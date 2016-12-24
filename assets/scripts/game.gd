extends Node

const STAGES_INFO = { "A": [ "Questões de Dispersão e Histograma", 2 ],
                      "B": [ "Questões de Causa e Efeito", 4 ],
                      "C": [ "Questões de Folha de Verificação e Gráfico de Pareto", 6 ], 
                      "D": [ "Questões de Controle de Variáveis", 8 ], 
                      "E": [ "Questões de Controle de Atributos", 10 ] }

onready var stages = get_tree().get_root().get_node( "main/game/stages" ).get_children()
onready var crosshair = get_tree().get_root().get_node( "main/crosshair" )

var total_score = 0
var stage_scores = {}
var completed_stages = 0