#lang north

-- @revision: e71b8631cf565603f4a0722094e3d5ec
-- @parent: efed79200bf19e497ce82c46ae7c7999
-- @description: Creates tool table.
-- @up {
create table tools(
  id serial primary key,
  partno text not null unique,
  description text not null,
  manufactorer text,
  mpn text,
  image bytea
);
-- }

-- @down {
drop table tools;
-- }