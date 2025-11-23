extends Node
class_name Semantic

const AST = preload("res://script/compiler/ast.gd")

static func analyze(program: AST.ProgramNode, context: Dictionary) -> Array:
	var errors: Array = []
	var scene: Node = context.get("scene", null)
	if scene == null:
		push_error("Semantic: scene não fornecida")
		return errors

	for stmt in program.statements:
		if stmt is AST.AssignmentNode:
			var name: String = stmt.name  # tipo explícito
			if not scene.has_variable(name):
				errors.append("Semantic: variável '%s' não existe na scene!" % name)
	return errors
