# Handoff: App do Agente Comunitário (Dr. Olhar)

## Overview
Aplicativo móvel do agente comunitário de saúde para o sistema Dr. Olhar — ausculta remota
domiciliar integrada ao prontuário eletrônico (SRS A.01, SaMD Classe II, RDC 751 / LGPD).

O agente faz login (sessão offline de 12 h), abre a agenda de pacientes, cadastra pacientes
novos em campo, percorre um mapa corporal de 9 pontos de ausculta, lê as instruções
específicas do tipo de ponto ao paciente, grava 10 s de áudio por ponto com feedback de
ruído em tempo real, revisa e aceita cada captura. Concluídos os 9 pontos, um aviso de
"Exame concluído" encerra a visita.

Idioma da interface: **Português (BR)**. Todos os textos deste documento são os textos finais.

## About the Design Files
Os arquivos deste pacote são **referências de design feitas em HTML** — protótipos que mostram
aparência e comportamento pretendidos, **não código de produção para copiar**.

A tarefa é **recriar estes designs no ambiente já existente do codebase alvo** (React Native,
Flutter, Kotlin/Compose, SwiftUI, etc.), usando seus padrões, bibliotecas e design system
estabelecidos. Se ainda não houver ambiente definido, escolher a stack mais apropriada para um
app móvel offline-first com captura de áudio e implementar os designs nela.

O protótipo é um único componente HTML com um seletor de telas lateral e um frame Android de
412 × 892 px. Nada disso faz parte do app: a lateral, o frame e os controles de simulação
("Conexão", "Ruído ambiente") existem só para navegar o protótipo.

## Fidelity
**Alta fidelidade (hifi).** Cores, tipografia, espaçamentos, raios, ícones e textos são finais
e devem ser recriados fielmente com as bibliotecas do codebase. As duas ilustrações do corpo
humano são placeholders de terceiros (ver Assets) e devem ser substituídas por arte licenciada.

Duas ressalvas conhecidas, a corrigir na implementação:
- O botão **+** (cadastrar paciente) está em 30 × 30 px por decisão do cliente, abaixo do mínimo
  de 44 px de área de toque. Recomendado manter o visual e ampliar a área tocável (hitSlop).
- O áudio, o SNR e a forma de onda são simulados no protótipo; os valores reais vêm do pipeline
  de captura.

## Screens / Views

Sete telas. O fluxo de coleta é um assistente de 3 passos (mapa 1/3 → instruções 2/3 →
gravação 3/3), com a revisão como etapa de saída que volta ao mapa.

---

### 01 · Login do agente
**Purpose:** autenticar o agente; a sessão vale 12 h offline.

