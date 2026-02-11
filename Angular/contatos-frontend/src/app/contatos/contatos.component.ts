import { Component, OnInit } from '@angular/core';
import { ContatoService } from './contato.service';
import { Contato } from './contato.model';

@Component({
  selector: 'app-contatos',
  templateUrl: './contatos.component.html',
  styleUrls: ['./contatos.component.css']
})
export class ContatosComponent implements OnInit {

  contatos: Contato[] = [];
  contatoSelecionado: Contato | null = null;
  novoContato: Contato = { nome: '', telefone: '', email: '' };
  termoPesquisa: string = '';
  editando: boolean = false;

  constructor(private contatoService: ContatoService) { }

  ngOnInit() {
    this.carregarContatos();
  }

  carregarContatos() {
    this.contatoService.getContatos().subscribe(
      (dados) => {
        this.contatos = dados;
        console.log('Contatos carregados:', this.contatos);
      },
      (erro) => {
        console.error('Erro ao carregar contatos:', erro);
      }
    );
  }

  buscarContatoPorId(id: number) {
    this.contatoService.getContatoById(id).subscribe(
      (dados) => {
        this.contatoSelecionado = dados;
        console.log('Contato encontrado:', this.contatoSelecionado);
      },
      (erro) => {
        console.error('Erro ao buscar contato:', erro);
      }
    );
  }

  criarContato(contato: Contato) {
    
    this.contatoService.createContato(contato).subscribe(
      (novoContato) => {
       
        this.contatos.push(novoContato);
        console.log('Contato criado com sucesso:', novoContato);
        
        this.carregarContatos();
        
        this.limparFormulario();
      },
      (erro) => {
        console.error('Erro ao criar contato:', erro);
      }
    );
  }

  atualizarContato(id: number, contato: Contato) {
    
    this.contatoService.updateContato(id, contato).subscribe(
      (contatoAtualizado) => {
        
        const index = this.contatos.findIndex(c => c.idPessoa === id);
        
       
        if (index !== -1) {
          this.contatos[index] = contatoAtualizado;
        }
        
        console.log('Contato atualizado com sucesso:', contatoAtualizado);
        
       
        this.carregarContatos();
        
        this.limparFormulario();
      },
      (erro) => {
        console.error('Erro ao atualizar contato:', erro);
      }
    );
  }

  deletarContato(id: number) {
    
    this.contatoService.deleteContato(id).subscribe(
      () => {
        
        this.contatos = this.contatos.filter(c => c.idPessoa !== id);
        
        console.log('Contato deletado com sucesso. ID:', id);
        
        
        if (this.contatoSelecionado && this.contatoSelecionado.idPessoa === id) {
          this.contatoSelecionado = null;
        }
      },
      (erro) => {
        console.error('Erro ao deletar contato:', erro);
      }
    );
  }

  salvarContato() {
    console.log('Salvando contato:', this.novoContato);
    if (this.editando && this.novoContato.idPessoa) {
      this.atualizarContato(this.novoContato.idPessoa, this.novoContato);
    } else {
      this.criarContato(this.novoContato);
    }
  }

  editarContato(contato: Contato) {
    this.novoContato = { ...contato };
    this.editando = true;
  }

  limparFormulario() {
    this.novoContato = { nome: '', telefone: '', email: '' };
    this.editando = false;
  }

  contatosFiltrados(): Contato[] {
    if (!this.termoPesquisa) {
      return this.contatos;
    }
    
    const termo = this.termoPesquisa.toLowerCase();
    return this.contatos.filter(c =>
      c.nome.toLowerCase().includes(termo) ||
      c.telefone.toLowerCase().includes(termo) ||
      c.email.toLowerCase().includes(termo)
    );
  }

}
