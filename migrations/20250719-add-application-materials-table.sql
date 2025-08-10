#lang north

-- @revision: 8741ef5b3a20d142f1399e9128b15f7f
-- @parent: 69affc4e2f35aff1ba5a1adebfd6b362
-- @description: Alters some table.
-- @up {
create table application_materials(
  id serial primary key,
  applicationid integer REFERENCES applications(id) ON DELETE CASCADE,
  materialid integer REFERENCES materials(id) ON DELETE CASCADE
);
-- }

-- @down {
drop table application_material;
-- }