/***
    BEGIN LICENSE

    Copyright (C) 2013 Pedro Paredes <gangsterveggies@gmail.com>

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

public class OptionBox : Gtk.Box {
    public static const int CONTAINS_TYPE = 0;
    public static const int REGULAR_TYPE = 1;

    public static const string[] labels = {"File contains:", "Regular Expression:"};

    private Gtk.Entry text_entry;
    private Gtk.Label text_label;
    private Gtk.Button remove_button;

    private int type;
    
    public OptionBox (Gtk.Orientation _orientation, int _spacing, int _type) {
        orientation = _orientation;
        spacing = _spacing;
        type = _type;
        text_label = new Gtk.Label (labels[type]);
        text_entry = new Gtk.Entry ();
        remove_button = new Gtk.Button.with_label ("Remove");
        pack_start (text_label, false, false, 8);
        pack_start (text_entry, true, true, 3);
        pack_start (remove_button, false, false, 0);
    }
}
