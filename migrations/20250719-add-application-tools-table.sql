#lang north

-- @revision: d29e0df6f0a1e331451044bdf51ef9c1
-- @parent: 8741ef5b3a20d142f1399e9128b15f7f
-- @description: Alters some table.
-- @up {
create table application_tools(
  id serial primary key,
  applicationid integer REFERENCES applications(id),
  toolid integer REFERENCES tools(id)
);
-- }

-- @down {
drop table application_tool;
-- }