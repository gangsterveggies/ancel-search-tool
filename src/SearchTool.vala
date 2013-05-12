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
    public string type;

    public Result.null () {
        location = "";
        name = "";
        type = "";
    }

    public Result (string _location, string _name, string _type) {
        location = _location;
        name = _name;
        if (_type != "") {
            type = _type;
        }
        else {
            type = "Executable";
        }
    }
}

public class SearchTool {
    public static string current_location;
    public static string keyword;
    public static string next;
    public static FileType next_type;
    public static bool begin;
    public static int counter;
    public static FileEnumerator enumerator;
    public static ArrayList<string> dir_stack;
    
    public static Result parseLocation (string loc, FileType file_type) {
        string name = "";
        string type = "";
        
        if (file_type == FileType.REGULAR) {
            int i;
            for (i = 0; i < loc.length; i++) {
                if (loc[i] == '.') {
                    i++;
                    break;
                }
                name += loc[i].to_string ();
            }
            
            for (; i < loc.length; i++) {
                type += loc[i].to_string();
            }
            return new Result (current_location + "/" + loc, name, type);
        }
        else if (file_type == FileType.DIRECTORY) {
            return new Result (current_location + "/" + loc, loc, "Directory");
        }
        else {
            return new Result (current_location + "/" + loc, loc, "Other");
        }
    }

    public static void init_search (string _location, string _keyword) {
        dir_stack = new ArrayList<string> ();
        dir_stack.add (_location);
        begin = true;
        counter = 1;
        keyword = _keyword;
    }

    public static Result get_next () {
        return parseLocation (next, next_type);
    }

    public static bool has_next () {
        try {
            FileInfo file_info = null;
            if (enumerator != null && (file_info = enumerator.next_file()) != null) {
                next = file_info.get_name ();
                next_type = file_info.get_file_type ();
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
                current_location = dir_stack.first ();
                while ((file_info = enumerator.next_file ()) == null) {
                    dir_stack.remove_at (0);
                    counter--;
                    if (counter == 0)
                        return false;
                    directory = File.new_for_path (dir_stack.first ());
                    enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                    current_location = dir_stack.first ();
                }
                next = file_info.get_name();
                next_type = file_info.get_file_type ();
            }
        } catch (Error e) {
            stderr.printf ("File Error trying to read a directory: %s\n", e.message);
        }
        if (!(keyword.down () in next.down ()) && keyword != "*") {
            return has_next ();
        }
        return true;
    }
}