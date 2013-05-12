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

public class Result {
    public string location;
    public string name;

    public Result (string _location, string _name) {
        location = _location;
        name = _name;
    }
}

public class SearchTool {
    public static string keyword;
    public static string next;
    public static bool begin;
    public static int counter;
    public static FileEnumerator enumerator;
    public static ArrayList<string> dir_stack;
    
    public static Result parseLocation (string loc) {
        string name = "";

        for (int i = loc.length - 1; i >= 0; i--) {
            name += loc[i].to_string ();
        }

        return new Result (loc, name);
    }

    public static void init_search (string _location, string _keyword) {
        dir_stack = new ArrayList<string> ();
        dir_stack.add (_location);
        begin = true;
        counter = 1;
        keyword = _keyword;
        next = "";
    }

    public static bool has_next () {
        try {
            FileInfo file_info = null;
            if (enumerator != null && (file_info = enumerator.next_file()) != null) {
                next = file_info.get_name ();
            }
            else {
                if (!begin) {
                    dir_stack.remove_at(0);
                    counter--;
                    if (counter == 0)
                        return false;
                }
                begin = false;
                var directory = File.new_for_path (dir_stack.first ());
                enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                while ((file_info = enumerator.next_file ()) == null) {
                    dir_stack.remove_at (0);
                    counter--;
                    if (counter == 0)
                        return false;
                    directory = File.new_for_path (dir_stack.first ());
                    enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                }
                next = file_info.get_name();
            }
        } catch (Error e) {
            stderr.printf ("File Error trying to read a directory: %s\n", e.message);
        }
        return true;
    }
}