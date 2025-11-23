extends Resource
class_name Lexer

# Representação de token
class Token:
	var type: String
	var value: String
	func _init(t: String, v: String):
		type = t
		value = v

# Funções auxiliares ------------------------

# Verifica se um caractere é letra
static func _is_letter(c: String) -> bool:
	if c.length() != 1:
		return false
	var code := c.unicode_at(0)
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122)

# Verifica se é dígito (0–9)
static func _is_digit(c: String) -> bool:
	if c.length() != 1:
		return false
	var code := c.unicode_at(0)
	return code >= 48 and code <= 57

# -------------------------------------------

# Lexer principal
static func tokenize(src: String) -> Array:
	var tokens: Array = []
	var i := 0
	var length := src.length()

	while i < length:
		var c := src[i]

		# whitespace
		if c in [" ", "\t", "\n", "\r"]:
			i += 1
			continue

		# números
		if _is_digit(c):
			var num := ""
			while i < length and _is_digit(src[i]):
				num += src[i]
				i += 1
			tokens.append(Token.new("NUMBER", num))
			continue

		# identificadores
		if _is_letter(c) or c == "_":
			var ident := ""
			while i < length and (_is_letter(src[i]) or _is_digit(src[i]) or src[i] == "_"):
				ident += src[i]
				i += 1
			tokens.append(Token.new("IDENT", ident))
			continue

		# operadores / símbolos
		match c:
			"=":
				tokens.append(Token.new("ASSIGN", "="))
			"+":
				tokens.append(Token.new("PLUS", "+"))
			"-":
				tokens.append(Token.new("MINUS", "-"))
			"*":
				tokens.append(Token.new("STAR", "*"))
			"/":
				tokens.append(Token.new("SLASH", "/"))
			";":
				tokens.append(Token.new("SEMI", ";"))
			"(":
				tokens.append(Token.new("LPAREN", "("))
			")":
				tokens.append(Token.new("RPAREN", ")"))
			_:
				push_error("Lexer: caractere inválido '%s' na posição %d" % [c, i])

		i += 1

	tokens.append(Token.new("EOF", ""))
	return tokens
