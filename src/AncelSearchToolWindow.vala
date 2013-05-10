/***
    BEGIN LICENSE

    Copyright (C) 2013 David Gomes <davidrafagomes@gmail.com>

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

        private Grid layout_grid;

        private ScrolledWindow scrolled_window;

        private ListStore model;
        private TreeView list;

        private Label search_text_label;
        private Label search_location_label;

        private Entry search_text_entry;
        private FileChooserButton file_chooser_button;

        private Button search_button;

        public AncelSearchToolWindow (Granite.Application app) {
            application = app as AncelSearchTool;
            set_application (app);
            init ();
        }

        private void init () {
            icon_name = "";

            title = _("Ancel Search Tool");
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

            setup_ui ();
            show_all ();

            set_size_request (640, 400);
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
            search_text_entry.margin_left = 10;
            search_text_entry.hexpand = true;

            file_chooser_button = new FileChooserButton ("Open", Gtk.FileChooserAction.SELECT_FOLDER);

            layout_grid.row_spacing = 10;

            layout_grid.attach (search_text_label, 1, 1, 1, 1);
            layout_grid.attach (search_text_entry, 2, 1, 1, 1);

            layout_grid.attach (search_location_label, 1, 3, 1, 1);
            layout_grid.attach (file_chooser_button, 2, 3, 1, 1);

            layout_grid.margin = 12;

            model = new ListStore (1, typeof (string));
            list = new TreeView.with_model (this.model);
            list.insert_column_with_attributes (-1, "Filename",
                                                new CellRendererText (), "text", 0);
            list.hexpand = true;
            list.vexpand = true;

            /* TEMP Add an example member to the tree view */
            TreeIter iter;
            model.append (out iter);
            model.set (iter, 0, "Example");

            scrolled_window = new ScrolledWindow (null, null);
            scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.NEVER);
            scrolled_window.add (list);
            layout_grid.attach (scrolled_window, 1, 4, 2, 1);

            add (layout_grid);
        }
    }
}
