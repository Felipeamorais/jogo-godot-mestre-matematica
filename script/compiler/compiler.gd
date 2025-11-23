extends Node
class_name Compiler

const Lexer = preload("res://script/compiler/lexer.gd")
const Parser = preload("res://script/compiler/parser.gd")
const AST = preload("res://script/compiler/ast.gd")
const Semantic = preload("res://script/compiler/semantic.gd")

static func compile_file(path: String, scene: Node) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Compiler: não foi possível abrir %s" % path)
		return
	var src: String = file.get_as_text()
	file.close()

	var lexer: Lexer = Lexer.new()
	var parser: Parser = Parser.new()
	var semantic: Semantic = Semantic.new()

	var tokens: Array = lexer.tokenize(src)
	var program = parser.parse(tokens)
	var sem_errors: Array = semantic.analyze(program, {"scene": scene})

	if sem_errors.size() > 0:
		for e in sem_errors:
			push_error(e)
		return

	for stmt in program.statements:
		if stmt is AST.AssignmentNode:
			var value: int = _eval_expr(stmt.expr, scene)
			if value == null:
				push_error("Compiler: falha ao avaliar '%s'" % stmt.name)
				continue
			if typeof(value) != TYPE_INT:
				value = int(value)
			if _scene_has_property(scene, stmt.name):
				scene.set(stmt.name, value)
				print("Compiler: set %s = %s" % [stmt.name, str(value)])
			else:
				push_error("Compiler: propriedade '%s' não encontrada na scene" % stmt.name)

static func _eval_expr(node, scene: Node) -> int:
	if node is AST.NumberNode:
		return node.value
	if node is AST.IdentifierNode:
		if _scene_has_property(scene, node.name):
			return scene.get(node.name)
		else:
			push_error("Eval: identificador '%s' não encontrado na scene" % node.name)
			return 0
	if node is AST.BinaryOpNode:
		var l: int = _eval_expr(node.left, scene)
		var r: int = _eval_expr(node.right, scene)
		match node.op:
			"+": return l + r
			"-": return l - r
			"*": return l * r
			"/":
				if r == 0:
					push_error("Eval: divisão por zero")
					return 0
				return l / r
			_:
				push_error("Eval: operador desconhecido %s" % node.op)
				return 0
	return 0

static func _scene_has_property(scene: Node, prop_name: String) -> bool:
	for p in scene.get_property_list():
		if p.has("name") and p["name"] == prop_name:
			return true
	var scr = scene.get_script()
	if scr != null:
		for p in scr.get_property_list():
			if p.has("name") and p["name"] == prop_name:
				return true
	return false
