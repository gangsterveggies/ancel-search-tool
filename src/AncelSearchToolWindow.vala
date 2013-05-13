/***
    BEGIN LICENSE

    Copyright (C) 2013 David Gomes <davidrafagomes@gmail.com>, Pedro Paredes <gangsterveggies@gmail.com>

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

using Gtk;
using Gdk;

namespace AncelSearchTool {

    public class AncelSearchToolWindow : Gtk.Window {

        public AncelSearchTool app;

        private unowned Thread<void*> search_thread;
        private bool search_cancel;
        private bool search_over;
        
        private Grid layout_grid;

        private ScrolledWindow scrolled_window;

        private ListStore model;
        private TreeView list;

        private Label search_text_label;
        private Label search_location_label;

        private Entry search_text_entry;
        private FileChooserButton file_chooser_button;

        private Button search_button;
        private Button about_button;

        public AncelSearchToolWindow (Granite.Application app) {
            this.app = app as AncelSearchTool;
            set_application (app);
            init ();
        }

        private void init () {
            icon_name = "";
            this.search_cancel = false;
            this.search_over = true;

            title = _("Ancel Search Tool");
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

            setup_ui ();
            show_all ();

            set_size_request (640, 400);
        }

        private void append_to_list (Result new_item) {
            TreeIter iter;
            model.append (out iter);
            model.set (iter, 0, new_item.name, 1, new_item.type, 2, new_item.location);
        }

        private void* search_func () {
            SearchTool.init_search(file_chooser_button.get_filename (), search_text_entry.text);

            while (!this.search_cancel && SearchTool.has_next()) {
                append_to_list (SearchTool.get_next());
                Thread.usleep (1000);
            }

            search_over = true;
            Thread.usleep (1000);
            this.search_button.set_label ("Search");
            return null;
        }

        private void on_search_clicked() {
            if (search_over) {
                search_cancel = false;
                search_over = false;
                search_button.set_label ("Cancel");
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
                search_thread.join();
            }
        }

        private void setup_ui () {
            layout_grid = new Grid ();

            search_text_label = new Label ("Search for:");
            search_text_label.set_alignment (0, 0.5f);
            search_text_label.set_justify (Justification.LEFT);

            search_location_label = new Label ("Search in:");
            search_location_label.set_alignment (0, 0.5f);
            search_location_label.set_justify (Justification.LEFT);

            search_text_entry = new Entry ();
            search_text_entry.hexpand = true;

            file_chooser_button = new FileChooserButton ("Open", Gtk.FileChooserAction.SELECT_FOLDER);

            layout_grid.row_spacing = 10;

            layout_grid.attach (search_text_label, 1, 1, 1, 1);
            layout_grid.attach (search_text_entry, 2, 1, 12, 1);

            layout_grid.attach (search_location_label, 1, 2, 1, 1);
            layout_grid.attach (file_chooser_button, 2, 2, 12, 1);

            layout_grid.margin = 12;

            model = new ListStore (3, typeof (string), typeof (string), typeof (string));
            list = new TreeView.with_model (this.model);
            CellRendererText cell = new CellRendererText ();
            list.insert_column_with_attributes (-1, "Filename", cell, "text", 0);
            list.insert_column_with_attributes (-1, "Type", cell, "text", 1);
            list.insert_column_with_attributes (-1, "Location", cell, "text", 2);
            list.hexpand = true;
            list.vexpand = true;
            list.row_activated.connect (on_row_activated);

            scrolled_window = new ScrolledWindow (null, null);
            scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
            scrolled_window.add (list);
            layout_grid.attach (scrolled_window, 1, 4, 13, 1);

            search_button = new Button.with_label ("Search");
            layout_grid.attach (search_button, 1, 5, 1, 1);
            search_button.clicked.connect (on_search_clicked);

            about_button = new Button.with_label ("About");
            layout_grid.attach (about_button, 2, 5, 1, 1);
            about_button.clicked.connect (() => {
                this.app.show_about (this);
            });

            add (layout_grid);
        }

        private string console_clean (string command) {
            string new_string = "";
            int i;
            
            for (i = 0; i < command.length; i++) {
                if (command[i].isspace ()) {
                    new_string += "\\";
                }

                new_string += command[i].to_string ();
            }

            return new_string;
        }

        private void on_row_activated (TreeView treeview , TreePath path, TreeViewColumn column) {
            TreeIter iter;
            treeview.model.get_iter (out iter, path);
            Result item = new Result.null ();
            treeview.model.get (iter, 1, out item.type, 2, out item.location);

            if (item.type == "Directory") {
                try {
                    Process.spawn_command_line_async ("xdg-open " + console_clean (item.location));
                } catch (Error e) {
                    stderr.printf ("File Error trying to open a directory: %s\n", e.message);
                }
            }
        }
    }
}
