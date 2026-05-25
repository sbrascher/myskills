# Exemplos Práticos de Código (Boilerplate)

Utilize estes modelos de código como base de referência ao gerar novos recursos na aplicação. Eles seguem 100% os padrões do Angular 19+ e PrimeNG 21+.

---

## 1. Componente Standalone Moderno (Signals)

Este exemplo demonstra a criação de um componente de formulário completo usando a nova API de Signals (`input()`, `model()`, `output()`, `inject()`), Control Flow nativo e componentes PrimeNG:

```typescript
// features/produtos/components/editor-produto.component.ts
import { Component, inject, input, model, output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumberModule } from 'primeng/inputnumber';
import { CardModule } from 'primeng/card';
import { MessageService } from 'primeng/api';

export interface Produto {
  id?: string;
  nome: string;
  preco: number;
}

@Component({
  selector: 'app-editor-produto',
  standalone: true,
  imports: [CommonModule, FormsModule, ButtonModule, InputTextModule, InputNumberModule, CardModule],
  template: `
    <p-card [header]="isEdicao() ? 'Editar Produto' : 'Novo Produto'" styleClass="shadow-md rounded-2xl bg-surface-0 dark:bg-surface-900 border border-surface-200 dark:border-surface-800">
      <form (submit)="salvar()" class="flex flex-col space-y-4">
        
        <!-- Campo Nome -->
        <div class="flex flex-col space-y-1">
          <label for="nome" class="text-xs font-semibold text-surface-500">Nome do Produto</label>
          <input 
            pInputText 
            id="nome" 
            name="nome" 
            [(ngModel)]="produto.nome" 
            required 
            placeholder="Digite o nome do produto"
            class="w-full rounded-lg"
          />
        </div>

        <!-- Campo Preço -->
        <div class="flex flex-col space-y-1">
          <label for="preco" class="text-xs font-semibold text-surface-500">Preço</label>
          <p-inputNumber 
            id="preco" 
            name="preco" 
            [(ngModel)]="produto.preco" 
            mode="currency" 
            currency="BRL" 
            locale="pt-BR" 
            class="w-full"
            styleClass="w-full"
            inputStyleClass="w-full rounded-lg"
          />
        </div>

        <!-- Botões de Ação -->
        <div class="flex items-center justify-end space-x-3 pt-2">
          <button 
            pButton 
            type="button" 
            label="Cancelar" 
            class="p-button-text p-button-secondary rounded-lg font-medium"
            (click)="onCancel.emit()"
          ></button>
          
          <button 
            pButton 
            type="submit" 
            label="Salvar Produto" 
            icon="pi pi-check" 
            class="p-button-raised bg-primary-600 hover:bg-primary-700 text-white rounded-lg font-medium px-4 py-2 border-none transition-colors duration-200"
          ></button>
        </div>

      </form>
    </p-card>
  `
})
export class EditorProdutoComponent {
  private messageService = inject(MessageService);

  // Inputs e Outputs reativos usando as novas APIs de Signals
  isEdicao = input<boolean>(false);
  produto = model.required<Produto>(); // Bidirecional via model()
  
  onSave = output<Produto>();
  onCancel = output<void>();

  salvar(): void {
    const dados = this.produto();
    if (!dados.nome || dados.preco <= 0) {
      this.messageService.add({
        severity: 'error',
        summary: 'Erro de Validação',
        detail: 'Preencha todos os campos corretamente.'
      });
      return;
    }
    
    this.onSave.emit(dados);
  }
}
```

---

## 2. Signal Store (Gerenciamento de Estado)

Este padrão implementa uma Store de estado global ou de escopo de feature utilizando apenas Signals, oferecendo uma alternativa reativa leve, limpa e performática ao RxJS ou NgRx:

```typescript
// signals/produtos.store.ts
import { Injectable, computed, signal, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { toSignal } from '@angular/core/rxjs-interop';
import { catchError, of } from 'rxjs';
import { Produto } from '../features/produtos/components/editor-produto.component';

interface ProdutosState {
  items: Produto[];
  loading: boolean;
  error: string | null;
  filtroPesquisa: string;
}

@Injectable({
  providedIn: 'root'
})
export class ProdutosStore {
  private http = inject(HttpClient);
  private readonly API_URL = '/api/produtos';

  // Estado privado (imutabilidade interna)
  private state = signal<ProdutosState>({
    items: [],
    loading: false,
    error: null,
    filtroPesquisa: ''
  });

  // Seletores públicos (leitura reativa)
  items = computed(() => this.state().items);
  loading = computed(() => this.state().loading);
  error = computed(() => this.state().error);
  filtroPesquisa = computed(() => this.state().filtroPesquisa);

  // Seletor calculado derivado
  itemsFiltrados = computed(() => {
    const termo = this.state().filtroPesquisa.toLowerCase().trim();
    if (!termo) return this.state().items;
    return this.state().items.filter(item => 
      item.nome.toLowerCase().includes(termo)
    );
  });

  // Ações de alteração de estado
  setFiltro(termo: string): void {
    this.state.update(s => ({ ...s, filtroPesquisa: termo }));
  }

  carregarProdutos(): void {
    this.state.update(s => ({ ...s, loading: true, error: null }));

    this.http.get<Produto[]>(this.API_URL).pipe(
      catchError(err => {
        this.state.update(s => ({ ...s, error: 'Erro ao carregar produtos', loading: false }));
        return of([] as Produto[]);
      })
    ).subscribe(dados => {
      this.state.update(s => ({ ...s, items: dados, loading: false }));
    });
  }

  adicionarProduto(produto: Produto): void {
    this.state.update(s => ({ ...s, loading: true }));
    
    this.http.post<Produto>(this.API_URL, produto).subscribe({
      next: (novoProduto) => {
        this.state.update(s => ({
          ...s,
          items: [...s.items, novoProduto],
          loading: false
        }));
      },
      error: () => this.state.update(s => ({ ...s, error: 'Erro ao adicionar produto', loading: false }))
    });
  }
}
```

---

## 3. Mapeamento de `DESIGN.md` (`ui-architect`) para Tailwind v4

Ao ler a definição visual em `DESIGN.md` gerada pela `ui-architect`, configure o `styles.css` global do projeto para que os novos componentes herdem as cores corporativas de forma centralizada:

Se o `DESIGN.md` definir:
- **Cor Primária:** `#8b5cf6` (Purple 500)
- **Cor de Destaque (Accent):** `#f43f5e` (Rose 500)

Você deve instruir o modelo a mapear essas cores no bloco `@theme` no `src/styles.css` da seguinte forma:

```css
/* src/styles.css */
@import "tailwindcss";
@import "tailwindcss-primeui";

@theme {
  /* Substitui a cor de destaque da marca */
  --color-brand-primary: #8b5cf6;
  --color-brand-accent: #f43f5e;
  
  /* Sobrescreve as cores semânticas primárias do PrimeNG no Tailwind */
  --color-primary-500: #8b5cf6;
  --color-primary-600: #7c3aed;
  --color-primary-700: #6d28d9;
}
```

Isso garante que classes utilitárias como `bg-brand-primary` ou `text-brand-accent` fiquem prontas para estilização, mantendo 100% de consistência corporativa entre PrimeNG e Tailwind CSS!
