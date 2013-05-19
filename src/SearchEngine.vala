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

using Gee;

public class SearchEngine {
    public static string current_location;
    public static string original_location;
    public static string keyword;
    public static string next;
    public static string next_extension;
    public static GLib.Icon next_icon;
    public static FileType next_type;
    public static bool begin;
    public static int counter;
    public static FileEnumerator enumerator;
    public static ArrayList<string> dir_stack;

    public static Result get_parent_directory (string location) {
        string name = "";
        string parent = "";
        
        int i;
        
        for (i = location.length - 1; i >= 0 && location[i] != '/'; i--) {
            name += location[i].to_string ();
        }
        
        i--;

        for (; i >= 0; i--) {
            parent += location[i].to_string ();
        }

        return new Result (location, name.reverse (), "Directory", parent.reverse (), new GLib.ThemedIcon (""));
    }

    public static Result parse_location (string loc, FileType file_type, string type, string parent, GLib.Icon icon) {
        string name = "";
        
        if (file_type == FileType.REGULAR) {
            int i;

            for (i = loc.length - 1; i >= 0; i--) {
                if (loc[i] == '.') {
                    break;
                }
            }
            
            if (i == -1) {
                i = loc.length - 1;
            }

            name = loc.slice (0, i);

            return new Result (current_location + "/" + loc, name, type, parent, icon);
        } else if (file_type == FileType.DIRECTORY) {
            return new Result (current_location + "/" + loc, loc, "Directory", parent, icon);
        } else {
            return new Result (current_location + "/" + loc, loc, "Other", parent, icon);
        }
    }

    public static void init_search (string _location, string _keyword) {
        dir_stack = new ArrayList<string> ();
        dir_stack.add (_location);
        begin = true;
        counter = 1;
        keyword = _keyword;
        original_location = _location;
    }

    public static Result get_next () {
        return parse_location (next, next_type, next_extension, dir_stack.first (), next_icon);
    }

    public static bool keyword_match (string word) {
        return !((keyword.length > word.length || !(keyword.down () in word.down ())) && keyword != "*");
    }

    public static bool has_next () {
        try {
            FileInfo file_info = null;

            if (enumerator != null && (file_info = enumerator.next_file ()) != null) {
                next = file_info.get_name ();
                next_type = file_info.get_file_type ();
                next_extension = file_info.get_content_type ();
                next_icon = file_info.get_icon ();
            } else {
                if (!begin) {
                    dir_stack.remove_at(0);
                    counter--;

                    if (counter == 0) {
                        return false;
                    }
                }

                begin = false;
                var directory = File.new_for_path (dir_stack.first ());
                enumerator = directory.enumerate_children ("standard::*", 0);
                current_location = dir_stack.first ();

                while ((file_info = enumerator.next_file ()) == null) {
                    dir_stack.remove_at (0);
                    counter--;

                    if (counter == 0) {
                        return false;
                    }

                    directory = File.new_for_path (dir_stack.first ());
                    enumerator = directory.enumerate_children ("standard::*", 0);
                    current_location = dir_stack.first ();
                }

                next = file_info.get_name ();
                next_type = file_info.get_file_type ();
                next_extension = file_info.get_content_type ();
                next_icon = file_info.get_icon ();
            }
        } catch (Error e) {
            stderr.printf ("File Error trying to read a directory: %s\n", e.message);
        }

        if (next_type == FileType.DIRECTORY) {
            dir_stack.add (current_location + "/" + next);
            counter++;
        }

        if (!keyword_match (next)) {
            return has_next ();
        }

        return true;
    }
}
