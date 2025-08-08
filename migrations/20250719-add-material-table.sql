#lang north

-- @revision: 51248c7851558d784e401a5996edefee
-- @parent: e71b8631cf565603f4a0722094e3d5ec
-- @description: Alters some table.
-- @up {
create table materials(
  id serial primary key,
  partno text not null unique,
  description text not null,
  manufactorer text,
  mpn text,
  image bytea
);
-- }

-- @down {
drop table materials;
-- }