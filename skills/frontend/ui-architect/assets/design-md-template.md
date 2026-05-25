---
id: {{theme-id}}
type: theme
status: draft
---

# Design System Specification: {{theme-name}}

Este documento técnico define os tokens de design do sistema de design "{{theme-name}}", compatível com as ferramentas automáticas do Google Stitch.

---

## 1. Design Tokens

Use este bloco estruturado para definir as variáveis visuais em três camadas: Core (brutos), Alias (semânticos) e Component (específicos).

```design-token
# ==========================================
# 1. CORES CORE (Paleta Base)
# ==========================================
core-color-primary-base: #6366f1
core-color-primary-light: #818cf8
core-color-primary-dark: #4f46e5

core-color-gray-50: #f8fafc
core-color-gray-100: #f1f5f9
core-color-gray-800: #1e293b
core-color-gray-900: #0f172a

core-color-success: #10b981
core-color-error: #ef4444

# ==========================================
# 2. TOKENS ALIAS (Significado Semântico)
# ==========================================
# Canvas / Backgrounds
color-bg-canvas: $core-color-gray-900
color-bg-surface: $core-color-gray-800

# Texto
color-text-primary: $core-color-gray-50
color-text-secondary: $core-color-gray-100

# Estados de Marca / Destaques
color-primary-action: $core-color-primary-base
color-primary-hover: $core-color-primary-light
color-primary-active: $core-color-primary-dark

# Status
color-status-success: $core-color-success
color-status-error: $core-color-error

# ==========================================
# 3. TIPOGRAFIA
# ==========================================
font-family-base: "Outfit", "Inter", sans-serif
font-size-sm: 14px
font-size-md: 16px
font-size-lg: 20px
font-size-xl: 32px

# ==========================================
# 4. GEOMETRIA E GRID (Espaçamento & Borda)
# ==========================================
spacing-unit: 8px
spacing-xs: $spacing-unit
spacing-sm: 16px
spacing-md: 24px
spacing-lg: 32px

radius-button: 12px
radius-card: 16px
radius-input: 8px
```

---

## 2. Diretrizes de Layout e Comportamento Visual

### Superfícies e Containers
- **Cards (`radius-card`):** Devem possuir um padding de `spacing-md` e borda fina de `1px solid rgba(255, 255, 255, 0.08)`.
- **Modais / Dialogs:** Devem ter um sombreamento sutil e blur de fundo (`backdrop-filter: blur(8px)`).

### Controles e Inputs
- **Botões (`radius-button`):** Devem possuir altura mínima de 44px para facilidade de toque. Transições em hover devem ser de `200ms ease-in-out`.
- **Inputs (`radius-input`):** A borda deve mudar para `color-primary-action` com foco e exibir um outline suave de `2px` com opacidade reduzida.
