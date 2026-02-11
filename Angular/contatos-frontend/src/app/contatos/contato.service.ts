import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Contato } from './contato.model';

@Injectable({
  providedIn: 'root'
})
export class ContatoService {

  private apiUrl = 'http://localhost:5000/api/contatos';

  constructor(private http: HttpClient) { }

  //Busca os contatos
  getContatos(): Observable<Contato[]> {
    return this.http.get<Contato[]>(this.apiUrl);
  }

  //Busca individual
  getContatoById(id: number): Observable<Contato> {
    return this.http.get<Contato>(`${this.apiUrl}/${id}`);
  }

  //Cria um contato
  createContato(contato: Contato): Observable<Contato> {
    return this.http.post<Contato>(this.apiUrl, contato);
  }

  //Atuliza um contato
  updateContato(id: number, contato: Contato): Observable<Contato> {
    return this.http.put<Contato>(`${this.apiUrl}/${id}`, contato);
  }

  //Apaga um contato
  deleteContato(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

}
