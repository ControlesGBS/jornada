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
