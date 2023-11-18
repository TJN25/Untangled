extends Node

class_name  State

signal Transitioned(state, new_state_name, character)

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
