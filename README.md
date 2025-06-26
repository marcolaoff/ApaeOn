# ApaeOn 🎫

Aplicativo mobile para compra, gestão e validação de ingressos para eventos da APAE Itapira.

## 📱 Visão Geral

O **ApaeOn** foi desenvolvido para simplificar a gestão de eventos da APAE Itapira, trazendo praticidade tanto para usuários quanto para administradores.

- **Usuário:**  
  - Cadastro/login via e-mail ou Google  
  - Compra de ingressos  
  - Carteira digital de ingressos com QR Code  
  - Visualização de eventos disponíveis  

- **Administrador:**  
  - CRUD completo de eventos  
  - Validação de ingressos por QR Code na entrada  
  - Relatórios de vendas/exportação de lista em PDF  

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
- **Packages:** `qr_flutter`, `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `image_picker`, `url_launcher`, `http`  

## **Equipe**
Professor Orientador: Lúcio Pelizzer Paris

Líder do Projeto: [Luis Gustavo Lima Junior](https://github.com/LuisGlima)

Desenvolvedores: 
- [Marco Antonio Lourenci Silva](https://github.com/marcolaoff)
- [Matheus Ferreira Machado](https://github.com/speeky00)
- [Adriano Ferreira Junior](https://github.com/AdrianoJr07)
- [Luis Henrique Topan](https://github.com/lui0908)

## 📲 Como Baixar o Aplicativo

Para facilitar o acesso ao aplicativo, disponibilizamos um QR Code que leva diretamente ao link do nosso **Google Drive**, onde é possível fazer o download do APK para instalação manual no Android.

### 🔗 Baixe escaneando este QR Code:

<img src="pi5/assets/qr_code_drive.PNG" alt="QR Code de Download" width="250"/>

> **Nota:** Se o navegador não permitir o download direto, clique em “Abrir no Drive” ou “Fazer o download mesmo assim”.

## 📲 Como Executar no Android Studio

**Pré-requisitos:**  
- Flutter instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
- Conta e projeto no Firebase
- Emulador configurado

### 1. Clone o repositório

```bash
git clone https://github.com/seuusuario/apaeon.git
cd apaeon

### 2. Instale as Dependências

```bash
flutter pub get


### 3. Execute o app

flutter run


