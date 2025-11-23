extends Node


# --- VARIÁVEIS GERAIS ---
var player_life := 3
var boss_life := 3
var correct_streak := 0 # Contador de acertos seguidos

# Função que será chamada quando o jogador RESPONDER
func processar_resposta(correta: bool):
	if correta:
		correct_streak += 1
		print("✅ Resposta correta! Série de acertos:", correct_streak)

		# Se acertar 3 vezes seguidas, o boss perde 1 de vida
		if correct_streak == 3:
			boss_life -= 1
			correct_streak = 0
			print("🔥 O boss levou 1 de dano! Vida atual:", boss_life)
			verificar_vencedor()
	else:
		# Se errar, o jogador perde 1 de vida e zera a sequência
		player_life -= 1
		correct_streak = 0
		print("❌ Resposta errada! Você perdeu 1 de vida:", player_life)
		verificar_vencedor()

# Função que verifica quem ganhou ou perdeu
func verificar_vencedor():
	if player_life <= 0:
		print("💀 O jogador foi derrotado!")
	elif boss_life <= 0:
		print("🏆 O jogador venceu o boss!")
