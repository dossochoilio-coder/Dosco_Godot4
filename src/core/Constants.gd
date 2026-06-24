# src/core/Constants.gd — Données statiques DOSCO (autoload)
extends Node

const COL: Dictionary  = {"A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6}
const COLR: Dictionary = {0:"A",1:"B",2:"C",3:"D",4:"E",5:"F",6:"G"}

const BOARD_LAYOUT: Array = [
	[null,null,null,"D1",null,null,null],
	[null,null,"C2","D2","E2",null,null],
	["A3","B3","C3","D3","E3","F3","G3"],
	["A4","B4","C4","D4","E4","F4","G4"],
	["A5","B5","C5","D5","E5","F5","G5"],
	["A6","B6","C6","D6","E6","F6","G6"],
	["A7","B7","C7","D7","E7","F7","G7"],
	[null,null,"C8","D8","E8",null,null],
	[null,null,null,"D9",null,null,null],
]

const INIT_BOARD: Dictionary = {
	"D1":{"color":"W","type":"Sirus"},
	"C2":{"color":"W","type":"Altair"},
	"E2":{"color":"W","type":"Vega"},
	"A3":{"color":"W","type":"Alioth"},
	"B3":{"color":"W","type":"Deneb"},
	"F3":{"color":"W","type":"Alhena"},
	"G3":{"color":"W","type":"Merak"},
	"D9":{"color":"B","type":"Rigel"},
	"C8":{"color":"B","type":"Epi"},
	"E8":{"color":"B","type":"Hadar"},
	"A7":{"color":"B","type":"Mimosa"},
	"B7":{"color":"B","type":"Acrux"},
	"F7":{"color":"B","type":"Spica"},
	"G7":{"color":"B","type":"Regulus"},
}

const PIECE_VALUES: Dictionary = {
	"Sirus":100,"Rigel":100,
	"Alhena":65,"Acrux":65,
	"Altair":60,"Hadar":60,
	"Vega":55,"Epi":55,
	"Deneb":50,"Spica":50,
	"Merak":40,"Mimosa":40,
	"Alioth":45,"Regulus":45,
}

const DIRS: Dictionary = {
	"W":{
		"Sirus": [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]],
		"Alhena":[[-1,1],[0,1],[1,1],[-1,0],[1,0],[0,-1]],
		"Altair":[[-1,1],[1,1],[-1,0],[1,0],[-1,-1],[1,-1]],
		"Vega":  [[0,1],[-1,0],[1,0],[-1,-1],[0,-1],[1,-1]],
		"Deneb": [[-1,1],[0,1],[1,1],[-1,-1],[0,-1],[1,-1]],
		"Merak": [[0,1],[-1,0],[1,0],[0,-1]],
		"Alioth":[[-1,1],[1,1],[-1,-1],[1,-1]],
	},
	"B":{
		"Rigel": [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]],
		"Acrux": [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[0,1]],
		"Hadar": [[-1,-1],[1,-1],[-1,0],[1,0],[-1,1],[1,1]],
		"Epi":   [[0,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]],
		"Spica": [[-1,-1],[0,-1],[1,-1],[-1,1],[0,1],[1,1]],
		"Mimosa":[[0,-1],[-1,0],[1,0],[0,1]],
		"Regulus":[[-1,-1],[1,-1],[-1,1],[1,1]],
	},
}

const INFILTRATION_W: String = "D9"
const INFILTRATION_B: String = "D1"
const CENTER_CELLS: Array    = ["D4","D5","D6","C5","E5"]
const NEAR_INFIL_W: Dictionary = {"D8":180,"D7":60}
const NEAR_INFIL_B: Dictionary = {"D2":200,"D3":70}
const MAX_MOVES_NO_CAPTURE: int = 50

var _valid_cache: Array = []

func get_valid_cells() -> Array:
	if _valid_cache.is_empty():
		for row in BOARD_LAYOUT:
			for cell in row:
				if cell != null: _valid_cache.append(cell)
	return _valid_cache

func to_cr(coord: String) -> Dictionary:
	return {"c": COL[coord[0]] as int, "r": (int(coord.substr(1)) - 1) as int}

func to_coord(c: int, r: int) -> String:
	if c < 0 or c > 6 or r < 0 or r > 8: return ""
	var key: String = (COLR[c] as String) + str(r + 1)
	if key in get_valid_cells(): return key
	return ""
