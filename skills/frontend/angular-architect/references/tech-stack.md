# Referência Técnica: Angular 19+ | PrimeNG 21+ | Tailwind CSS v4

Este documento estabelece as diretrizes técnicas fundamentais a serem seguidas rigorosamente no desenvolvimento contínuo da aplicação.

## 1. Angular 19+ (Signals & Clean Architecture)

O desenvolvimento deve ser orientado a componentes desacoplados, de alta performance e reativos por meio da reatividade nativa do Angular:

### 1.1 Programação Reativa com Signals
- **Inputs:** Use `input()` ou `input.required()`.
  ```typescript
  productId = input.required<string>();
  ```
- **Two-Way Binding:** Use `model()` em vez de combinar `input` e `output`. O `model()` é bidirecional e propaga o sinal automaticamente.
  ```typescript
  searchValue = model<string>(''); // Gera searchValue() e searchValueChange() implicitamente
  ```
- **Outputs:** Use `output()` para notificações do filho para o pai.
  ```typescript
  onSave = output<Product>();
  ```
- **Injeção de Dependências:** Use exclusivamente a função `inject()` no escopo de inicialização da classe.
  ```typescript
  private http = inject(HttpClient);
  ```

### 1.2 Novo Fluxo de Controle (Control Flow)
- Evite `*ngIf` e `*ngFor`. Use a sintaxe `@` nativa para otimização de renderização.
  ```html
  @if (loading()) {
    <p-progressSpinner />
  } @else {
    @for (item of items(); track item.id) {
      <div>{{ item.name }}</div>
    } @empty {
      <p>Nenhum item encontrado.</p>
    }
  }
  ```

---

## 2. Tailwind CSS v4 + @primeuix/themes

A integração visual entre utilitários do Tailwind e componentes do PrimeNG é feita sem arquivos JavaScript adicionais (`tailwind.config.js` está obsoleto):

### 2.1 CSS-First Theme Definition
- Todo o tema deve estar concentrado no `styles.css` principal por meio da diretiva `@theme`.
- Utilize o plugin `@tailwindcss/postcss` e importe o plugin do PrimeUI para gerar a ponte de tokens.
  ```css
  @import "tailwindcss";
  @import "tailwindcss-primeui";
  ```

### 2.2 Sincronização de Dark Mode
- Para manter a consistência visual em componentes PrimeNG e estilizações Tailwind personalizadas, a classe `.dark` deve ser aplicada no elemento `<html>` do documento.
- O PrimeNG deve ser configurado para rastrear essa classe por meio da propriedade `darkModeSelector: '.dark'`.

---

## 3. Estrutura Padrão de Pastas (Clean Architecture)

Organize a base de código do projeto de forma que as responsabilidades fiquem altamente visíveis e desacopladas:

```text
src/app/
├── core/               # Lógica de infraestrutura global (Guards, Services HTTP globais, Interceptors)
├── shared/             # UI genérica (Componentes utilitários/burros, Pipes comuns, Diretivas de UI)
├── features/           # Módulos e páginas divididos por domínios de negócio (ex: 'usuarios', 'produtos')
│   └── <feature-name>/
│       ├── components/ # Componentes específicos desta feature
│       ├── services/   # Consumo de APIs específicas desta feature
│       └── pages/      # Páginas/containers roteáveis
├── signals/            # State Management global baseado em Stores de Signals
└── models/             # Tipos, enums e interfaces globais
```
