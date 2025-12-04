import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ideal: esconder isso depois (ex: .env)
  static const _apiKey = 'chave-api';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text('''
Você é o assistente oficial do aplicativo ApaeOn, utilizado pela APAE de Itapira.

REGRAS IMPORTANTES:
- Seu foco é EXCLUSIVAMENTE:
  • explicar como usar o app ApaeOn (eventos, compra de ingressos, meus ingressos, perfil, login, localização);
  • tirar dúvidas sobre a APAE de Itapira (missão, atividades, eventos da instituição etc.), desde que estejam alinhadas ao contexto do app.
- NÃO responda perguntas sobre outros assuntos (notícias, esporte, política, matemática, curiosidades gerais, etc.).
- NÃO invente funcionalidades que o app não tem.
- Sempre responda em português, de forma simples, educada e direta.

Se a pergunta NÃO tiver relação com:
- o app ApaeOn; OU
- a APAE de Itapira;

então responda APENAS esta frase (sem adicionar nada antes ou depois):

"Sou o assistente do aplicativo ApaeOn e da APAE de Itapira. No momento, só posso ajudar com dúvidas sobre o app e sobre a instituição."
'''),
    );
  }

  Future<String> ask(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      return 'Digite uma dúvida sobre o uso do aplicativo 😊';
    }

    final prompt = '''
Pergunta do usuário: "$userMessage"

Lembrete das regras:
- Só responda sobre o app ApaeOn ou sobre a APAE de Itapira.
- Se a pergunta não tiver relação com isso, responda exatamente:
"Sou o assistente do aplicativo ApaeOn e da APAE de Itapira. No momento, só posso ajudar com dúvidas sobre o app e sobre a instituição."
''';

    final response = await _model.generateContent([
      Content.text(prompt),
    ]);

    return response.text?.trim() ??
        'Não consegui gerar uma resposta agora. Tente novamente em instantes.';
  }
}
