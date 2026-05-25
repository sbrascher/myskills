# Referência Técnica: Angular 19+ | PrimeNG 21+ | Tailwind CSS v4

Este documento serve como diretriz técnica absoluta para o desenvolvimento e scaffolding do ecossistema front-end com Angular, Tailwind CSS v4 e PrimeNG 21+.

## 1. Angular 19+ (Práticas Modernas)

A partir do Angular 18/19, o ecossistema mudou drasticamente para simplificar e melhorar a performance com **Signals** e **Standalone Components**:

### 1.1 Injeção de Dependência
- Prefira usar a função `inject()` em vez do construtor tradicional para injetar serviços.
- **Exemplo:**
  ```typescript
  import { inject } from '@angular/core';
  import { ThemeService } from './core/services/theme.service';

  export class DashboardComponent {
    private themeService = inject(ThemeService);
  }
  ```

### 1.2 Signals e Reatividade
- **Signals Locais:** Use `signal()` para declarar variáveis reativas locais.
- **Computed:** Use `computed()` para valores derivados que reagem automaticamente.
- **Signal Inputs:** Use `input<string>()` ou `input.required<number>()` em vez do decorador `@Input()`.
- **Signal Outputs:** Use `output<void>()` ou `output<string>()` em vez de `@Output() EventEmitter`.
- **Control Flow:** Use a nova sintaxe de fluxo de controle nativa (`@if`, `@for`, `@switch`) em vez das diretivas estruturais legadas (`*ngIf`, `*ngFor`).
  - *Evite:* `*ngIf="isLoading"`
  - *Prefira:* `@if (isLoading()) { ... }`

---

## 2. Tailwind CSS v4 (Design System no CSS)

O Tailwind CSS v4 introduziu um novo compilador de alta performance construído em Rust, mudando a forma de configurar e usar a ferramenta:

### 2.1 CSS-First Configuration
- **Não use `tailwind.config.js`.** Toda a configuração de temas, cores customizadas, fontes e animações é feita diretamente no arquivo CSS global usando a diretiva `@theme`.
- **Imports:** A importação é feita apenas via `@import "tailwindcss";` no topo do arquivo CSS principal.
- **Customização de Cores e Estilos:**
  ```css
  @import "tailwindcss";

  @theme {
    --color-brand-primary: #3b82f6;
    --font-sans: "Outfit", sans-serif;
  }
  ```

### 2.2 Classes Utilitárias vs Design Tokens
- Em vez de reescrever cores inline arbitrárias (ex: `bg-[#3b82f6]`), declare no CSS `@theme` e use classes semânticas e padronizadas (`bg-brand-primary`).

---

## 3. PrimeNG 21+ (Componentes e Temas)

A versão 21 do PrimeNG foca em integração nativa com Tailwind CSS, performance de bundle e flexibilidade de customização técnica:

### 3.1 CSS Variables & Design Tokens
- O PrimeNG expõe variáveis CSS correspondentes a cada token de design (ex: `--p-primary-500`, `--p-surface-500`).
- O plugin `tailwindcss-primeui` faz a ponte entre essas variáveis e as classes do Tailwind, permitindo o uso de classes nativas como `text-primary-500` e `bg-surface-100`.

### 3.2 Styled Mode
- Por padrão, utilize o **Styled Mode** com o preset **Aura** (`@primeuix/themes/aura`). Esse preset garante uma UI leve, limpa e moderna que se adapta perfeitamente com classes do Tailwind.

### 3.3 Sincronização de Dark Mode
- Para habilitar o Dark Mode no PrimeNG e Tailwind ao mesmo tempo, use a classe `.dark` no elemento `<html>` do documento e garanta que o PrimeNG esteja configurado com `darkModeSelector: '.dark'`.
