-- Tabela principal: 1 linha por leiturista por dia
create table if not exists jornada (
  id            bigserial primary key,
  matricula     text not null,
  data          date not null,
  rz            text,
  hora_inicial  text,
  hora_final    text,
  span_min      integer,        -- total de minutos entre 1ª e última leitura
  qtd_leituras  integer,
  gaps_json     text,           -- array JSON com gaps >= 5min ex: [12,45,180]
  rotas_json    text,           -- array JSON com "rota|local_cod" ex: ["7|3301","19|3301"]
  created_at    timestamptz default now(),
  unique(matricula, data)       -- substituição automática
);

create index if not exists idx_jornada_mat_data on jornada(matricula, data);

-- Tabela de matrículas
create table if not exists matriculas (
  matricula        text primary key,
  nome_leiturista  text,
  funcao           text,
  base             text,
  situacao         text
);

-- Tabela local -> base (fixa)
create table if not exists local_base (
  local   text primary key,
  cidade  text,
  base    text
);

alter table jornada    disable row level security;
alter table matriculas disable row level security;
alter table local_base disable row level security;

-- ============================================================
-- MIGRAÇÃO: trava única de jornada precisa incluir o RZ.
-- Rodar uma vez no SQL Editor do Supabase da GBS (projeto ndwivbhqglpnfyqwjbzu).
-- O upload é 1 arquivo por RZ, e um leiturista pode trabalhar em mais de um RZ no
-- mesmo dia (arquivos separados). Com a trava só em (matricula,data), o upsert do
-- segundo RZ sobrescrevia inteiro a linha que o primeiro já tinha gravado pra aquele
-- dia -- o Painel mostrava só os horários da última RZ processada, como se o
-- leiturista tivesse começado mais tarde do que realmente começou. Com RZ na trava,
-- cada RZ vira sua própria linha (reprocessar a mesma RZ continua seguro, substitui só
-- ela mesma); a tela já soma todas as linhas do dia (ver renderTabela em index.html).
alter table jornada drop constraint if exists jornada_matricula_data_key;
alter table jornada add constraint jornada_matricula_data_rz_key unique (matricula, data, rz);
