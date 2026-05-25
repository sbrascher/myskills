# Templates de Configuração e Boilerplate

Este arquivo contém as configurações exatas e o código de boilerplate a serem injetados ou seguidos no processo de scaffolding pela skill `angular-scaffolder`.

---

## 1. `.postcssrc.json`

Arquivo de configuração do PostCSS para processar o Tailwind v4. Deve ser criado na raiz do projeto:

```json
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
```

---

## 2. `src/styles.css`

Arquivo CSS principal com as importações e variáveis do tema. Observe o mapeamento de variáveis do PrimeNG Aura para classes utilitárias do Tailwind v4:

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

  --color-surface-0: var(--p-surface-0);
  --color-surface-50: var(--p-surface-50);
  --color-surface-100: var(--p-surface-100);
  --color-surface-200: var(--p-surface-200);
  --color-surface-300: var(--p-surface-300);
  --color-surface-400: var(--p-surface-400);
  --color-surface-500: var(--p-surface-500);
  --color-surface-600: var(--p-surface-600);
  --color-surface-700: var(--p-surface-700);
  --color-surface-800: var(--p-surface-800);
  --color-surface-900: var(--p-surface-900);
  --color-surface-950: var(--p-surface-950);
}

body {
  @apply bg-surface-50 text-surface-900 dark:bg-surface-950 dark:text-surface-50 antialiased transition-colors duration-300;
  font-family: 'Inter', sans-serif;
}
```

---

## 3. `src/app/core/services/theme.service.ts`

Serviço reativo usando Signals para controle de Dark Mode persistido no `localStorage`:

```typescript
import { Injectable, signal, effect } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private readonly THEME_KEY = 'app-dark-mode';
  
  // Signal de estado do Dark Mode
  isDark = signal<boolean>(this.getInitialTheme());

  constructor() {
    // Efeito reativo para sincronizar a classe no HTML toda vez que o sinal muda
    effect(() => {
      const dark = this.isDark();
      const root = window.document.documentElement;
      
      if (dark) {
        root.classList.add('dark');
        localStorage.setItem(this.THEME_KEY, 'true');
      } else {
        root.classList.remove('dark');
        localStorage.setItem(this.THEME_KEY, 'false');
      }
    });
  }

  toggleTheme(): void {
    this.isDark.update(prev => !prev);
  }

  private getInitialTheme(): boolean {
    const saved = localStorage.getItem(this.THEME_KEY);
    if (saved !== null) {
      return saved === 'true';
    }
    // Caso não exista, checa preferência do sistema operacional
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  }
}
```

---

## 4. `src/app/app.component.ts`

Componente principal configurado como standalone com injeção reativa do `ThemeService` e dados fictícios para exibição de uma tabela e gráficos de demonstração:

```typescript
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';
import { CardModule } from 'primeng/card';
import { ThemeService } from './core/services/theme.service';

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  status: 'INSTOCK' | 'LOWSTOCK' | 'OUTOFSTOCK';
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, ButtonModule, TableModule, CardModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  themeService = inject(ThemeService);

  products: Product[] = [
    { id: '1', name: 'Elite Leather Watch', category: 'Accessories', price: 299.99, status: 'INSTOCK' },
    { id: '2', name: 'Cyberpunk Mechanical Keyboard', category: 'Peripherals', price: 189.50, status: 'INSTOCK' },
    { id: '3', name: 'Ergonomic Standing Desk', category: 'Office', price: 499.00, status: 'LOWSTOCK' },
    { id: '4', name: 'Wireless Active Noise Cancelling Headphones', category: 'Audio', price: 249.99, status: 'OUTOFSTOCK' },
    { id: '5', name: 'UltraWide Curved Monitor 34"', category: 'Peripherals', price: 699.99, status: 'INSTOCK' }
  ];

  getStatusClass(status: string): string {
    switch (status) {
      case 'INSTOCK': return 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300';
      case 'LOWSTOCK': return 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300';
      case 'OUTOFSTOCK': return 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300';
      default: return 'bg-surface-100 text-surface-800 dark:bg-surface-800 dark:text-surface-300';
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'INSTOCK': return 'Em Estoque';
      case 'LOWSTOCK': return 'Poucas Unidades';
      case 'OUTOFSTOCK': return 'Esgotado';
      default: return status;
    }
  }
}
```

---

## 5. `src/app/app.component.html`

Interface premium com Dashboard, Sidebar reativa, estatísticas rápidas, tabela de produtos e controle reativo de Dark Mode:

```html
<div class="flex h-screen overflow-hidden bg-surface-50 text-surface-900 dark:bg-surface-950 dark:text-surface-50 font-sans">
  
  <!-- Sidebar -->
  <aside class="hidden md:flex flex-col w-64 bg-surface-0 dark:bg-surface-900 border-r border-surface-200 dark:border-surface-800 p-6 space-y-6">
    <div class="flex items-center space-x-3">
      <div class="w-9 h-9 rounded-xl bg-gradient-to-tr from-primary-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-primary-500/20">
        <span class="font-bold text-lg">A</span>
      </div>
      <div>
        <h1 class="text-base font-bold leading-none tracking-tight">App Architect</h1>
        <span class="text-xs text-surface-400 dark:text-surface-500 font-medium">Angular & PrimeNG</span>
      </div>
    </div>

    <!-- Navigation Menu -->
    <nav class="flex-1 space-y-1">
      <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-primary-50 dark:bg-primary-950/30 text-primary-600 dark:text-primary-400 font-medium transition-all duration-200">
        <i class="pi pi-home text-lg"></i>
        <span>Dashboard</span>
      </a>
      <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-surface-600 dark:text-surface-400 hover:bg-surface-100 dark:hover:bg-surface-800/50 font-medium transition-all duration-200">
        <i class="pi pi-box text-lg"></i>
        <span>Produtos</span>
      </a>
      <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-surface-600 dark:text-surface-400 hover:bg-surface-100 dark:hover:bg-surface-800/50 font-medium transition-all duration-200">
        <i class="pi pi-users text-lg"></i>
        <span>Clientes</span>
      </a>
      <a href="#" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-surface-600 dark:text-surface-400 hover:bg-surface-100 dark:hover:bg-surface-800/50 font-medium transition-all duration-200">
        <i class="pi pi-cog text-lg"></i>
        <span>Configurações</span>
      </a>
    </nav>

    <!-- Footer Sidebar -->
    <div class="pt-4 border-t border-surface-200 dark:border-surface-800">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-3">
          <div class="w-9 h-9 rounded-full bg-surface-200 dark:bg-surface-800 flex items-center justify-center font-bold text-sm">
            US
          </div>
          <div>
            <p class="text-xs font-semibold leading-none">Usuário Admin</p>
            <span class="text-[10px] text-surface-400">admin@app.com</span>
          </div>
        </div>
      </div>
    </div>
  </aside>

  <!-- Main Content Wrapper -->
  <main class="flex-1 flex flex-col overflow-y-auto">
    
    <!-- Top Header -->
    <header class="flex items-center justify-between px-6 py-4 bg-surface-0 dark:bg-surface-900 border-b border-surface-200 dark:border-surface-800">
      <h2 class="text-lg font-bold">Dashboard Geral</h2>
      
      <!-- Theme Switcher & Actions -->
      <div class="flex items-center space-x-3">
        <button 
          pButton 
          [icon]="themeService.isDark() ? 'pi pi-sun' : 'pi pi-moon'" 
          (click)="themeService.toggleTheme()" 
          class="p-button-rounded p-button-text p-button-plain text-lg hover:bg-surface-100 dark:hover:bg-surface-800">
        </button>
        <button pButton label="Nova Venda" icon="pi pi-plus" class="p-button-raised p-button-primary bg-primary-600 hover:bg-primary-700 text-white rounded-xl font-medium px-4 py-2 border-none transition-colors duration-200"></button>
      </div>
    </header>

    <!-- Content Area -->
    <div class="p-6 space-y-6 max-w-7xl mx-auto w-full">
      
      <!-- Metric Cards Grid -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        <!-- Metric Card 1 -->
        <p-card styleClass="shadow-sm border border-surface-200 dark:border-surface-800 rounded-2xl bg-surface-0 dark:bg-surface-900 overflow-hidden">
          <div class="flex justify-between items-start">
            <div>
              <span class="text-xs font-semibold text-surface-400 uppercase tracking-wider">Faturamento Mensal</span>
              <h3 class="text-3xl font-bold mt-2">R$ 45.290,00</h3>
            </div>
            <div class="w-10 h-10 rounded-xl bg-emerald-50 dark:bg-emerald-950/30 flex items-center justify-center text-emerald-600 dark:text-emerald-400">
              <i class="pi pi-dollar text-xl"></i>
            </div>
          </div>
          <div class="flex items-center space-x-2 mt-4 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
            <i class="pi pi-arrow-up-right"></i>
            <span>+12.5% em relação ao mês anterior</span>
          </div>
        </p-card>

        <!-- Metric Card 2 -->
        <p-card styleClass="shadow-sm border border-surface-200 dark:border-surface-800 rounded-2xl bg-surface-0 dark:bg-surface-900 overflow-hidden">
          <div class="flex justify-between items-start">
            <div>
              <span class="text-xs font-semibold text-surface-400 uppercase tracking-wider">Novos Clientes</span>
              <h3 class="text-3xl font-bold mt-2">+342</h3>
            </div>
            <div class="w-10 h-10 rounded-xl bg-indigo-50 dark:bg-indigo-950/30 flex items-center justify-center text-indigo-600 dark:text-indigo-400">
              <i class="pi pi-users text-xl"></i>
            </div>
          </div>
          <div class="flex items-center space-x-2 mt-4 text-xs font-semibold text-indigo-600 dark:text-indigo-400">
            <i class="pi pi-arrow-up-right"></i>
            <span>+8.2% novos cadastros esta semana</span>
          </div>
        </p-card>

        <!-- Metric Card 3 -->
        <p-card styleClass="shadow-sm border border-surface-200 dark:border-surface-800 rounded-2xl bg-surface-0 dark:bg-surface-900 overflow-hidden">
          <div class="flex justify-between items-start">
            <div>
              <span class="text-xs font-semibold text-surface-400 uppercase tracking-wider">Produtos Ativos</span>
              <h3 class="text-3xl font-bold mt-2">1,204</h3>
            </div>
            <div class="w-10 h-10 rounded-xl bg-amber-50 dark:bg-amber-950/30 flex items-center justify-center text-amber-600 dark:text-amber-400">
              <i class="pi pi-box text-xl"></i>
            </div>
          </div>
          <div class="flex items-center space-x-2 mt-4 text-xs font-semibold text-rose-600 dark:text-rose-400">
            <i class="pi pi-arrow-down-right"></i>
            <span>-2% itens esgotados recentemente</span>
          </div>
        </p-card>

      </section>

      <!-- Table Section -->
      <section class="bg-surface-0 dark:bg-surface-900 rounded-2xl border border-surface-200 dark:border-surface-800 overflow-hidden shadow-sm">
        <div class="px-6 py-5 border-b border-surface-200 dark:border-surface-800 flex items-center justify-between">
          <div>
            <h3 class="text-base font-bold">Monitor de Produtos</h3>
            <p class="text-xs text-surface-400 mt-1">Lista de inventário atualizada em tempo real.</p>
          </div>
        </div>

        <!-- PrimeNG Table customizada via Tailwind -->
        <p-table [value]="products" [tableStyle]="{ 'min-width': '50rem' }" styleClass="p-datatable-striped">
          <ng-template pTemplate="header">
            <tr class="bg-surface-50 dark:bg-surface-800/40 text-xs font-bold uppercase tracking-wider border-b border-surface-200 dark:border-surface-800 text-surface-500">
              <th class="px-6 py-4 text-left font-semibold">Nome</th>
              <th class="px-6 py-4 text-left font-semibold">Categoria</th>
              <th class="px-6 py-4 text-left font-semibold">Preço</th>
              <th class="px-6 py-4 text-center font-semibold">Status</th>
            </tr>
          </ng-template>
          <ng-template pTemplate="body" let-product>
            <tr class="hover:bg-surface-50/50 dark:hover:bg-surface-800/20 border-b border-surface-200 dark:border-surface-800 transition-colors duration-150">
              <td class="px-6 py-4 text-sm font-semibold">{{ product.name }}</td>
              <td class="px-6 py-4 text-sm text-surface-500 dark:text-surface-400">{{ product.category }}</td>
              <td class="px-6 py-4 text-sm font-medium">{{ product.price | currency:'BRL' }}</td>
              <td class="px-6 py-4 text-center">
                <span [class]="getStatusClass(product.status)" class="px-2.5 py-1 rounded-full text-xs font-bold tracking-wide uppercase">
                  {{ getStatusLabel(product.status) }}
                </span>
              </td>
            </tr>
          </ng-template>
        </p-table>
      </section>

    </div>
  </main>
</div>
```
