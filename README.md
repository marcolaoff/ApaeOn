# ApaeOn 🎫

Aplicativo mobile para compra, gestão e validação de ingressos para eventos da APAE Itapira.

## 📱 Visão Geral

O **ApaeOn** simplifica a organização de eventos e o processo de venda de ingressos da APAE. Usuários podem comprar ingressos, acessar QR Codes para entrada e consultar eventos. O app permite à administração criar, editar, excluir eventos, validar ingressos e gerar relatórios de vendas.

## 🚀 Funcionalidades

- Cadastro/login com e-mail e Google
- Visualização e compra de ingressos
- Carteira de ingressos com QR Code individual
- Validação de ingressos via QR Code (admin)
- Administração de eventos (CRUD completo)
- Relatórios e exportação em PDF
- Modo claro/escuro
- Logout e gestão de perfil

## 🛠️ Tecnologias

- **Flutter** (Android/iOS)
- **Firebase Authentication**
- **Cloud Firestore** (banco de dados)
- **Firebase Storage** (imagens)
- **Firebase Functions/Google Cloud VM** (API Flask/PDF)
- **Packages:** qr_flutter, firebase_core, cloud_firestore, firebase_auth, firebase_storage, image_picker, url_launcher, http

## 📲 Como Executar

**Pré-requisitos:**  
- Flutter instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
- Conta e projeto no Firebase

### 1. Clone o repositório

```bash
git clone https://github.com/seuusuario/apaeon.git
cd apaeon
