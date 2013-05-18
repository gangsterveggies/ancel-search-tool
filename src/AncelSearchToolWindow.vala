/***
    BEGIN LICENSE

    Copyright (C) 2013 David Gomes <davidrafagomes@gmail.com>,
                       Pedro Paredes <gangsterveggies@gmail.com>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>

    END LICENSE
***/

namespace AncelSearchTool {

    public class AncelSearchToolWindow : Gtk.Window {

        public AncelSearchTool app;

        private unowned Thread<void*> search_thread;
        private bool search_cancel;
        private bool search_over;
        
        private Gtk.Grid layout_grid;

        private Gtk.ScrolledWindow scrolled_window;

        private Gtk.TreeStore model;
        private Gtk.TreeView list;

        private Gee.HashMap<string, Gtk.TreeIter?> parent_map;

        private Gtk.Label search_text_label;
        private Gtk.Label search_location_label;
        private Gtk.Label search_results_label;

        private Gtk.Entry search_text_entry;
        private Gtk.FileChooserButton file_chooser_button;

        private Gtk.Button search_button;
        private Gtk.Button about_button;

        public AncelSearchToolWindow (Granite.Application app) {
            this.app = app as AncelSearchTool;
            set_application (app);
            init ();
        }

        private void init () {
            icon_name = "";
            this.search_cancel = false;
            this.search_over = true;
            parent_map = new Gee.HashMap<string, Gtk.TreeIter?> ();

            title = _("Search Tool");
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

            setup_ui ();
            show_all ();

            set_size_request (640, 400);
        }

        private void append_to_list (Result new_item) {
            Gtk.TreeIter iter;

            if (parent_map.has_key (new_item.parent)) {
                model.append (out iter, parent_map.get (new_item.parent));
            } else {
                model.append (out iter, null);
            }

            string color_string = "white";

            if (!SearchEngine.keyword_match (new_item.name)) {
                color_string = "red";
            }

            if (new_item.type == "Directory") {
                parent_map.set (new_item.location, iter);
            }

            model.set (iter, 0, new_item.name, 1, new_item.type, 2, new_item.location, 3, color_string);
        }

        private void* search_func () {
            SearchEngine.init_search(file_chooser_button.get_filename (), search_text_entry.text);

            while (!this.search_cancel && SearchEngine.has_next ()) {
                append_to_list (SearchEngine.get_next ());
                list.expand_all ();
                Thread.usleep (1000);
            }

            search_over = true;
            Thread.usleep (1000);
            this.search_button.set_label ("Search");
            return null;
        }

        private void on_search_clicked () {
            if (search_over) {
                parent_map.clear ();
                search_cancel = false;
                search_over = false;
                search_button.set_label ("Stop");
                model.clear();

                try {
                    // New version of Threading (not working)
                    // search_thread = new Thread<void*> (search_func);
                    search_thread = Thread.create<void*> (search_func, false);              
                } catch (ThreadError e) {
                    stderr.printf ("%s\n", e.message);
                    return;
                }
            } else {
                this.search_cancel = true;
                search_thread.join ();
            }
        }

        private void setup_ui () {
            layout_grid = new Gtk.Grid ();

            search_text_label = new Gtk.Label ("Search for:");
            search_text_label.set_alignment (0, 0.5f);
            search_text_label.set_justify (Gtk.Justification.LEFT);

            search_location_label = new Gtk.Label ("Search in:");
            search_location_label.set_alignment (0, 0.5f);
            search_location_label.set_justify (Gtk.Justification.LEFT);

            search_results_label = new Gtk.Label ("Results:");
            search_results_label.set_alignment (0, 0.5f);
            search_results_label.set_justify (Gtk.Justification.LEFT);

            search_text_entry = new Gtk.Entry ();
            search_text_entry.hexpand = true;

            file_chooser_button = new Gtk.FileChooserButton ("Open", Gtk.FileChooserAction.SELECT_FOLDER);

            layout_grid.row_spacing = 10;

            layout_grid.attach (search_text_label, 1, 1, 1, 1);
            layout_grid.attach (search_text_entry, 2, 1, 12, 1);

            layout_grid.attach (search_location_label, 1, 2, 1, 1);
            layout_grid.attach (file_chooser_button, 2, 2, 12, 1);

            layout_grid.attach (search_results_label, 1, 3, 1, 1);

            layout_grid.margin = 12;

            model = new Gtk.TreeStore (4, typeof (string), typeof (string), typeof (string), typeof (string));
            list = new Gtk.TreeView.with_model (this.model);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();
            cell.set ("background_set", true);
            list.insert_column_with_attributes (-1, "Filename", cell, "text", 0, "background", 3);
            list.insert_column_with_attributes (-1, "Type", cell, "text", 1, "background", 3);
            list.insert_column_with_attributes (-1, "Location", cell, "text", 2, "background", 3);
            list.hexpand = true;
            list.vexpand = true;
            list.row_activated.connect (on_row_activated);

            scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (list);
            layout_grid.attach (scrolled_window, 1, 4, 13, 1);

            search_button = new Gtk.Button.with_label ("Search");
            layout_grid.attach (search_button, 13, 5, 1, 1);
            search_button.clicked.connect (on_search_clicked);

            about_button = new Gtk.Button.with_label ("About");
            layout_grid.attach (about_button, 1, 5, 1, 1);

            about_button.clicked.connect (() => {
                this.app.show_about (this);
            });

            add (layout_grid);
        }

        private void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
            Gtk.TreeIter iter;
            treeview.model.get_iter (out iter, path);
            Result item = new Result.null ();
            treeview.model.get (iter, 1, out item.type, 2, out item.location);
            
            try {
                string[] spawn_args = {"xdg-open", item.location};
                string[] spawn_env = Environ.get ();
                Pid child_pid;
                Process.spawn_async ("/", spawn_args, spawn_env, SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out child_pid);
            } catch (SpawnError e) {
                stdout.printf ("File Error trying to open a file: %s\n", e.message);
            }
        }
    }
}
