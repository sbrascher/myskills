---
name: angular-scaffolder
description: Inicializa um novo projeto Angular 19+ totalmente configurado com Tailwind CSS v4 e PrimeNG 21, estruturando a arquitetura de pastas limpa (core, shared, features, signals) e configurando um tema reativo com Dark Mode.
---

# Angular Scaffolder

Esta skill guia e automatiza a criação e configuração de um novo projeto Angular moderno pré-configurado com Tailwind CSS v4 e PrimeNG 21+.

## Workflow de Inicialização

Siga este passo a passo rigorosamente para construir o projeto do zero:

### 1. Criar Projeto Angular Base
Execute o CLI do Angular para criar um novo projeto com o estilo CSS padrão, roteamento habilitado e usando standalone components por padrão.

```bash
npx -y @angular/cli@latest new <project-name> --style=css --routing --standalone
```

### 2. Instalar Dependências de Estilo e UI
Acesse a pasta do projeto recém-criado e instale o Tailwind CSS v4, PostCSS, o plugin oficial do PrimeUI para Tailwind, o PrimeNG e o pacote de temas oficial. Use a flag `--force` para evitar possíveis conflitos de dependências de peer dependencies dos pacotes mais recentes:

```bash
npm install tailwindcss @tailwindcss/postcss postcss tailwindcss-primeui --save-dev --force
npm install primeng @primeuix/themes --force
```

### 3. Configurar PostCSS
Crie o arquivo `.postcssrc.json` na raiz do projeto para habilitar o processamento do Tailwind CSS v4:

```json
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
```

### 4. Importar Tailwind e PrimeUI no CSS Global
No arquivo global `src/styles.css`, remova todo o conteúdo padrão e insira os imports do Tailwind v4 e do PrimeUI, além de configurar as customizações do tema dentro de `@theme`:

```css
@import "tailwindcss";
@import "tailwindcss-primeui";

@theme {
  --color-primary-50: var(--p-primary-50);
  --color-primary-100: var(--p-primary-100);
  --color-primary-200: var(--p-primary-200);
  --color-primary-300: var(--p-primary-300);
  --color-primary-400: var(--p-primary-400);
  --color-primary-500: var(--p-primary-500);
  --color-primary-600: var(--p-primary-600);
  --color-primary-700: var(--p-primary-700);
  --color-primary-800: var(--p-primary-800);
  --color-primary-900: var(--p-primary-900);
  --color-primary-950: var(--p-primary-950);
}
```

### 5. Configurar PrimeNG no Angular Config
No arquivo `src/app/app.config.ts`, importe `providePrimeNG` e o preset `Aura` de `@primeuix/themes/aura`, além de habilitar as animações assíncronas do Angular para os componentes PrimeNG:

```typescript
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeuix/themes/aura';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideAnimationsAsync(),
    providePrimeNG({
      theme: {
        preset: Aura,
        options: {
          darkModeSelector: '.dark'
        }
      }
    })
  ]
};
```

### 6. Criar Arquitetura de Pastas
Crie as seguintes pastas dentro de `src/app/` para garantir uma estrutura limpa e profissional baseada em domínios/features:

- `src/app/core/` (Guards, Services globais, Interceptors)
- `src/app/shared/` (Componentes comuns/burros, Pipes, Diretivas)
- `src/app/features/` (Módulos/Páginas de negócio da aplicação)
- `src/app/signals/` (Gerenciamento de estado global reativo usando Signals)
- `src/app/models/` (Interfaces e Types globais)

### 7. Scaffolding do Layout Base e Dark Mode
Crie os componentes e serviços essenciais listados no arquivo de referências `references/project-templates.md` para entregar um projeto pronto para desenvolvimento, contendo:
- `theme.service.ts` (Serviço reativo com Signals para controle do Dark Mode integrado com Tailwind e PrimeNG).
- `app.component` atualizado contendo uma interface moderna de Dashboard de demonstração utilizando componentes do PrimeNG (ex: Sidebar, Navbar, Button, Table, Toast, Dialog, Card) estilizados com Tailwind CSS v4.

## Regras de Qualidade e Arquitetura

1. **Signals Primeiro:** Todos os estados reativos locais e globais devem usar `signal`, `computed` e as novas propriedades de fluxo de controle reativo (`input()`, `output()`). Não use `BehaviorSubject` ou injeções antigas.
2. **Estilo CSS-first com Tailwind v4:** Não crie arquivos `tailwind.config.js`. Todas as customizações e extensões de design system devem residir no bloco `@theme` dentro de `src/styles.css`.
3. **Organização Limpa:** Jamais coloque lógica de negócio pesada nos templates ou nos componentes de visualização. Crie serviços ou stores reativos na pasta `signals/`.
4. **Sem Placeholders:** Todos os componentes demonstrativos criados devem ser visualmente ricos e totalmente interativos.
