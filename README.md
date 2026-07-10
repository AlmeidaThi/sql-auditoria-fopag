# Auditoria de Eventos da Folha de Pagamento

Consulta SQL, para RM Totvs, para auditar eventos financeiros da folha de pagamento, recalculando valores esperados com base em salario, jornada, referencia do evento e regras especificas por grupo de evento.

O resultado compara o valor pago com o valor recalculado e classifica cada linha com um status de auditoria.

## Objetivo

Identificar divergencias em eventos de folha para um ano e mes de competencia informados, considerando somente funcionarios sem data de demissao.

A consulta retorna, por funcionario e evento:

- dados da coligada, filial, sindicato e funcionario;
- evento de folha pago;
- salario e jornada vigentes na competencia;
- memoria de calculo aplicada;
- valor recalculado;
- valor pago;
- diferenca em valor e percentual;
- status da auditoria.

## Parametros

A consulta usa dois parametros:

```sql
:ANOCOMP
:MESCOMP
```

Eles filtram a competencia da folha:

```sql
WHERE PFFINANC.ANOCOMP = :ANOCOMP
  AND PFFINANC.MESCOMP = :MESCOMP
```

## Estrutura da consulta

A query e organizada em CTEs:

### REGRAS_EVENTOS

Mapeia cada `CODEVENTO` para um `GRUPO_REGRA`.

Exemplos de grupos:

- `DIVISOR_30`
- `HORA_EXTRA_DIURNA_50`
- `HORA_EXTRA_NOTURNA_50`
- `HORA_EXTRA_DIURNA_70`
- `HORA_EXTRA_NOTURNA_70`
- `HORA_EXTRA_DIURNA_100`
- `HORA_EXTRA_NOTURNA_100`
- `ADICIONAL_NOTURNO`
- `PERICULOSIDADE`
- `ATRASO_HORAS`
- `SOBREAVISO_HORAS`
- `VALE_TRANSPORTE`
- `ANUENIO_PERCENTUAL`
- `ANUENIO_FIXO`

### MOVIMENTOS

Busca os movimentos financeiros da folha na tabela `PFFINANC`, juntando dados de funcionario, filial, pessoa, evento e sindicato.

Tabelas usadas:

- `PFFINANC`
- `PFUNC`
- `GFILIAL`
- `PPESSOA`
- `PEVENTO`
- `PSINDIC`

Filtros principais:

- ano de competencia;
- mes de competencia;
- funcionarios sem data de demissao;
- eventos existentes em `REGRAS_EVENTOS`.

### BASE_PERICULOSIDADE

Calcula uma base auxiliar para eventos de periculosidade, somando valores absolutos dos eventos:

```text
0055, 0031, 0041, 0215
```

### BASE_CALCULO

Monta a base final de calculo, incluindo:

- salario vigente;
- jornada vigente;
- data de vigencia salarial;
- valor do dia;
- valor da hora;
- memoria de calculo;
- valor recalculado bruto.

O salario e a jornada sao obtidos da tabela `PFHSTSAL`, considerando o historico salarial mais recente ate o fim da competencia.

## Principais regras de calculo

| Grupo | Regra resumida |
| --- | --- |
| `DIVISOR_30` | `(salario / 30) * ref` |
| `HORA_EXTRA_DIURNA_50` | `(salario / jornada) * 1.5 * ref` |
| `HORA_EXTRA_NOTURNA_50` | Hora extra 50% com conversao noturna por `52.50` |
| `HORA_EXTRA_DIURNA_70` | `(salario / jornada) * 1.7 * ref` |
| `HORA_EXTRA_NOTURNA_70` | Hora extra 70% com conversao noturna por `52.50` |
| `HORA_EXTRA_DIURNA_100` | `(salario / jornada) * 2 * ref` |
| `HORA_EXTRA_NOTURNA_100` | Hora extra 100% com conversao noturna por `52.50` |
| `ADICIONAL_NOTURNO` | `(salario / jornada) * 0.20 * ref` |
| `PERICULOSIDADE` | `((salario / 30 * ref) + base_periculosidade) * 0.30` |
| `ATRASO_HORAS` | `(salario / jornada) * ref` |
| `SOBREAVISO_HORAS` | `(salario / jornada) * 1/3 * ref` |
| `VALE_TRANSPORTE` | percentual sobre salario conforme filial |
| `ANUENIO_PERCENTUAL` | `salario * 0.01 * ref` |
| `ANUENIO_FIXO` | valor fixo conforme coligada/filial multiplicado por `ref` |

