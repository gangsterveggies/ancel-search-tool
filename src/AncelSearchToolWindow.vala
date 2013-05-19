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
    using Gtk;

    public class AncelSearchToolWindow : Gtk.Window {

        public AncelSearchTool app;

        private unowned Thread<void*> search_thread;
        private bool search_cancel;
        private bool search_over;

        private string initial_directory;
        
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

        public AncelSearchToolWindow (Granite.Application _app) {
            app = _app as AncelSearchTool;
            set_application (_app);
            init ();
        }

        private void init () {
            icon_name = "";
            search_cancel = false;
            search_over = true;
            initial_directory = "";
            parent_map = new Gee.HashMap<string, Gtk.TreeIter?> ();

            title = _("Search Tool");
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            key_press_event.connect (on_key_pressed);

            setup_ui ();
            show_all ();

            set_size_request (640, 400);
        }

        private bool on_key_pressed (Gtk.Widget source, Gdk.EventKey key) {
            if (key.keyval == Gdk.Key.Return && search_text_entry.is_focus) {
                on_search_clicked ();               
            } else if (key.keyval == Gdk.Key.Escape) {
                this.destroy ();
            }

            return false;
        }

        private void append_to_list (Result new_item) {
            Gtk.TreeIter iter;

            if (new_item.parent == initial_directory) {
                model.append (out iter, null);
            } else {
                if (!parent_map.has_key (new_item.parent)) {
                    append_to_list (SearchEngine.get_parent_directory (new_item.parent));
                }

                model.append (out iter, parent_map.get (new_item.parent));
            }
            GLib.Icon icon = new_item.icon;

            if (new_item.type == "Directory") {
                parent_map.set (new_item.location, iter);
                try {
                    icon = IconTheme.get_default ().load_icon (Gtk.Stock.DIRECTORY, 16, 0);
                } catch (GLib.Error e) {
                    stderr.printf ("Error trying to open Icon: %s\n", e.message);
                }
            }

            if (icon == null) {
                try {
                    icon = IconTheme.get_default ().load_icon (Gtk.Stock.FILE, 16, 0); }
                catch (GLib.Error e) {
                    stderr.printf ("Error trying to open Icon: %s\n", e.message);
                }
            }

            model.set (iter, 0, new_item.name, 1, new_item.type, 2, new_item.location, 3, icon);
        }

        private void* search_func () {
            SearchEngine.init_search (initial_directory, search_text_entry.text);

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
                initial_directory = file_chooser_button.get_filename ();
                
                if (search_text_entry.text == "") {
                    return;
                }

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

            model = new Gtk.TreeStore (4, typeof (string), typeof (string), typeof (string), typeof (GLib.Icon));
            list = new Gtk.TreeView.with_model (this.model);
            Gtk.CellRendererText cell = new Gtk.CellRendererText ();

            Gtk.TreeViewColumn col = new Gtk.TreeViewColumn ();
            col.title = "Filename";
            col.resizable = true;
            var crp = new Gtk.CellRendererPixbuf ();
            col.pack_start (crp, false);
            col.add_attribute (crp, "gicon", 3);
            
            var crt = new CellRendererText ();
            col.pack_start (crt, false);
            col.add_attribute (crt, "text", 0);

            list.insert_column (col, -1);           
            list.insert_column_with_attributes (-1, "Type", cell, "text", 1);
            list.insert_column_with_attributes (-1, "Location", cell, "text", 2);
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
