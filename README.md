# Como rodar o projeto

Com o ocaml e opam instalados, utilize os comandos:
```bash
opam install dune
opam install csv
dune build
dune exec etl_pipeline
```


# Relatório de Desenvolvimento da Ferramenta ETL

O presente relatório apresenta o desenvolvimento da ferramenta ETL para extração de informações de um CSV de uma base com informações de pedidos e itens do pedido. A partir disso, era necessário calcular a receita e impostos dos produtos, para cada pedido. Como item adicional também foi realizado o cálculo da média mensal de receita e impostos.

O projeto foi criado inteiramente em **OCaml** e com o **Dune** para organizar as dependências e módulos do projeto. Para esse projeto, foram utilizadas LLMs em algumas partes de sua execução e seu uso será detalhado à frente.

## Leitura dos Dados CSV

A partir dos arquivos CSV disponibilizados, foi utilizada a biblioteca `csv` que traz módulos que permitem a leitura do arquivo, transformando-o em um `Csv.t`, uma matriz com valores (lista de listas de strings representando linhas e colunas).

Foi criado um arquivo `readData.ml` para fazer a chamada das funções `Csv.load` dos dois arquivos.

## Conversão dos Dados para Records

Com os `Csv.t`, partiu-se para a criação das _helper functions_ para transformar cada linha em **records**, que são tipos customizados do OCaml, semelhantes a um dicionário/HashMap, mas com campos imutáveis por padrão.

Antes de criar as funções, foram criados os seguintes tipos customizados:

```ocaml
(** Represents an order record with its attributes *)
type order = {
    id : int;
    client_id : int;
    order_date : datetime;
    status: order_status;
    origin: order_origin;
}

(** Represents an item within an order *)
type order_item = {
    order_id : int;
    product_id : int;
    quantity : int;
    price : float;
    tax : float;
}
```

Cada campo corresponde a uma coluna do CSV original.

### Estratégia de Conversão

- Separação do cabeçalho dos dados (`header`)
- Utilização da função `associate` da biblioteca `csv` para gerar listas de tuplas (nome da coluna, valor)
- Aplicação de uma função `map` que preenche um record inicialmente com valores inválidos (`unknown` ou `-1`)
- Uso de `pattern matching` para atualizar os campos do record via `List.fold_left`

Essa estratégia foi aplicada para os dois arquivos CSV.

LLMs (Claude 3.7) foram utilizadas nesta etapa para corrigir problemas de compilação, criação da `main` e funções de `print` para verificação dos dados.

## Filtro e Transformação de Dados

### Filtro

Filtragem de pedidos com base na origem e status. Estratégia adotada:

- Função com `pattern matching` que verifica se o `order` corresponde aos critérios
- IDs válidos são adicionados a uma lista acumuladora

Resultado: uma lista de `order_id`s que atendem aos critérios.

### Transformação

Com a lista de `order_id`s:

- Filtragem dos `order_item`s com aquele `order_id`
- Cálculo de receita (preço × quantidade)
- Cálculo de impostos (preço × quantidade × taxa)
- Soma dos valores com `fold_left`

Novo tipo customizado criado para armazenar os dados agregados:

```ocaml
type agg_order_info = {
    order_id : int;
    total_revenue : float;
    total_tax : float;
}
```

### Funções Criadas

- `transform_orders_to_agg_info`: aplica a transformação em cada `order_id`
- `agg_order_info_of_id`: faz o filtro e soma de valores por `order_id`

Resultado salvo em novo arquivo CSV via `Csv.t`.

LLMs foram utilizadas novamente para auxiliar na criação da `main` de teste e ajustes de build.

## Cálculo Mensal de Receita e Impostos

Mesmo processo, mas aplicado sobre conjuntos "ano-mês":

- Determinação do range temporal dos dados (menor e maior data)
- Criação de lista "ano-mês"
- Filtro de `order_id`s por data
- Aplicação da função de agregação anterior

## Documentação

Todas as funções criadas possuem docstrings, geradas com auxílio da LLM.

---

_Fim do relatório._