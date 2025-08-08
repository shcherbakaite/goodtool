#lang north

-- @revision: 69affc4e2f35aff1ba5a1adebfd6b362
-- @parent: 51248c7851558d784e401a5996edefee
-- @description: Alters some table.
-- @up {
create table applications(
  id serial primary key,
  description text,
  note text
);
-- }

-- @down {
drop table applications;
-- }