**Layout:** tela cheia branca (#FFFFFF), `padding: 0 24px`, coluna flex centralizada
verticalmente, `gap: 28px`; rodapé fixo embaixo.

**Components (de cima para baixo):**
1. **Bloco de marca** — coluna centralizada, `text-align: center`.
   - Logo: quadrado 46 × 46 px, `border-radius: 13px`, fundo #1B6FE3, `margin-bottom: 20px`;
     dentro, círculo 16 × 16 px com `border: 3px solid #FFF`.
   - Título "Dr. Olhar": Public Sans 700, 30px, `line-height: 1.1`, `letter-spacing: -.025em`, #0F1720.
2. **Campo "CPF do agente"** — rótulo Public Sans 600, 12px, #57646F, `margin-bottom: 7px`.
   Caixa 56px de altura, `border: 1.5px solid #E1E6EB`, `radius: 12px`, `padding: 0 16px`,
   fundo #F5F7F9, valor em IBM Plex Mono 500, 18px ("821.443.190-05").
3. **Campo "Senha"** — igual ao anterior; valor "••••••" em IBM Plex Mono 500, 20px,
   `letter-spacing: .3em`.
4. **Botão "Entrar"** — 60px de altura, `radius: 14px`, fundo #1B6FE3 (hover #0E4FAE),
   texto #FFF Public Sans 600, 17px. Navega para 02.
5. **Aviso LGPD** — fundo #EDF3FD, `radius: 12px`, `padding: 14px`, ponto 8 × 8 px #1B6FE3 à
   esquerda, texto Public Sans 400, 13px, `line-height: 1.45`, #2A4A72:
   "Login válido por 12 h em modo offline. Os dados coletados ficam criptografados no aparelho
   até haver rede."
6. **Rodapé** — IBM Plex Mono 400, 11.5px, #57646F, centralizado: "v A.01 · RDC 751 · LGPD".

---

### 02 · Pacientes
**Purpose:** agenda do dia, estado de envio por visita, entrada para cadastro e exclusão.

**Layout:** cabeçalho branco fixo + lista rolável (`overflow-y: auto`) sobre fundo #EEF1F4.
O container é `position: relative` para ancorar o diálogo de exclusão.

**Cabeçalho** (fundo #FFFFFF, `padding: 18px 20px 16px`, `border-bottom: 1px solid #E1E6EB`):
- Linha 1: à esquerda "Segunda, 16 nov" (Public Sans 400, 13px, #57646F) e "Pacientes"
  (Public Sans 700, 24px, `letter-spacing: -.02em`); à direita, em linha com `gap: 9px`:
  - **Chip de conexão** — `padding: 7px 11px`, `radius: 20px`; online: fundo #E6F4EC, ponto e
    texto #0F6B45, "Online"; offline: fundo #FAF3E3, ponto e texto #8A5A0B, "Offline".
    Texto em IBM Plex Mono 600, 11px.
  - **Botão +** — 30 × 30 px, `radius: 9px`, fundo #1B6FE3 (hover #0E4FAE), glifo "+" Public
    Sans 300, 18px, #FFF. Navega para 03. `aria-label="Cadastrar paciente"`.
- Linha 2 (`margin-top: 14px`, `gap: 8px`): dois cartões `flex: 1`, `padding: 11px 12px`,
  `radius: 11px`, fundo #F5F7F9 — número em Public Sans 700, 20px (o de "concluídas" em
  #0F6B45), rótulo Public Sans 400, 11.5px, #57646F, `margin-top: 5px`: "agendadas", "concluídas".

**Linha de paciente** (uma por item, `gap: 10px` entre linhas):
container flex `align-items: stretch`, fundo #FFF, `border: 1px solid #E1E6EB`,
`border-left: 4px solid #1B6FE3`, `radius: 13px`, `overflow: hidden`, hover `border-color: #C8D2DB`.
- **Área de toque** (`flex: 1`, `padding: 15px 4px 15px 14px`, sem borda, fundo transparente) —
  abre a tela 04 com o mapa do paciente:
  - Nome: Public Sans 600, 16.5px, #0F1720.
  - Detalhe: Public Sans 400, 13px, #57646F, `margin-top: 4px` (ex. "74 anos · Sítio Boa Vista").
  - À direita, coluna `align-items: flex-end`, `gap: 8px`: horário em IBM Plex Mono 400, 12.5px,
    #57646F; abaixo, **ícone de estado de envio** — caixa 26 × 26 px, `radius: 8px`:
    - **na nuvem**: fundo #E6F4EC, traço #0F6B45, ícone de nuvem (15px)
    - **enviando**: fundo #EDF3FD, traço #1B6FE3, flecha para cima (14px)
    - **sem conexão**: fundo #FAF3E3, traço #8A5A0B, antena de rede cortada (15px)
- **Botão de exclusão** — coluna 36px, `border-left: 1px solid #E1E6EB`, fundo transparente,
  ícone de lixeira 21px em #57646F; hover fundo #FBECEA e traço #C33B2E.
  `aria-label="Excluir paciente"`. Abre o diálogo de confirmação.

**Nota de rodapé da lista** — `padding: 13px`, `radius: 12px`, `border: 1px dashed #E1E6EB`,
etiqueta "UX-05" (IBM Plex Mono 600, 10px, #57646F) + texto Public Sans 400, 12.5px, #57646F:
"O ícone à direita mostra o envio de cada visita: nuvem sincronizado, flecha em envio, rede
cortada sem conexão."

**Diálogo "Excluir paciente"** (overlay dentro da tela, `z-index: 30`, fundo
`rgba(15,23,32,.55)`, `padding: 24px`, centralizado):
cartão `max-width: 320px`, fundo #FFF, `radius: 20px`, `padding: 26px 22px 20px`,
`box-shadow: 0 18px 48px rgba(15,23,32,.3)`, entrada com a animação `subir` (.22s ease).
- Círculo 64 × 64 px fundo #FBECEA, ícone de lixeira 30px #C33B2E.
- Título "Excluir paciente": Public Sans 700, 19px.
- Corpo: Public Sans 400, 13.5px, #57646F — "Remover {nome} da agenda? As capturas já enviadas
  permanecem no prontuário."
- Botão "Excluir": 54px, fundo #C33B2E (hover #A62E23), texto #FFF 600/16px.
- Botão "Cancelar": 52px, `border: 1.5px solid #E1E6EB`, fundo #FFF, texto #0F1720.

---

### 03 · Cadastrar paciente
**Purpose:** cadastro local de paciente novo durante a visita.

**Layout:** cabeçalho com botão voltar (36 × 36 px, `radius: 10px`, borda #E1E6EB, glifo "←"),
título "Cadastrar paciente" (600/16px) e subtítulo "Dados de identificação" (400/12.5px, #57646F);
corpo rolável `padding: 16px`, `gap: 14px`; rodapé branco fixo.

**Campos** (todos: rótulo 600/12px #57646F; input 56px de altura, `border: 1.5px solid #E1E6EB`,
`radius: 12px`, `padding: 0 16px`, fundo #FFF, foco `border-color: #1B6FE3`):
1. **Nome completo** — Public Sans 500, 16px; placeholder "Maria Aparecida da Silva"; `inputmode="text"`.
2. **CPF** — IBM Plex Mono 500, 16px; placeholder "000.000.000-00"; `inputmode="numeric"`;
   máscara aplicada ao digitar: `000.000.000-00` (máx. 11 dígitos).
3. **RG** — IBM Plex Mono; placeholder "00.000.000-0"; aceita dígitos, X, ponto e hífen (máx. 14 ch).
4. **Data de nascimento** — IBM Plex Mono; placeholder "DD/MM/AAAA"; `inputmode="numeric"`;
   máscara `DD/MM/AAAA` (máx. 8 dígitos).

**Validação** (só ao tocar em salvar; borda do campo vira #C33B2E e a mensagem aparece abaixo em
Public Sans 500, 11.5px, #C33B2E):
- Nome: mínimo 3 caracteres → "Informe o nome completo."
- CPF: exatamente 11 dígitos → "CPF deve ter 11 dígitos."
- RG: mínimo 5 caracteres alfanuméricos → "RG inválido."
- Nascimento: 8 dígitos → "Use o formato DD/MM/AAAA."; fora de faixa (dia 1–31, mês 1–12,
  ano 1900–2026) → "Data fora do intervalo válido."

**Aviso LGPD** — fundo #EDF3FD, `radius: 12px`, etiqueta "LGPD" + "Dados gravados criptografados
no aparelho e vinculados ao prontuário no próximo envio."

**Botão "Salvar paciente"** — 60px, fundo #1B6FE3, texto #FFF 600/17px. Em sucesso: adiciona o
paciente ao fim da lista (idade derivada do ano de nascimento, detalhe "{idade} anos · cadastrado
agora", estado de envio "enviando"), limpa o formulário e volta para 02.

---

### 04 · Mapa corporal
**Purpose:** escolher e acompanhar os 9 pontos de ausculta do protocolo.

**Layout:** cabeçalho (voltar, "Mapa de ausculta", "{n} de 9 pontos coletados", contador "1/3");
barra de progresso; abas Anterior/Posterior; painel do corpo; cartão de referência; legenda;
rodapé fixo. Container `position: relative` para o pop-up de conclusão.

**Barra de progresso** — trilha 6px `radius: 3px` #E1E6EB; preenchimento #1B8C5A com
`transition: width .35s ease`, largura = coletados / 9.

**Abas** — dois botões `flex: 1`, 42px, `radius: 10px`; ativo fundo #0F1720 texto #FFF,
inativo fundo #FFF texto #57646F. Rótulos "Anterior" e "Posterior".

**Painel do corpo** — cartão fundo #FFF, `border: 1px solid #E1E6EB`, `radius: 16px`,
`padding: 14px 12px 12px`; título "Tórax anterior" / "Tórax posterior" em IBM Plex Mono 600,
11px, `letter-spacing: .1em`, maiúsculas, #57646F, centralizado.
Área do corpo: 344 × 267 px (painel único), `position: relative`, com a ilustração em
`object-fit: contain` preenchendo a caixa. Os pontos são posicionados em **porcentagem** sobre
essa caixa, então a arte pode ser trocada mantendo a proporção 1.16 : 1.

**Marcadores de ponto** — círculos 42px na face posterior e 32px na anterior (mais apertada),
`transform: translate(-50%,-50%)`, `border: 2px`, número do protocolo em Public Sans 700
(16px / 14px). Três estados:
- **pendente**: fundo `rgba(255,255,255,.92)`, borda `rgba(15,23,32,.22)`, número #4A5B69
- **em foco**: fundo e borda #1B6FE3, número #FFF, `box-shadow: 0 4px 14px rgba(27,111,227,.45)`,
  mais um anel pulsante (`@keyframes pulso`, 36px, `rgba(27,111,227,.35)`, 1.6s infinito)
- **coletado**: fundo e borda #1B8C5A, marca "✓" branca
Sombra padrão dos demais: `0 1px 4px rgba(15,23,32,.16)`.

**Posições dos 9 pontos** (x, y em % da caixa do corpo) — **ordem e nomes fixos do protocolo,
não alterar nem substituir**:

| # | Nome | Grupo | Face | x | y | Localização |
|---|------|-------|------|---|---|-------------|
| 1 | Mitral | Cardíaco | anterior | 63 | 55 | 5º EIC esquerdo, linha hemiclavicular (ápice) |
| 2 | Tricúspide | Cardíaco | anterior | 52 | 45 | 4º–5º EIC esquerdo, borda esternal |
| 3 | Aórtico | Cardíaco | anterior | 43 | 28 | 2º EIC direito, borda esternal |
| 4 | Pulmonar | Cardíaco | anterior | 57 | 28 | 2º EIC esquerdo, borda esternal |
| 5 | QID / periumbilical | Intestinal | anterior | 43 | 78 | Quadrante inferior direito, periumbilical |
| 6 | Base direita | Pulmonar | posterior | 60 | 61 | Posterior, infraescapular D |
| 7 | Base esquerda | Pulmonar | posterior | 40 | 61 | Posterior, infraescapular E |
| 8 | Ápice direito | Pulmonar | posterior | 60 | 30 | Posterior, supraescapular D |
| 9 | Ápice esquerdo | Pulmonar | posterior | 40 | 30 | Posterior, supraescapular E |

**Lateralidade:** na face **anterior** a imagem espelha (direita do paciente à esquerda da tela);
na **posterior** não espelha (direita do paciente à direita da tela). Daí 6 e 8 estarem em x=60.

**Cartão de referência** (ponto em foco, ou o próximo pendente **da face visível**):
fundo #FFF, `border: 1px solid #E1E6EB`, `radius: 14px`, `padding: 13px 14px`, flex `gap: 12px`.
- Selo 36 × 36 px, `radius: 10px`, fundo #EDF3FD (ou #E6F4EC se coletado), número em Public Sans
  700, 17px, #1B6FE3 (ou #0F6B45).
- Nome (600/14.5px) + grupo em IBM Plex Mono 600, 10px maiúsculas #57646F na mesma linha.
- Localização: IBM Plex Mono 500, 11.5px, na cor do selo.
- Descrição: Public Sans 400, 12.5px, #57646F.

**Legenda** — três itens com `gap: 14px`, Public Sans 400, 11.5px, #57646F: "Pendente"
(círculo 11px `border: 2px solid #C2CBD4`), "Em foco" (#1B6FE3), "Coletado" (#1B8C5A).

**Rodapé** — dica centralizada (400/13px #57646F): "Toque em um ponto para iniciar a gravação." /
"Ponto em foco: {nome}" / "Todos os pontos validados."; botão 60px fundo #1B6FE3:
"Gravar próximo ponto" / "Gravar {nome}" / "Exame concluído".

**Pop-up "Exame concluído"** (quando os 9 pontos estão coletados; overlay `z-index: 20`,
`rgba(15,23,32,.55)`): cartão `max-width: 320px`, fundo #FFF, `radius: 20px`,
`padding: 28px 22px 22px`, animação `subir`. Círculo 72px #E6F4EC com "✓" 38px #1B8C5A;
título Public Sans 700, 21px; corpo "Os 9 pontos do protocolo foram auscultados e validados nesta
visita."; botão "Concluir visita" 54px #1B6FE3 → volta para 02 e reinicia a coleta.

---

### 05 · Instruções ao paciente
**Purpose:** orientar o paciente **antes** da contagem regressiva. Nunca sobrepor ao timer.

**Layout:** cabeçalho (voltar, nome do ponto, "Orientações antes da captura", contador "2/3");
corpo rolável `padding: 24px 18px 18px`, `gap: 22px`; rodapé fixo.

**Ícone central** — círculo 132 × 132 px, fundo e traço por grupo, SVG 70px, `stroke-width` ~2.5,
traços arredondados:
- **Pulmonar** — pulmões com traqueia; fundo #EDF3FD, traço #1B6FE3
- **Cardíaco** — coração com traçado de ECG; fundo #FBECEA, traço #C33B2E
- **Intestinal** — círculo sereno (olhos fechados e sorriso); fundo #E6F4EC, traço #0F6B45

**Identificação do ponto** (centralizada, abaixo do ícone):
- Título: Public Sans 700, 23px, `letter-spacing: -.015em` — pontos cardíacos recebem o prefixo
  "Foco" ("Foco Mitral"); os demais usam o nome puro ("Base direita").
- Grupo: IBM Plex Mono 600, 11px, `letter-spacing: .12em`, maiúsculas, `margin-top: 9px` —
  cor de texto acessível: #0E4FAE (pulmonar), #C33B2E (cardíaco), #0F6B45 (intestinal).
- Localização anatômica: Public Sans 400, 13px, #57646F.

**Lista de instruções** — um cartão por item (nunca texto corrido), `gap: 9px`: fundo #FFF,
`border: 1px solid #E1E6EB`, `radius: 13px`, `padding: 14px 15px`, flex `gap: 12px`;
marcador circular 24px na cor do grupo com "✓" 13px; texto Public Sans 400, 14.5px,
`line-height: 1.4`, #0F1720.

**Ordem fixa** (respiração → postura/ambiente → boa prática) e **textos exatos**:

*Pulmonar (bases D/E, ápices D/E)*
1. Respire mais fundo e mais devagar que o normal
2. Respire pela boca, não pelo nariz
3. Mantenha o tórax despido na região do ponto
4. Se sentir necessidade, tussa uma vez antes de começarmos

*Cardíaco (mitral, tricúspide, aórtico, pulmonar)*
1. Respire normalmente, sem forçar
2. Fique em ambiente silencioso
3. Quando indicado no app, prenda a respiração por alguns segundos
4. Evite falar durante a captura

*Intestinal (QID/periumbilical)*
1. Relaxe a musculatura abdominal
2. Respire normalmente
3. Evite falar durante a captura
4. Fique parado, sem se mexer

**Rodapé fixo** — botão 60px, `radius: 14px`, #1B6FE3 (hover #0E4FAE), "Tudo pronto, continuar"
→ tela 06. O botão só aparece depois da lista, no rodapé; não há atalho para o timer.

---

### 06 · Gravação ao vivo
**Purpose:** capturar 10 s de áudio no ponto, com feedback de ruído em tempo real.

**Layout:** tema claro igual às demais. Cabeçalho branco (voltar, nome do ponto, subtítulo
"Ponto {n} · {Grupo} · 44.1 kHz · OPUS" em IBM Plex Mono, contador "3/3"); corpo centralizado
verticalmente `padding: 0 20px`, `gap: 26px`; rodapé branco fixo.

**Cronômetro** — IBM Plex Mono 600, 72px, `letter-spacing: -.03em`, formato "10,0s"
(vírgula decimal, décimos). Cor: #0F1720 gravando com sinal bom, #C33B2E com ruído alto,
#6B7885 em repouso. Abaixo, rótulo Public Sans 500, 14px, #57646F: "duração da captura" /
"restantes — mantenha a posição".

**Forma de onda** — caixa 132px, `radius: 16px`, fundo #FFF, `border: 1px solid #E1E6EB`,
34 barras `flex: 1` com `gap: 3px`, `radius: 2px`, altura 8–116px derivada do envelope
respiratório + granulação. Cor: #1B8C5A (sinal bom), #C33B2E (ruído alto), #CBD5DE (repouso).
Com ruído alto, a caixa inteira ganha `animation: tremer .18s linear infinite`.

**Qualidade do sinal (SNR)** — rótulo "Qualidade do sinal (SNR)" (500/12.5px #57646F) e valor
"{n} dB" (IBM Plex Mono 600, 13px) na cor do estado; barra 8px `radius: 4px` trilha #E1E6EB,
preenchimento = SNR / 40 com `transition: width .25s linear`; faixa de aviso `padding: 12px 13px`,
`radius: 12px`, fundo #E6F4EC / #FBECEA, ponto 9px e texto 500/13px na cor do estado:
"Sinal bom — pode gravar" / "Ruído excessivo · reposicionar sensor". **Limiar: 20 dB.**

**Botão de gravação** — círculo 92 × 92 px, `border: 4px solid #E1E6EB`; parado: fundo #1B6FE3
com círculo branco 38px; gravando: fundo #C33B2E com quadrado branco 26px (`radius: 6px`).
Dica abaixo (400/12.5px #57646F): "Toque para gravar 10 s" / "Toque para interromper".

**Comportamento:** a contagem decrementa 0,1 s a cada 100 ms; ao chegar a zero, para e navega
automaticamente para 07. Abaixo de 20 dB de SNR, o aparelho deve vibrar (UI-MOB-002).

---

### 07 · Revisar captura
**Purpose:** ouvir a captura antes de aceitar, evitando novo deslocamento ao domicílio.

**Layout:** cabeçalho "Revisar captura" + "{nome do ponto} · 10 s"; corpo `padding: 16px`,
`gap: 14px`; rodapé com duas ações.

**Player** — cartão fundo #FFF, `border: 1px solid #E1E6EB`, `radius: 16px`, `padding: 16px`:
onda estática de 46 barras (`gap: 2.5px`, #B9CBE4, altura 6–98px); abaixo, botão circular 48px
#1B6FE3 com triângulo branco de play, trilha de 4px #E1E6EB e marcas "0:00" / "0:10" em
IBM Plex Mono 400, 11px, #57646F.

**Qualidade** — linha única (não expor dados técnicos): cartão `padding: 14px 15px`, à esquerda
"Qualidade da captura" (500/13.5px #57646F), à direita "Boa" / "Ruim" em Public Sans 600, 16px,
#0F6B45 / #C33B2E.

**Aviso** — `padding: 13px 14px`, `radius: 12px`, fundo #E6F4EC / #FBECEA, ponto 9px e texto
400/13px na cor do estado: "Som limpo, pode aceitar o ponto." / "Muito ruído na gravação. Refaça
com o sensor mais firme sobre o ponto."

**Rodapé** — "Refazer" (`flex: 1`, 60px, `border: 1.5px solid #E1E6EB`, fundo #FFF) volta para 06;
"Aceitar ponto" (`flex: 1.4`, 60px, fundo #1B8C5A, texto #FFF) marca o ponto como coletado, limpa
o foco e volta para 04.

---

## Interactions & Behavior

**Fluxo de navegação**
```
01 Login ──► 02 Pacientes ──► 04 Mapa ──► 05 Instruções ──► 06 Gravação ──► 07 Revisão
                  │  ▲                ▲                                         │
                  │  └──── pop-up "Exame concluído" (9/9) ◄────────────── aceitar ponto
                  └──► 03 Cadastro ───┘ (salvar volta para 02)
```
- Tocar num paciente abre o mapa daquela visita.
- Tocar num marcador põe o ponto em foco (não grava direto); o botão do rodapé leva às instruções.
- "Gravar próximo ponto" escolhe o primeiro pendente **da face visível**, senão o primeiro pendente.
- Aceitar um ponto sempre volta ao mapa. O nono ponto dispara o pop-up de conclusão.
- "Concluir visita" volta para 02 e zera os pontos coletados.
- Voltar (←) sobe um nível: instruções → mapa, mapa → pacientes, cadastro → pacientes.

**Animações** (todas em `@keyframes`, com `prefers-reduced-motion` a considerar na implementação)
- `pulso` — anel do ponto em foco: `scale(1) opacity .9` → `scale(2.6) opacity 0` em 70% → fim;
  1.6s `ease-out` infinito. O `translate(-50%,-50%)` precisa estar **dentro** dos keyframes.
- `tremer` — onda com ruído alto: ±2px em X, .18s linear infinito.
- `subir` — entrada dos diálogos: `opacity 0, translateY(6px)` → normal, .22s ease.
- Barra de progresso: `width` .35s ease. Barra de SNR: `width` .25s linear.

**Estados de hover** — botões primários escurecem para #0E4FAE; cartões e botões de borda passam
a `border-color: #C8D2DB`; lixeira ganha fundo #FBECEA e traço #C33B2E; itens do índice lateral
(só protótipo) vão para #E3E9EF.

**Offline / envio** — o estado de conexão altera o chip do cabeçalho e o ícone de cada paciente.
Sem rede: capturas ficam no banco local criptografado e sobem sozinhas quando a rede voltar
(UI-MOB-003). Não há tela de fila; o estado vive na linha do paciente.

## State Management

Estado do protótipo (traduzir para o gerenciador do codebase):
- `tela` — tela atual: login | hoje | cadastro | mapa | instrucoes | gravacao | revisao
- `face` — 'anterior' | 'posterior' (aba do mapa)
- `ponto` — id do ponto em foco (C1–C4, I1, L1–L4) ou null
- `coletados` — mapa { idDoPonto: true } dos pontos aceitos
- `gravando`, `restante` (segundos, 1 decimal), `quadro` (tick da animação da onda)
- `online` — conectividade (no app, vem do sistema)
- `ruido` — ruído ambiente alto (no app, derivado do SNR medido)
- `novos` — pacientes cadastrados em campo; `removidos` — índices excluídos
- `form` { nome, cpf, rg, nasc }, `tentouSalvar` — cadastro e exibição de erros
- `excluindo` — índice do paciente no diálogo de exclusão, ou null
- `popupVisto` — se o aviso de exame concluído já foi dispensado

**Dados reais a substituir:** lista de pacientes e horários, conectividade, SNR e forma de onda,
áudio gravado, persistência do cadastro e da exclusão, fila de upload, bundle FHIR.

## Design Tokens

**Cores**
| Token | Hex | Uso |
|---|---|---|
| acc | #1B6FE3 | ação primária, ponto em foco, azul pulmonar |
| acc-d | #0E4FAE | hover primário, texto azul acessível |
| bg | #EEF1F4 | fundo das telas |
| surf | #FFFFFF | cartões, cabeçalho, rodapé |
| surf2 | #F5F7F9 | campos, cartões internos |
| ink | #0F1720 | texto principal, aba ativa |
| mut | #57646F | texto secundário |
| line | #E1E6EB | bordas, trilhas |
| chip | #EDF3FD | fundo informativo azul |
| ok | #1B8C5A | preenchimentos verdes (ponto coletado, onda, progresso) |
| ok-txt | #0F6B45 | texto/ícone verde (contraste) |
| warn | #C9821B → texto #8A5A0B | estado offline |
| bad | #C33B2E | erro, ruído alto, exclusão, vermelho cardíaco |
| — | #2A4A72 | texto sobre fundo #EDF3FD |
| — | #A62E23 | hover do botão de exclusão |
| — | #6B7885 | cronômetro em repouso |
| — | #B9CBE4 | onda estática da revisão |
| — | #CBD5DE | onda em repouso |
| — | #4A5B69 | número do ponto pendente |
| — | #C8D2DB | borda em hover |

**Tipografia** — Public Sans (300/400/500/600/700) para interface; IBM Plex Mono (400/500/600)
para números, códigos e etiquetas técnicas.
Escala em uso: 30 / 27 / 24 / 23 / 21 / 19 / 17 / 16.5 / 16 / 14.5 / 13.5 / 13 / 12.5 / 12 /
11.5 / 11 / 10.5 / 10 px; cronômetro 72px; mínimo de 10px só em etiquetas maiúsculas monospace.

**Espaçamento** — 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 18, 20, 22, 24, 26, 28 px;
`padding` de tela 16–20px; `gap` de lista 9–10px.

**Raios** — 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 20 px; 50% em círculos; pílula 20px.

**Sombras**
- Diálogos: `0 18px 48px rgba(15,23,32,.3)`
- Ponto em foco: `0 4px 14px rgba(27,111,227,.45)`
- Pontos normais: `0 1px 4px rgba(15,23,32,.16)`
- Overlay: `rgba(15,23,32,.55)`

**Alturas de toque** — botões primários 60px; secundários 52–54px; campos 56px; botão voltar
36 × 36 px; botão de gravação 92 × 92 px; botão + 30 × 30 px (ver ressalva em Fidelity).

**Aparelho** — 412 × 892 px (frame Android), área útil de tela 812px, todas as telas com altura
fixa e rolagem interna na região de conteúdo.

## Assets

- `assets/torso-frente.png` e `assets/torso-dorso.png` — ilustrações do tórax anterior e
  posterior. **Placeholders fornecidos pelo cliente, sem licença verificada.** Substituir por arte
  licenciada ou própria, mantendo proporção ~1.16 : 1 e o mesmo enquadramento (ombros ao quadril);
  as coordenadas dos pontos são percentuais e se mantêm.
- Ícones — todos SVG inline desenhados no protótipo (nuvem, flecha, rede cortada, lixeira, pulmões,
  coração com ECG, círculo sereno, check, play). Recomendado recriar com a biblioteca de ícones do
  codebase, preservando peso de traço e pontas arredondadas.
- Fontes — Public Sans e IBM Plex Mono (Google Fonts, SIL Open Font License).
- Sem imagens geradas por IA e sem emoji.

## Files

- `App do Agente.dc.html` — protótipo completo, as 7 telas com toda a interatividade.
  A lateral, o frame Android e os controles de simulação são andaimes do protótipo.
- `App do Agente-print.dc.html` — versão paginada para PDF (3 páginas paisagem).
- `android-frame.jsx`, `doc-page.js`, `support.js` — andaimes do protótipo, não são o design.
- `assets/` — as duas ilustrações do corpo.
- `PONTOS-DE-AUSCULTA.md` — **os 9 pontos de ausculta do protocolo**, com nomes e ordem obrigatórios.
  Qualquer tela, formulário ou texto sobre captura de áudio deve usar exatamente esses 9.