## Regra de vale-transporte

Para `VALE_TRANSPORTE`, o percentual usado depende da filial:

| Filial | Percentual |
| --- | --- |
| `3` | `0%` |
| `4`, `16` | `1%` |
| Demais filiais | `6%` |

O status tambem informa se o valor pago ficou dentro ou acima do limite aplicavel.

## Status de auditoria

A coluna `STATUS_AUDITORIA` pode retornar:

| Status | Significado |
| --- | --- |
| `SEM SALARIO VIGENTE` | Nao foi encontrado salario vigente para a competencia |
| `SEM JORNADA` | Evento depende de jornada, mas a jornada esta zerada |
| `OK` | Valor pago igual ao valor recalculado |
| `OK - ARREDONDAMENTO` | Diferenca entre `0.01` e `0.99` |
| `DIVERGENTE` | Diferenca fora da tolerancia |
| `OK - DENTRO DO LIMITE 0%` | Vale-transporte dentro do limite da filial 3 |
| `OK - DENTRO DO LIMITE 1%` | Vale-transporte dentro do limite das filiais 4 e 16 |
| `OK - DENTRO DO LIMITE 6%` | Vale-transporte dentro do limite das demais filiais |
| `DIVERGENTE - ACIMA DO LIMITE 0%` | Vale-transporte acima do limite da filial 3 |
| `DIVERGENTE - ACIMA DO LIMITE 1%` | Vale-transporte acima do limite das filiais 4 e 16 |
| `DIVERGENTE - ACIMA DO LIMITE 6%` | Vale-transporte acima do limite das demais filiais |

## Campos retornados

A consulta retorna campos como:

- `COD_SINDICATO`
- `NOME_SINDICATO`
- `CODCOLIGADA`
- `CODFILIAL`
- `FILIAL`
- `CHAPA`
- `NOME`
- `CPF`
- `ANOCOMP`
- `MESCOMP`
- `NROPERIODO`
- `DTPAGTO`
- `DATAADMISSAO`
- `DATADEMISSAO`
- `CODSITUACAO`
- `CODEVENTO`
- `DESCRICAO`
- `PROVDESCBASE`
- `GRUPO_REGRA`
- `SALARIO_BASE`
- `JORNADA`
- `DT_VIGENCIA_SALARIAL`
- `VALOR_DIA`
- `VALOR_HORA`
- `REF`
- `MEMORIA_CALCULO`
- `VALOR_RECALCULADO`
- `VALOR_PAGO`
- `DIFERENCA`
- `STATUS_AUDITORIA`
- `PERCENTUAL_DIFERENCA`

## Requisitos

- Banco SQL Server ou ambiente compativel com a sintaxe usada.
- Permissao de leitura nas tabelas consultadas.
- Parametros `:ANOCOMP` e `:MESCOMP` preenchidos pela ferramenta de execucao.

Recursos SQL usados:

- CTE com `WITH`;
- `VALUES`;
- `UNION ALL`;
- `OUTER APPLY`;
- `TOP 1`;
- `EOMONTH`;
- `DATEFROMPARTS`;
- `ISNULL`;
- `NULLIF`;
- `ROUND`;
- `CAST`;
- hints `WITH (NOLOCK)`.

## Observacoes

- A consulta usa `WITH (NOLOCK)`, portanto pode ler dados ainda nao confirmados em transacoes abertas.
- Funcionarios com `DATADEMISSAO` preenchida sao desconsiderados.
- Apenas eventos mapeados em `REGRAS_EVENTOS` entram no resultado.
- O calculo usa o salario vigente mais recente ate o ultimo dia da competencia.
- Diferencas de ate `0.99` sao classificadas como `OK - ARREDONDAMENTO`.
- As regras de valores fixos e percentuais estao codificadas diretamente na consulta.


