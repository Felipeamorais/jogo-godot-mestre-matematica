extends Resource
# class_name removido para evitar conflito com Godot

# AST nodes
class NodeAST: pass

class NumberNode:
	var value: int
	func _init(v: int):
		value = v

class IdentifierNode:
	var name: String
	func _init(n: String):
		name = n

class BinaryOpNode:
	var left
	var op: String
	var right
	func _init(l, o: String, r):
		left = l
		op = o
		right = r

class AssignmentNode:
	var name: String
	var expr
	func _init(n: String, e):
		name = n
		expr = e

class ProgramNode:
	var statements: Array = []
