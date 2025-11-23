# res://script/compiler/parser.gd
extends Node
class_name Parser

# cargue o AST do caminho correto
const AST = preload("res://script/compiler/ast.gd")
const Lexer = preload("res://script/compiler/lexer.gd") # opcional, apenas para constantes se precisar

# construtor padrão (sem argumentos) — resolve "Too few arguments for new()"
func _init() -> void:
	pass

# estado da instância
var tokens: Array = []
var pos: int = 0

# parse é um método de instância que recebe os tokens
func parse(p_tokens: Array) -> AST.ProgramNode:
	tokens = p_tokens.duplicate()
	pos = 0
	return _parse_program()

func _current():
	return tokens[pos]

func _advance():
	pos += 1
	return tokens[pos - 1]

func _match(type):
	if _current().type == type:
		return _advance()
	return null

func _consume(type, msg: String):
	if _current().type == type:
		return _advance()
	push_error(msg)
	return null

func _parse_program() -> AST.ProgramNode:
	var prog := AST.ProgramNode.new()
	while _current().type != "EOF":
		var stmt = _parse_statement()
		if stmt != null:
			prog.statements.append(stmt)
		else:
			# tentativa simples de recuperação
			_advance()
	return prog

func _parse_statement():
	# espera IDENT ASSIGN expr [SEMI]
	if _current().type == "IDENT":
		var name: String = _advance().value
		_consume("ASSIGN", "Parser: esperado '=' depois de identificador")
		var expr = _parse_expr()
		# opcional: aceitar ';'
		if _current().type == "SEMI":
			_advance()
		return AST.AssignmentNode.new(name, expr)
	push_error("Parser: esperado identificador, token atual: %s" % _current().value)
	return null

# expressões com precedência
func _parse_expr():
	return _parse_term()

func _parse_term():
	var node = _parse_factor()
	while _current().type in ["PLUS", "MINUS"]:
		var op: String = _advance().value
		var right = _parse_factor()
		node = AST.BinaryOpNode.new(node, op, right)
	return node

func _parse_factor():
	var node = _parse_primary()
	while _current().type in ["STAR", "SLASH"]:
		var op: String = _advance().value
		var right = _parse_primary()
		node = AST.BinaryOpNode.new(node, op, right)
	return node

func _parse_primary():
	var t = _current()
	if t.type == "NUMBER":
		_advance()
		return AST.NumberNode.new(int(t.value))
	if t.type == "IDENT":
		_advance()
		return AST.IdentifierNode.new(t.value)
	if t.type == "LPAREN":
		_advance()
		var expr = _parse_expr()
		_consume("RPAREN", "Parser: esperado ')'")
		return expr
	push_error("Parser: token inesperado: %s" % t.value)
	return AST.NumberNode.new(0)
