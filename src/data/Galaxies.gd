# src/data/Galaxies.gd
extends Node

const GALAXIES := [
    {"id": "voie_lactee", "name": "Voie Lactée", "stake": 10, "color": Color(0.541, 0.706, 1.0)},
    {"id": "andromede",   "name": "Andromède",   "stake": 50, "color": Color(0.694, 0.541, 1.0)},
    {"id": "sombrero",    "name": "Sombrero",    "stake": 150,"color": Color(1.0, 0.784, 0.392)},
    {"id": "tourbillon",  "name": "Tourbillon",  "stake": 500,"color": Color(0.353, 1.0, 0.784)},
    {"id": "cigare",      "name": "Cigare",      "stake": 1500,"color": Color(1.0, 0.420, 0.616)},
]

func get_galaxy(galaxy_id: String) -> Dictionary:
    for g in GALAXIES:
        if g["id"] == galaxy_id:
            return g
    return GALAXIES[0]
