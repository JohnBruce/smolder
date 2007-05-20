CREATE TABLE project (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT, 
    name                TEXT NOT NULL,
    start_date          INTEGER NOT NULL,
    public              INTEGER DEFAULT 1,
    enable_rss          INTEGER DEFAULT 1,
    default_platform    TEXT DEFAULT '',
    default_arch        TEXT DEFAULT '',
    graph_start         TEXT DEFAULT 'project',
    allow_anon          INTEGER DEFAULT 0
);

CREATE UNIQUE INDEX i_project_name_project on project (name);

